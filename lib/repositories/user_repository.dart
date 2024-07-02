abstract class UserRepository {
  Future<void> addUser(String userId, Map<String, dynamic> userData);
  Future<Map<String, dynamic>?> getUser(String userId);
  Future<void> updateUserFortuneData(String userId, String question, String persona);
  Future<void> updateUserField<T>(String userId, String field, T value);
}
