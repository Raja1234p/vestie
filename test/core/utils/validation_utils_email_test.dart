import 'package:flutter_test/flutter_test.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/utils/validation_utils.dart';
import 'package:vestie/core/utils/validators.dart';

void main() {
  group('ValidationUtils.validateEmail', () {
    group('single-domain (valid)', () {
      const emails = [
        'user@gmail.com',
        'test.user@example.com',
        'name+tag@company.com',
        'a@b.co',
      ];

      for (final email in emails) {
        test('accepts $email', () {
          expect(ValidationUtils.validateEmail(email), isNull);
        });
      }
    });

    group('multi-domain (valid)', () {
      const emails = [
        'tdyyzbr9zb@privaterelay.appleid.com',
        'user@mail.company.com',
        'alice@sub.domain.example.org',
        'test@company.co.uk',
      ];

      for (final email in emails) {
        test('accepts $email', () {
          expect(ValidationUtils.validateEmail(email), isNull);
        });
      }
    });

    group('invalid', () {
      test('empty shows required', () {
        expect(
          ValidationUtils.validateEmail(''),
          AppStrings.errorEmailRequired,
        );
      });

      test('whitespace-only shows required', () {
        expect(
          ValidationUtils.validateEmail('   '),
          AppStrings.errorEmailRequired,
        );
      });

      const invalidEmails = [
        'plainaddress',
        'missing-at-sign.com',
        '@nodomain.com',
        'user@',
        'user@domain',
        'user@.com',
        'user@domain.c',
        'user@domain..com',
      ];

      for (final email in invalidEmails) {
        test('rejects $email', () {
          expect(
            ValidationUtils.validateEmail(email),
            AppStrings.errorEmailInvalid,
          );
        });
      }
    });

    test('trimmed before validation', () {
      expect(
        ValidationUtils.validateEmail('  user@gmail.com  '),
        isNull,
      );
      expect(
        ValidationUtils.validateEmail('  tdyyzbr9zb@privaterelay.appleid.com  '),
        isNull,
      );
    });
  });

  group('Validators.validateEmail delegates to ValidationUtils', () {
    test('accepts Apple Private Relay email', () {
      expect(
        Validators.validateEmail('tdyyzbr9zb@privaterelay.appleid.com'),
        isNull,
      );
    });

    test('accepts single-domain email', () {
      expect(Validators.validateEmail('user@gmail.com'), isNull);
    });

    test('rejects invalid email', () {
      expect(
        Validators.validateEmail('not-an-email'),
        AppStrings.errorEmailInvalid,
      );
    });
  });
}
