import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class AuthService {
  static final LocalAuthentication _localAuth = LocalAuthentication();
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  // Check if biometric authentication is available
  static Future<bool> isBiometricAvailable() async {
    try {
      final bool isAvailable = await _localAuth.canCheckBiometrics;
      final bool isDeviceSupported = await _localAuth.isDeviceSupported();
      return isAvailable && isDeviceSupported;
    } catch (e) {
      return false;
    }
  }

  // Get available biometric types
  static Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      return [];
    }
  }

  // Authenticate with biometrics
  static Future<bool> authenticateWithBiometrics({
    String reason = 'Please authenticate to access your finance data',
  }) async {
    try {
      final bool isAuthenticated = await _localAuth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
          useErrorDialogs: true,
        ),
      );
      return isAuthenticated;
    } on PlatformException catch (e) {
      print('Biometric authentication error: $e');
      return false;
    }
  }

  // Store encrypted user data
  static Future<void> storeSecureData(String key, String value) async {
    try {
      final encryptedValue = _encryptData(value);
      await _secureStorage.write(key: key, value: encryptedValue);
    } catch (e) {
      print('Error storing secure data: $e');
    }
  }

  // Retrieve encrypted user data
  static Future<String?> getSecureData(String key) async {
    try {
      final encryptedValue = await _secureStorage.read(key: key);
      if (encryptedValue != null) {
        return _decryptData(encryptedValue);
      }
      return null;
    } catch (e) {
      print('Error retrieving secure data: $e');
      return null;
    }
  }

  // Delete secure data
  static Future<void> deleteSecureData(String key) async {
    try {
      await _secureStorage.delete(key: key);
    } catch (e) {
      print('Error deleting secure data: $e');
    }
  }

  // Clear all secure data
  static Future<void> clearAllSecureData() async {
    try {
      await _secureStorage.deleteAll();
    } catch (e) {
      print('Error clearing secure data: $e');
    }
  }

  // Simple encryption for additional security
  static String _encryptData(String data) {
    final bytes = utf8.encode(data);
    return base64.encode(bytes); // Simple base64 encoding
  }

  // Simple decryption
  static String _decryptData(String encryptedData) {
    final bytes = base64.decode(encryptedData);
    return utf8.decode(bytes);
  }

  // Check if user has set up authentication
  static Future<bool> hasAuthenticationSetup() async {
    final authSetup = await getSecureData('auth_setup');
    return authSetup == 'true';
  }

  // Mark authentication as set up
  static Future<void> setAuthenticationSetup(bool isSetup) async {
    await storeSecureData('auth_setup', isSetup.toString());
  }

  // Store user financial pin (hashed)
  static Future<void> storeFinancialPin(String pin) async {
    final hashedPin = sha256.convert(utf8.encode(pin)).toString();
    await storeSecureData('financial_pin', hashedPin);
  }

  // Verify financial pin
  static Future<bool> verifyFinancialPin(String pin) async {
    try {
      final storedHash = await getSecureData('financial_pin');
      if (storedHash == null) return false;

      final inputHash = sha256.convert(utf8.encode(pin)).toString();
      return storedHash == inputHash;
    } catch (e) {
      return false;
    }
  }

  // Check if financial pin is set
  static Future<bool> hasFinancialPin() async {
    final pin = await getSecureData('financial_pin');
    return pin != null;
  }
}
