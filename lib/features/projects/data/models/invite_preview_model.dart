import 'package:vestie/core/utils/roi_display_format.dart';

import '../../domain/entities/invite_preview_entity.dart';

class InvitePreviewModel extends InvitePreviewEntity {
  const InvitePreviewModel({
    required super.projectId,
    required super.projectName,
    required super.projectType,
    required super.visibility,
    required super.requiresApproval,
    required super.expiresAtUtc,
    required super.isExpired,
    required super.isJoinable,
    super.description,
    super.memberCount,
    super.raisedAmount,
    super.contributionCount,
    super.roiPercentage,
  });

  factory InvitePreviewModel.fromJson(Map<String, dynamic> json) {
    return InvitePreviewModel(
      projectId: json['projectId'] as String? ?? '',
      projectName: json['projectName'] as String? ?? '',
      projectType: json['projectType'] as String? ?? '',
      visibility: json['visibility'] as String? ?? '',
      requiresApproval: json['requiresApproval'] as bool? ?? false,
      expiresAtUtc: json['expiresAtUtc'] as String? ?? '',
      isExpired: json['isExpired'] as bool? ?? false,
      isJoinable: json['isJoinable'] as bool? ?? false,
      description: _optionalString(json['description']),
      memberCount: _optionalInt(json['memberCount'] ?? json['membersCount']),
      raisedAmount: _optionalDouble(json['raisedAmount']),
      contributionCount: _optionalInt(
        json['contributionCount'] ?? json['contributionsCount'],
      ),
      roiPercentage: normalizeDisplayableRoi(
        _optionalDouble(
          json['roi'] ??
              json['roiPercentage'] ??
              json['expectedRoi'] ??
              json['annualRoiPercent'],
        ),
      ),
    );
  }

  static double? _optionalDouble(Object? value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  static String? _optionalString(Object? value) {
    final s = value?.toString().trim();
    if (s == null || s.isEmpty) return null;
    return s;
  }

  static int? _optionalInt(Object? value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }
}
