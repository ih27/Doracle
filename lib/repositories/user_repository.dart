abstract class UserRepository {
  Future<void> addUser(String userId, Map<String, dynamic> userData);
  Future<Map<String, dynamic>?> getUser(String userId);
  Future<void> updateUser(String userId, Map<String, dynamic> userData);
}