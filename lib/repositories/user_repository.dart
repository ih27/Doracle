import 'package:firebase_auth/firebase_auth.dart';

abstract class UserRepository {
  Future<void> addUser(User user, Map<String, dynamic> userData);
  Future<Map<String, dynamic>?> getUser(String userId);
  Future<void> updateUserFortuneData(String userId, String question, String persona);
  Future<void> updateUserField<T>(String userId, String field, T value);
}
