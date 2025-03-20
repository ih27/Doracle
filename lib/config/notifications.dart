import 'dart:async' show TimeoutException;
import 'dart:io' show Platform;
import 'package:eraser/eraser.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

const int _maxRetries = 3;
const Duration _retryDelay = Duration(minutes: 15);

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  //await Firebase.initializeApp();

  // Handle background message
  // Message ID: ${message.messageId}
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
    // FCM token refresh callback
  }).onError((err) {
    // Error occurred during token refresh
  });

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    // Handle foreground message
    // Message data available in message.data
    if (message.notification != null) {
      // Notification payload available
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

void cleanUpNotifications() {
  Eraser.clearAllAppNotifications();
  Eraser.resetBadgeCountAndRemoveNotificationsFromCenter();
}

Future<void> _getFCMToken({int retryCount = 0}) async {
  if (retryCount >= _maxRetries) {
    // Maximum retries reached for FCM token
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
      // Token retrieved successfully
      // Here you would typically send this token to your server
    }
  } catch (e) {
    // Error occurred while getting FCM token
    _scheduleTokenRetry(_getFCMToken, retryCount + 1);
  }
}

Future<void> _getAPNSToken({int retryCount = 0}) async {
  if (retryCount >= _maxRetries) {
    // Maximum retries reached for APNS token
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
      // Token retrieved successfully
      // Here you would typically send this token to your server
    }
  } catch (e) {
    // Error occurred while getting APNS token
    _scheduleTokenRetry(_getAPNSToken, retryCount + 1);
  }
}

void _scheduleTokenRetry(
    Future<void> Function({int retryCount}) tokenFunction, int retryCount) {
  Future.delayed(_retryDelay, () => tokenFunction(retryCount: retryCount));
}
