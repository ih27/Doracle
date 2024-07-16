import 'dart:async' show TimeoutException;
import 'dart:io' show Platform;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

const int _maxRetries = 3;
const Duration _retryDelay = Duration(minutes: 15);

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  //await Firebase.initializeApp();

  debugPrint("Handling a background message: ${message.messageId}");
}

Future<void> setupNotifications() async {
  await FirebaseMessaging.instance.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  FirebaseMessaging.instance.onTokenRefresh.listen((fcmToken) {
    debugPrint('FCM token refresh callback called...');
  }).onError((err) {
    debugPrint('Error in token refresh: $err');
  });

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    debugPrint('Got a message whilst in the foreground!');
    debugPrint('Message data: ${message.data}');

    if (message.notification != null) {
      debugPrint(
          'Message also contained a notification: ${message.notification}');
    }
  });

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Start the token retrieval process without blocking
  if (Platform.isIOS) {
    _getAPNSToken().then((_) => _getFCMToken());
  } else {
    _getFCMToken();
  }
}

Future<void> _getFCMToken({int retryCount = 0}) async {
  if (retryCount >= _maxRetries) {
    debugPrint('Max retries reached for FCM token. Giving up.');
    return;
  }

  try {
    String? token = await FirebaseMessaging.instance.getToken().timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        throw TimeoutException('FCM token retrieval timed out');
      },
    );
    if (token != null) {
      // debugPrint("My FCM token: $token");
      // Here you would typically send this token to your server
    }
  } catch (e) {
    debugPrint('Error getting FCM token: $e');
    _scheduleTokenRetry(_getFCMToken, retryCount + 1);
  }
}

Future<void> _getAPNSToken({int retryCount = 0}) async {
  if (retryCount >= _maxRetries) {
    debugPrint('Max retries reached for APNS token. Giving up.');
    return;
  }

  try {
    String? token = await FirebaseMessaging.instance.getAPNSToken().timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        throw TimeoutException('APNS token retrieval timed out');
      },
    );
    if (token != null) {
      // debugPrint("My APNS token: $token");
      // Here you would typically send this token to your server
    }
  } catch (e) {
    debugPrint('Error getting APNS token: $e');
    _scheduleTokenRetry(_getAPNSToken, retryCount + 1);
  }
}

void _scheduleTokenRetry(
    Future<void> Function({int retryCount}) tokenFunction, int retryCount) {
  Future.delayed(_retryDelay, () => tokenFunction(retryCount: retryCount));
}
