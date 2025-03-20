import 'package:flutter/foundation.dart';
import '../providers/entitlement_provider.dart';
import 'haptic_service.dart';
import '../config/dependency_injection.dart';
import '../models/user_model.dart';
import '../repositories/user_repository.dart';

class UserService extends ValueNotifier<AppUser?> {
  final UserRepository _userRepository;
  final HapticService _hapticService = getIt<HapticService>();
  final EntitlementProvider _entitlementProvider = getIt<EntitlementProvider>();

  UserService(this._userRepository) : super(null) {
    _entitlementProvider.addListener(_onEntitlementChanged);
  }

  bool get isEntitled => _entitlementProvider.isEntitled;

  void _onEntitlementChanged() {
    if (value != null && value!.isEntitled != isEntitled) {
      value!.isEntitled = isEntitled;
      _updateUserEntitlementStatus();
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _entitlementProvider.removeListener(_onEntitlementChanged);
    super.dispose();
  }

  Future<void> loadCurrentUser(String userId) async {
    final userData = await _userRepository.getUser(userId);

    // Get the current device capability
    bool currentCanVibrate = await _hapticService.getCanVibrate();

    if (userData != null) {
      try {
        value = AppUser.fromMap(
            {...userData, 'id': userId, 'canVibrate': currentCanVibrate});

        // Update Firestore if the canVibrate status has changed
        if (userData['canVibrate'] != currentCanVibrate) {
          await updateUserField('canVibrate', currentCanVibrate);
        }

        // Update the isEntitled status based on the EntitlementProvider
        if (value!.isEntitled != isEntitled) {
          value!.isEntitled = isEntitled;
          await _updateUserEntitlementStatus();
        }

        notifyListeners();
      } catch (e) {
        // Error creating AppUser
      }
    } else {
      // No existing user data, create new user with current canVibrate status
      value = AppUser(
        id: userId,
        email: '', // You might want to get this from Firebase Auth
        canVibrate: currentCanVibrate,
        isEntitled: isEntitled,
      );
      await _userRepository.addUser(userId, value!.toMap());
      notifyListeners();
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
      if (!isEntitled) {
        value!.remainingQuestionsCount--;
      }
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

  Future<void> updateSubscriptionHistory(String subscriptionType) async {
    if (value != null) {
      value!.addSubscriptionToHistory({
        'subscriptionType': subscriptionType,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
      value!.isEntitled = true;
      await _userRepository.updateUser(value!.id, value!.toMap());
      notifyListeners();
    }
  }

  Future<void> _updateUserEntitlementStatus() async {
    if (value != null) {
      await _userRepository
          .updateUser(value!.id, {'isEntitled': value!.isEntitled});
      notifyListeners();
    }
  }

  Future<void> updateUserField<T>(String fieldName, T fieldValue) async {
    if (value != null) {
      await _userRepository.updateUser(value!.id, {fieldName: fieldValue});
      value!.updateField(fieldName, fieldValue);
      notifyListeners();
    }
  }

  int getRemainingQuestionsCount() {
    return value?.remainingQuestionsCount ?? 0;
  }

  bool hasRunOutOfQuestions() {
    return value?.remainingQuestionsCount == 0;
  }
}
