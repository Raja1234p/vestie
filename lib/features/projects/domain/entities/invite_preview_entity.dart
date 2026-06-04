import 'package:equatable/equatable.dart';

class InvitePreviewEntity extends Equatable {
  final String projectId;
  final String projectName;
  final String projectType;
  final String visibility;
  final bool requiresApproval;
  final String expiresAtUtc;
  final bool isExpired;
  final bool isJoinable;
  final String? description;
  final int? memberCount;
  final double? raisedAmount;
  final int? contributionCount;
  final double? roiPercentage;

  const InvitePreviewEntity({
    required this.projectId,
    required this.projectName,
    required this.projectType,
    required this.visibility,
    required this.requiresApproval,
    required this.expiresAtUtc,
    required this.isExpired,
    required this.isJoinable,
    this.description,
    this.memberCount,
    this.raisedAmount,
    this.contributionCount,
    this.roiPercentage,
  });

  bool get isInvestment =>
      projectType.toLowerCase().contains('invest');

  @override
  List<Object?> get props => [
        projectId,
        projectName,
        projectType,
        visibility,
        requiresApproval,
        expiresAtUtc,
        isExpired,
        isJoinable,
        description,
        memberCount,
        raisedAmount,
        contributionCount,
        roiPercentage,
      ];
}
