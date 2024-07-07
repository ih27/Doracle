import '../models/user_model.dart';
import '../repositories/user_repository.dart';
import 'package:flutter/foundation.dart';

class UserService extends ValueNotifier<AppUser?> {
  final UserRepository _userRepository;

  UserService(this._userRepository) : super(null);

  Future<void> loadCurrentUser(String userId) async {
    debugPrint('loadCurrentUser called with userId: $userId');
    final userData = await _userRepository.getUser(userId);
    if (userData != null) {
      try {
        value = AppUser.fromMap({...userData, 'id': userId});
        notifyListeners();
      } catch (e) {
        debugPrint('Error creating AppUser: $e');
        // Handle the error, maybe set a default user or leave value as null
      }
    } else {
      debugPrint('No user data found for userId: $userId');
    }
  }

  Future<void> addUser(String userId, Map<String, dynamic> userData) async {
    await _userRepository.addUser(userId, userData);
    await loadCurrentUser(userId);
  }

  Future<void> updateUserFortuneData(String question, String persona) async {
    if (value != null) {
      value!.addQuestionToHistory({
        'question': question,
        'persona': persona,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
      await _userRepository.updateUser(value!.id, value!.toMap());
      notifyListeners();
    }
  }

  Future<void> updatePurchaseHistory(int questionCount) async {
    if (value != null) {
      value!.addPurchaseToHistory({
        'questionCount': questionCount,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
      await _userRepository.updateUser(value!.id, value!.toMap());
      notifyListeners();
    }
  }

  Future<void> updateUserField<T>(String fieldName, T fieldValue) async {
    if (value != null) {
      debugPrint("Updating $fieldName to $fieldValue");
      await _userRepository.updateUser(value!.id, {fieldName: fieldValue});
      value!.updateField(fieldName, fieldValue);
      notifyListeners();
    }
  }

  int getRemainingQuestionsCount() {
    return value?.remainingQuestionsCount ?? 0;
  }
}
