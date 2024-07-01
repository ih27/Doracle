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

  Future<void> updateUserFortuneData(String question) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await _userRepository.updateUserFortuneData(user.uid, question);
    }
  }  
}