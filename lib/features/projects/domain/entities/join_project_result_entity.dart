import 'package:equatable/equatable.dart';

class JoinProjectResultEntity extends Equatable {
  final String projectId;
  final String membershipId;
  final String status;
  final String role;

  const JoinProjectResultEntity({
    required this.projectId,
    required this.membershipId,
    required this.status,
    required this.role,
  });

  String get normalizedStatus => status.toLowerCase();

  /// Leader approval required — user stays on discover.
  bool get isPendingMembership => normalizedStatus.contains('pending');

  /// Immediate join (`active`, etc.) — open project detail.
  bool get isImmediateMembership => !isPendingMembership;

  @override
  List<Object?> get props => [projectId, membershipId, status, role];
}
