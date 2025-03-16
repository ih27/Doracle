import 'package:flutter/foundation.dart';
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
      debugPrint('Stored value for key: $key');
    } catch (e) {
      debugPrint('Error storing value for key: $key - $e');
      rethrow;
    }
  }

  /// Retrieve a value securely
  Future<String?> read({required String key}) async {
    try {
      final value = await _secureStorage.read(key: key);
      return value;
    } catch (e) {
      debugPrint('Error reading value for key: $key - $e');
      return null;
    }
  }

  /// Delete a value securely
  Future<void> delete({required String key}) async {
    try {
      await _secureStorage.delete(key: key);
      debugPrint('Deleted value for key: $key');
    } catch (e) {
      debugPrint('Error deleting value for key: $key - $e');
    }
  }

  /// Clear all values
  Future<void> deleteAll() async {
    try {
      await _secureStorage.deleteAll();
      debugPrint('Deleted all stored values');
    } catch (e) {
      debugPrint('Error deleting all values - $e');
    }
  }
}
