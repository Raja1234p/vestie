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

  @override
  List<Object?> get props => [projectId, membershipId, status, role];
}
