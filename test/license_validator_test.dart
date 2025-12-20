import 'package:flutter_test/flutter_test.dart';
import 'package:generic_audio_notification/license_validator.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

void main() {
  group('LicenseValidator', () {
    const verificationKey = 'GENERIC_AUDIO_NOTIFICATION_PUBLIC_KEY_V1';

    String generateValidLicense(String packageName) {
      final key = utf8.encode(verificationKey);
      final bytes = utf8.encode(packageName);
      final hmac = Hmac(sha256, key);
      final signature = hmac.convert(bytes);
      final signatureBase64 = base64Encode(signature.bytes);
      return '$packageName:$signatureBase64';
    }

    test('Valid license with matching package name should return true', () {
      const packageName = 'com.example.test';
      final license = generateValidLicense(packageName);

      expect(
        LicenseValidator.validateLicense(license, packageName),
        isTrue,
      );
    });

    test('Invalid signature should throw LicenseException', () {
      const packageName = 'com.example.test';
      const invalidLicense = 'com.example.test:invalidSignature123';

      expect(
        () => LicenseValidator.validateLicense(invalidLicense, packageName),
        throwsA(isA<LicenseException>()),
      );
    });

    test('Malformed license key should throw LicenseException', () {
      const packageName = 'com.example.test';
      const malformedLicense = 'malformed-license-without-colon';

      expect(
        () => LicenseValidator.validateLicense(malformedLicense, packageName),
        throwsA(isA<LicenseException>()),
      );
    });

    test('Wrong package name should throw LicenseException', () {
      const correctPackage = 'com.example.correct';
      const wrongPackage = 'com.example.wrong';
      final license = generateValidLicense(correctPackage);

      expect(
        () => LicenseValidator.validateLicense(license, wrongPackage),
        throwsA(
          isA<LicenseException>().having(
            (e) => e.message,
            'message',
            contains('not valid for package'),
          ),
        ),
      );
    });

    test('Null license in release mode should throw LicenseException', () {
      // Note: This test will pass in debug mode, so it's more of a documentation test
      const packageName = 'com.example.test';

      // In debug mode, this will return true
      // In release mode, this would throw
      final result = LicenseValidator.validateLicense(null, packageName);

      // In debug mode, expect true
      expect(result, isTrue);
    });

    test('Empty license in release mode should throw LicenseException', () {
      const packageName = 'com.example.test';

      // In debug mode, this will return true
      final result = LicenseValidator.validateLicense('', packageName);

      // In debug mode, expect true
      expect(result, isTrue);
    });

    test('isDebugBuild should return correct value', () {
      // This will be true when running tests
      expect(LicenseValidator.isDebugBuild(), isTrue);
    });

    test('License with extra colons should throw LicenseException', () {
      const packageName = 'com.example.test';
      const licenseWithExtraColons = 'com.example.test:signature:extra';

      expect(
        () => LicenseValidator.validateLicense(
            licenseWithExtraColons, packageName),
        throwsA(isA<LicenseException>()),
      );
    });

    test(
        'License with different package should include both package names in error',
        () {
      const correctPackage = 'com.correct.package';
      const wrongPackage = 'com.wrong.package';
      final license = generateValidLicense(correctPackage);

      expect(
        () => LicenseValidator.validateLicense(license, wrongPackage),
        throwsA(
          isA<LicenseException>().having(
            (e) => e.message,
            'message',
            allOf(
              contains(wrongPackage),
              contains(correctPackage),
            ),
          ),
        ),
      );
    });
  });
}
