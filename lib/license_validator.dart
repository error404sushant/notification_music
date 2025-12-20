import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';

/// Exception thrown when license validation fails
class LicenseException implements Exception {
  final String message;

  LicenseException(this.message);

  @override
  String toString() => 'LicenseException: $message';
}

/// Validates license keys for the generic_audio_notification package
class LicenseValidator {
  // This is the public verification key - the private key is kept secret
  // and used only for generating licenses
  static const String _verificationKey =
      'GENERIC_AUDIO_NOTIFICATION_PUBLIC_KEY_V1';

  /// Validates a license key for the given package name
  ///
  /// Returns true if the license is valid, false otherwise.
  /// In debug mode, always returns true without validation.
  ///
  /// License format: packageName:base64(hmac_signature)
  static bool validateLicense(String? licenseKey, String packageName) {
    // Skip validation in debug mode
    if (kDebugMode) {
      debugPrint(
          'GenericAudioNotification: Debug mode - skipping license validation');
      return true;
    }

    // License is required in release mode
    if (licenseKey == null || licenseKey.isEmpty) {
      throw LicenseException('License key is required for release builds');
    }

    try {
      // Parse license key format: packageName:signature
      final parts = licenseKey.split(':');
      if (parts.length != 2) {
        throw LicenseException('Invalid license key format');
      }

      final licensedPackage = parts[0];
      final signature = parts[1];

      // Verify package name matches
      if (licensedPackage != packageName) {
        throw LicenseException(
            'License is not valid for package "$packageName". '
            'This license is for "$licensedPackage"');
      }

      // Verify signature
      if (!_verifySignature(packageName, signature)) {
        throw LicenseException('License signature verification failed');
      }

      debugPrint(
          'GenericAudioNotification: License validated successfully for $packageName');
      return true;
    } catch (e) {
      if (e is LicenseException) {
        rethrow;
      }
      throw LicenseException('License validation error: ${e.toString()}');
    }
  }

  /// Verifies the HMAC-SHA256 signature
  static bool _verifySignature(String packageName, String signature) {
    try {
      // Decode the signature from base64
      final providedSignature = base64Decode(signature);

      // Generate expected signature
      final key = utf8.encode(_verificationKey);
      final bytes = utf8.encode(packageName);
      final hmac = Hmac(sha256, key);
      final expectedSignature = hmac.convert(bytes);

      // Compare signatures (constant-time comparison to prevent timing attacks)
      if (providedSignature.length != expectedSignature.bytes.length) {
        return false;
      }

      var result = 0;
      for (var i = 0; i < providedSignature.length; i++) {
        result |= providedSignature[i] ^ expectedSignature.bytes[i];
      }

      return result == 0;
    } catch (e) {
      debugPrint(
          'GenericAudioNotification: Signature verification failed - $e');
      return false;
    }
  }

  /// Checks if the current build is a debug build
  static bool isDebugBuild() {
    return kDebugMode;
  }
}
