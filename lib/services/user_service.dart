import 'package:firebase_auth/firebase_auth.dart';
import '../repositories/user_repository.dart';

class UserService {
  final UserRepository _userRepository;

  UserService(this._userRepository);

  Future<void> addUser(User user, Map<String, dynamic> userData) async {
    await _userRepository.addUser(user, userData);
  }

  Future<Map<String, dynamic>?> getUser(String userId) async {
    return await _userRepository.getUser(userId);
  }

  Future<void> updateUserFortuneData(String question, String persona) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await _userRepository.updateUserFortuneData(user.uid, question, persona);
    }
  }

  Future<T?> getUserField<T>(String field) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userData = await getUser(user.uid);
      return userData?[field] as T?;
    }
    return null;
  }

  Future<void> updateUserField<T>(String field, T value) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await _userRepository.updateUserField(user.uid, field, value);
    }
  }

  Future<Map<String, dynamic>?> getCurrentUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return await getUser(user.uid);
    }
    return null;
  }
}