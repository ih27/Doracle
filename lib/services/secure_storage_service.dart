import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Service for securely storing and retrieving data using flutter_secure_storage
///
/// This centralized service should be used throughout the app when secure storage
/// is needed, rather than creating multiple instances of FlutterSecureStorage.
///
/// Usage example:
/// ```dart
/// final secureStorage = getIt<SecureStorageService>();
///
/// // Store a value
/// await secureStorage.write(key: 'my_key', value: 'my_value');
///
/// // Read a value
/// final value = await secureStorage.read(key: 'my_key');
///
/// // Delete a value
/// await secureStorage.delete(key: 'my_key');
/// ```
class SecureStorageService {
  final FlutterSecureStorage _secureStorage;

  /// Create a new SecureStorageService with the given storage options
  SecureStorageService({
    AndroidOptions? androidOptions,
    IOSOptions? iosOptions,
  }) : _secureStorage = FlutterSecureStorage(
          aOptions: androidOptions ?? const AndroidOptions(),
          iOptions: iosOptions ?? const IOSOptions(),
        );

  /// Store a value securely
  Future<void> write({required String key, required String? value}) async {
    try {
      await _secureStorage.write(key: key, value: value);
    } catch (e) {
      rethrow;
    }
  }

  /// Retrieve a value securely
  Future<String?> read({required String key}) async {
    try {
      final value = await _secureStorage.read(key: key);
      return value;
    } catch (e) {
      return null;
    }
  }

  /// Delete a value securely
  Future<void> delete({required String key}) async {
    try {
      await _secureStorage.delete(key: key);
    } catch (e) {
      // Error deleting value
    }
  }

  /// Clear all values
  Future<void> deleteAll() async {
    try {
      await _secureStorage.deleteAll();
    } catch (e) {
      // Error deleting all values
    }
  }
}
