// import 'package:vestie/core/network/dio_client.dart';
// import 'package:vestie/core/storage/secure_storage_impl.dart';
// import 'package:vestie/features/auth/data/datasources/auth_remote_data_source_impl.dart';
// import 'package:vestie/core/constants/api_constants.dart';
// import 'dart:io';
//
// void main() async {
//   print('--- Starting Auth Flow Integration Test ---');
//
//   // 1. Setup
//   final storage = SecureStorageImpl();
//   final client = DioClient(secureStorage: storage);
//   final dataSource = AuthRemoteDataSourceImpl(client);
//
//   final testEmail = 'test_${DateTime.now().millisecondsSinceEpoch}@example.com';
//   final testPass = 'Password123!';
//   final testName = 'Integration Test User';
//
//   try {
//     // 2. Register
//     print('Testing Register: $testEmail');
//     await dataSource.register(
//       fullName: testName,
//       email: testEmail,
//       password: testPass,
//       confirmPassword: testPass,
//     );
//     print('Registration request sent successfully.');
//
//     // 3. Login (Note: On real systems, you might need to verify email first)
//     // However, some dev APIs allow login immediately or have a master code.
//     // If it fails with 401, it's expected if verification is required.
//     print('\nTesting Login: $testEmail');
//     try {
//       final tokens = await dataSource.login(
//         email: testEmail,
//         password: testPass,
//         deviceName: 'IntegrationTestRunner',
//         ipAddress: '127.0.0.1',
//       );
//       print('Login Success!');
//       print('Access Token: ${tokens.accessToken.substring(0, 10)}...');
//     } catch (e) {
//       print('Login failed (Expected if email verification is mandatory): $e');
//     }
//
//     // 4. Forgot Password
//     print('\nTesting Forgot Password: $testEmail');
//     await dataSource.forgotPassword(email: testEmail);
//     print('Forgot password request sent.');
//
//   } catch (e) {
//     print('\n[ERROR] Test failed: $e');
//     exit(1);
//   }
//
//   print('\n--- Integration Test Completed ---');
// }
