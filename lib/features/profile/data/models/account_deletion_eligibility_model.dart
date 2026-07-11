import '../../domain/entities/account_deletion_eligibility_entity.dart';

class AccountDeletionEligibilityModel {
  final bool isEligible;
  final List<String> reasons;

  const AccountDeletionEligibilityModel({
    required this.isEligible,
    this.reasons = const [],
  });

  factory AccountDeletionEligibilityModel.fromJson(Map<String, dynamic> json) {
    final eligible = _parseEligible(json);
    return AccountDeletionEligibilityModel(
      isEligible: eligible,
      reasons: eligible ? const [] : _parseReasons(json),
    );
  }

  AccountDeletionEligibilityEntity toEntity() => AccountDeletionEligibilityEntity(
    isEligible: isEligible,
    reasons: reasons,
  );

  static bool _parseEligible(Map<String, dynamic> json) {
    for (final key in const ['eligible', 'isEligible', 'canDelete', 'deletionAllowed']) {
      final value = json[key];
      if (value is bool) return value;
    }
    return false;
  }

  static List<String> _parseReasons(Map<String, dynamic> json) {
    final reasons = json['reasons'];
    if (reasons is List && reasons.isNotEmpty) {
      return reasons
          .map((e) => e?.toString().trim() ?? '')
          .where((message) => message.isNotEmpty)
          .toList(growable: false);
    }

    for (final key in const ['reason', 'message', 'detail', 'title']) {
      final value = json[key];
      if (value is String && value.trim().isNotEmpty) {
        return [value.trim()];
      }
    }

    final blockers = json['blockers'];
    if (blockers is List && blockers.isNotEmpty) {
      return blockers
          .map((e) {
            if (e is Map) {
              final msg = e['message'] ?? e['reason'] ?? e['description'];
              if (msg is String && msg.trim().isNotEmpty) return msg.trim();
            }
            return e?.toString().trim() ?? '';
          })
          .where((message) => message.isNotEmpty)
          .toList(growable: false);
    }

    return const [];
  }
}
