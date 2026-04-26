import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/foundation.dart';
import 'package:vestie/core/network/dio_client.dart';
import 'package:vestie/features/auth/data/datasources/auth_remote_data_source_impl.dart';
import 'package:vestie/core/storage/secure_storage_impl.dart';
import 'package:mocktail/mocktail.dart';

class MockSecureStorage extends Mock implements SecureStorageImpl {}

void main() {
  // This is an integration test that hits the real local API.
  // We use testWidgets or just a regular test but we need flutter environment.
  
  test('Auth Flow Integration Test', () async {
    debugPrint('--- Starting Auth Flow Integration Test ---');
    
    final mockStorage = MockSecureStorage();
    when(() => mockStorage.getString(any())).thenAnswer((_) async => null);
    when(() => mockStorage.saveString(any(), any())).thenAnswer((_) async {});
    
    final client = DioClient(secureStorage: mockStorage);
    final dataSource = AuthRemoteDataSourceImpl(client);
    
    final testEmail = 'test_${DateTime.now().millisecondsSinceEpoch}@example.com';
    final testPass = 'Password123!';
    final testName = 'Integration Test User';

    try {
      // 1. Register
      debugPrint('Testing Register: $testEmail');
      await dataSource.register(
        fullName: testName,
        email: testEmail,
        password: testPass,
        confirmPassword: testPass,
      );
      debugPrint('Registration request sent successfully.');

      // 2. Login
      // Expecting 401 if verification is required, or 200 if it works.
      debugPrint('\nTesting Login: $testEmail');
      try {
        final tokens = await dataSource.login(
          email: testEmail,
          password: testPass,
          deviceName: 'IntegrationTestRunner',
          ipAddress: '127.0.0.1',
        );
        debugPrint('Login Success!');
        debugPrint('Access Token: ${tokens.accessToken?.substring(0, 10)}...');
      } catch (e) {
        debugPrint('Login failed (Expected if email verification is mandatory): $e');
      }

      // 3. Forgot Password
      debugPrint('\nTesting Forgot Password: $testEmail');
      await dataSource.forgotPassword(email: testEmail);
      debugPrint('Forgot password request sent.');

    } catch (e) {
      debugPrint('\n[ERROR] Test failed: $e');
      fail('Integration test failed with error: $e');
    }

    debugPrint('\n--- Integration Test Completed ---');
  });
}
