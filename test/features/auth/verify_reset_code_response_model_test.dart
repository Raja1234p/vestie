import 'package:flutter_test/flutter_test.dart';
import 'package:vestie/features/auth/data/models/verify_reset_code_response_model.dart';

void main() {
  group('VerifyResetCodeResponseModel', () {
    test('fromJson parses userId and message', () {
      const json = {
        'userId': '3fa85f64-5717-4562-b3fc-2c963f66afa6',
        'message': 'Reset code verified. You may set a new password.',
      };

      final model = VerifyResetCodeResponseModel.fromJson(json);

      expect(model.userId, json['userId']);
      expect(model.message, json['message']);
    });

    test('fromJson defaults missing fields to empty strings', () {
      final model = VerifyResetCodeResponseModel.fromJson({});

      expect(model.userId, '');
      expect(model.message, '');
    });
  });
}
