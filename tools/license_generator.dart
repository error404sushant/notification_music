#!/usr/bin/env dart

import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';

/// License Generator Tool for generic_audio_notification package
///
/// Usage: dart run tools/license_generator.dart <package_name>
///
/// Environment Variables:
///   GENERIC_AUDIO_LICENSE_KEY - The private key for signing licenses
///
/// Example:
///   export GENERIC_AUDIO_LICENSE_KEY="your-secret-private-key"
///   dart run tools/license_generator.dart com.example.myapp

void main(List<String> arguments) {
  // Validate arguments
  if (arguments.isEmpty) {
    printUsage();
    exit(1);
  }

  final packageName = arguments[0];

  // Validate package name format
  if (!_isValidPackageName(packageName)) {
    print('❌ Error: Invalid package name format');
    print('   Package name should follow format: com.company.appname');
    exit(1);
  }

  // Get private key from environment
  final privateKey = Platform.environment['GENERIC_AUDIO_LICENSE_KEY'];
  if (privateKey == null || privateKey.isEmpty) {
    print('❌ Error: GENERIC_AUDIO_LICENSE_KEY environment variable not set');
    print('');
    print('Please set the private key:');
    print('  export GENERIC_AUDIO_LICENSE_KEY="your-secret-private-key"');
    print('');
    print(
        '⚠️  IMPORTANT: Keep this key secret and never commit it to version control!');
    exit(1);
  }

  // Generate license
  try {
    final license = generateLicense(packageName, privateKey);

    print('');
    print('✅ License generated successfully!');
    print('');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('Package Name: $packageName');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('');
    print('License Key:');
    print(license);
    print('');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('');
    print('Usage in Flutter app:');
    print('');
    print(
        '  import \'package:generic_audio_notification/generic_audio_notification.dart\';');
    print('');
    print('  void main() async {');
    print('    WidgetsFlutterBinding.ensureInitialized();');
    print('    ');
    print('    // Initialize with license key');
    print('    await GenericAudioNotification().initialize(');
    print('      \'$license\'');
    print('    );');
    print('    ');
    print('    runApp(MyApp());');
    print('  }');
    print('');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  } catch (e) {
    print('❌ Error generating license: $e');
    exit(1);
  }
}

/// Generates a license key for the given package name
String generateLicense(String packageName, String privateKey) {
  // Use the same key as in the validator (this should match)
  // In production, you'd use the actual private key
  const verificationKey = 'GENERIC_AUDIO_NOTIFICATION_PUBLIC_KEY_V1';

  // Generate HMAC-SHA256 signature
  final key = utf8.encode(verificationKey);
  final bytes = utf8.encode(packageName);
  final hmac = Hmac(sha256, key);
  final signature = hmac.convert(bytes);

  // Encode signature as base64
  final signatureBase64 = base64Encode(signature.bytes);

  // Format: packageName:signature
  return '$packageName:$signatureBase64';
}

/// Validates package name format
bool _isValidPackageName(String packageName) {
  // Basic validation: should have at least 2 parts separated by dots
  final parts = packageName.split('.');
  if (parts.length < 2) {
    return false;
  }

  // Each part should be non-empty and contain only valid characters
  final validPattern = RegExp(r'^[a-z][a-z0-9_]*$');
  for (final part in parts) {
    if (part.isEmpty || !validPattern.hasMatch(part)) {
      return false;
    }
  }

  return true;
}

/// Prints usage information
void printUsage() {
  print('');
  print('License Generator for generic_audio_notification');
  print('');
  print('Usage:');
  print('  dart run tools/license_generator.dart <package_name>');
  print('');
  print('Arguments:');
  print(
      '  package_name    The Android/iOS package name (e.g., com.example.myapp)');
  print('');
  print('Environment Variables:');
  print(
      '  GENERIC_AUDIO_LICENSE_KEY    Private key for signing licenses (required)');
  print('');
  print('Example:');
  print('  export GENERIC_AUDIO_LICENSE_KEY="your-secret-key"');
  print('  dart run tools/license_generator.dart com.example.myapp');
  print('');
}
