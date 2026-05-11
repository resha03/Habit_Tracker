import 'package:encrypt/encrypt.dart' as encrypt;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecurityService {
  static final SecurityService _instance = SecurityService._internal();

  factory SecurityService() {
    return _instance;
  }

  SecurityService._internal();

  late encrypt.Key _key;
  late encrypt.IV _iv;
  final _secureStorage = const FlutterSecureStorage();

  /// Initialize encryption key
  Future<void> initializeEncryption() async {
    try {
      final storedKey = await _secureStorage.read(key: 'encryption_key');
      if (storedKey != null) {
        _key = encrypt.Key.fromBase64(storedKey);
      } else {
        _key = encrypt.Key.fromSecureRandom(32);
        await _secureStorage.write(
          key: 'encryption_key',
          value: _key.base64,
        );
      }

      final storedIV = await _secureStorage.read(key: 'encryption_iv');
      if (storedIV != null) {
        _iv = encrypt.IV.fromBase64(storedIV);
      } else {
        _iv = encrypt.IV.fromSecureRandom(16);
        await _secureStorage.write(
          key: 'encryption_iv',
          value: _iv.base64,
        );
      }
    } catch (e) {
      throw SecurityException('Failed to initialize encryption: $e');
    }
  }

  /// Encrypt data
  String encryptData(String plaintext) {
    try {
      final encrypter = encrypt.Encrypter(encrypt.AES(_key));
      final encrypted = encrypter.encrypt(plaintext, iv: _iv);
      return encrypted.base64;
    } catch (e) {
      throw SecurityException('Encryption failed: $e');
    }
  }

  /// Decrypt data
  String decryptData(String encryptedData) {
    try {
      final encrypter = encrypt.Encrypter(encrypt.AES(_key));
      final decrypted =
          encrypter.decrypt64(encryptedData, iv: _iv);
      return decrypted;
    } catch (e) {
      throw SecurityException('Decryption failed: $e');
    }
  }

  /// Encrypt JSON
  String encryptJson(Map<String, dynamic> json) {
    final jsonString = jsonEncode(json);
    return encryptData(jsonString);
  }

  /// Decrypt JSON
  Map<String, dynamic> decryptJson(String encryptedJson) {
    final jsonString = decryptData(encryptedJson);
    return jsonDecode(jsonString) as Map<String, dynamic>;
  }

  /// Store sensitive data securely
  Future<void> storeSensitiveData(String key, String value) async {
    final encrypted = encryptData(value);
    await _secureStorage.write(key: key, value: encrypted);
  }

  /// Retrieve sensitive data
  Future<String?> getSensitiveData(String key) async {
    final encrypted = await _secureStorage.read(key: key);
    if (encrypted == null) return null;
    return decryptData(encrypted);
  }

  /// Delete sensitive data
  Future<void> deleteSensitiveData(String key) async {
    await _secureStorage.delete(key: key);
  }

  /// Clear all secure storage
  Future<void> clearSecureStorage() async {
    await _secureStorage.deleteAll();
  }
}

class SecurityException implements Exception {
  final String message;
  SecurityException(this.message);

  @override
  String toString() => 'SecurityException: $message';
}
