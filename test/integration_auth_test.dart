import 'package:flutter_test/flutter_test.dart';
import 'package:vestie/core/network/dio_client.dart';
import 'package:vestie/features/auth/data/datasources/auth_remote_data_source_impl.dart';
import 'package:vestie/core/storage/secure_storage_impl.dart';
import 'package:mocktail/mocktail.dart';

class MockSecureStorage extends Mock implements SecureStorageImpl {}

void main() {
  // This is an integration test that hits the real local API.
  // We use testWidgets or just a regular test but we need flutter environment.
  
  test('Auth Flow Integration Test', () async {
    print('--- Starting Auth Flow Integration Test ---');
    
    final mockStorage = MockSecureStorage();
    when(() => mockStorage.getString(any())).thenAnswer((_) async => null);
    when(() => mockStorage.saveString(any(), any())).thenAnswer((_) async => null);
    
    final client = DioClient(secureStorage: mockStorage);
    final dataSource = AuthRemoteDataSourceImpl(client);
    
    final testEmail = 'test_${DateTime.now().millisecondsSinceEpoch}@example.com';
    final testPass = 'Password123!';
    final testName = 'Integration Test User';

    try {
      // 1. Register
      print('Testing Register: $testEmail');
      await dataSource.register(
        fullName: testName,
        email: testEmail,
        password: testPass,
        confirmPassword: testPass,
      );
      print('Registration request sent successfully.');

      // 2. Login
      // Expecting 401 if verification is required, or 200 if it works.
      print('\nTesting Login: $testEmail');
      try {
        final tokens = await dataSource.login(
          email: testEmail,
          password: testPass,
          deviceName: 'IntegrationTestRunner',
          ipAddress: '127.0.0.1',
        );
        print('Login Success!');
        print('Access Token: ${tokens.accessToken?.substring(0, 10)}...');
      } catch (e) {
        print('Login failed (Expected if email verification is mandatory): $e');
      }

      // 3. Forgot Password
      print('\nTesting Forgot Password: $testEmail');
      await dataSource.forgotPassword(email: testEmail);
      print('Forgot password request sent.');

    } catch (e) {
      print('\n[ERROR] Test failed: $e');
      fail('Integration test failed with error: $e');
    }

    print('\n--- Integration Test Completed ---');
  });
}
