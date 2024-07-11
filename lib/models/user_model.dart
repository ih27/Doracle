import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class AppUser extends ChangeNotifier {
  String id;
  String email;
  int remainingQuestionsCount;
  int totalQuestionsAsked;
  List<Map<String, dynamic>> questionHistory;
  List<Map<String, dynamic>> purchaseHistory;
  bool canVibrate;
  static const _remainingQuestionsCount = 50;
  static const _totalQuestionsAsked = 0;
  dynamic lastQuestionTimestamp;
  dynamic lastPurchaseTimestamp;

  AppUser({
    required this.id,
    required this.email,
    this.canVibrate = false,
    this.remainingQuestionsCount = _remainingQuestionsCount,
    this.totalQuestionsAsked = _totalQuestionsAsked,
    this.questionHistory = const [],
    this.purchaseHistory = const [],
    this.lastQuestionTimestamp,
    this.lastPurchaseTimestamp,
  });

  void updateField<T>(String fieldName, T value) {
    switch (fieldName) {
      case 'remainingQuestionsCount':
        remainingQuestionsCount = value as int;
        break;
      case 'totalQuestionsAsked':
        totalQuestionsAsked = value as int;
        break;
      case 'email':
        email = value as String;
        break;
      case 'canVibrate':
        canVibrate = value as bool;
        break;
    }
    notifyListeners();
  }

  void addQuestionToHistory(Map<String, dynamic> question) {
    questionHistory.add(question);
    totalQuestionsAsked++;
    remainingQuestionsCount--;
    lastQuestionTimestamp = FieldValue.serverTimestamp();
    notifyListeners();
  }

  void addPurchaseToHistory(Map<String, dynamic> purchase) {
    purchaseHistory.add(purchase);
    remainingQuestionsCount += purchase['questionCount'] as int;
    lastPurchaseTimestamp = FieldValue.serverTimestamp();
    notifyListeners();
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'canVibrate': canVibrate,
      'remainingQuestionsCount': remainingQuestionsCount,
      'totalQuestionsAsked': totalQuestionsAsked,
      'questionHistory': questionHistory,
      'purchaseHistory': purchaseHistory,
      'lastQuestionTimestamp': lastQuestionTimestamp,
      'lastPurchaseTimestamp': lastPurchaseTimestamp,
    };
  }

  static AppUser fromMap(Map<String, dynamic> map) {
    return AppUser(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      canVibrate: map['canVibrate'] ?? false,
      remainingQuestionsCount:
          map['remainingQuestionsCount'] ?? _remainingQuestionsCount,
      totalQuestionsAsked: map['totalQuestionsAsked'] ?? _totalQuestionsAsked,
      questionHistory:
          List<Map<String, dynamic>>.from(map['questionHistory'] ?? []),
      purchaseHistory:
          List<Map<String, dynamic>>.from(map['purchaseHistory'] ?? []),
      lastQuestionTimestamp: map['lastQuestionTimestamp'],
      lastPurchaseTimestamp: map['lastPurchaseTimestamp'],
    );
  }

  // Helper method to get the timestamp as DateTime
  DateTime? getLastQuestionTimestamp() {
    if (lastQuestionTimestamp is Timestamp) {
      return (lastQuestionTimestamp as Timestamp).toDate();
    }
    return null;
  }

  DateTime? getLastPurchaseTimestamp() {
    if (lastPurchaseTimestamp is Timestamp) {
      return (lastPurchaseTimestamp as Timestamp).toDate();
    }
    return null;
  }
}
