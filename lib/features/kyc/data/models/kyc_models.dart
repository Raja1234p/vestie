import 'package:vestie/core/utils/safe_parser.dart';
import 'package:vestie/features/kyc/domain/entities/kyc_status_entity.dart';

class KycStatusModel extends KycStatusEntity {
  const KycStatusModel({
    required super.status,
    super.stripeConnectAccountId,
    super.chargesEnabled,
    super.payoutsEnabled,
    super.requirementsCurrentlyDue,
  });

  factory KycStatusModel.fromJson(Map<String, dynamic> json) {
    final due =
        (json['requirementsCurrentlyDue'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList(growable: false) ??
        const <String>[];

    return KycStatusModel(
      status: kycStatusFromApi(json.safeString('status')),
      stripeConnectAccountId: json.safeStringNullable('stripeConnectAccountId'),
      chargesEnabled: json.safeBool('chargesEnabled'),
      payoutsEnabled: json.safeBool('payoutsEnabled'),
      requirementsCurrentlyDue: due,
    );
  }
}

class KycStartResultModel extends KycStartResultEntity {
  const KycStartResultModel({
    required super.status,
    super.onboardingUrl,
    super.onboardingExpiresAt,
  });

  factory KycStartResultModel.fromJson(Map<String, dynamic> json) {
    return KycStartResultModel(
      status: kycStatusFromApi(
        json.safeString('status', defaultValue: 'Pending'),
      ),
      onboardingUrl: json.safeStringNullable('onboardingUrl'),
      onboardingExpiresAt: _parseDate(json['onboardingExpiresAt']),
    );
  }
}

DateTime? _parseDate(dynamic raw) {
  if (raw == null) return null;
  return DateTime.tryParse(raw.toString());
}
