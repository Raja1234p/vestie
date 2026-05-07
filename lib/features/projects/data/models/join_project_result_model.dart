import '../../domain/entities/join_project_result_entity.dart';

class JoinProjectResultModel extends JoinProjectResultEntity {
  const JoinProjectResultModel({
    required super.projectId,
    required super.membershipId,
    required super.status,
    required super.role,
  });

  factory JoinProjectResultModel.fromJson(Map<String, dynamic> json) {
    return JoinProjectResultModel(
      projectId: json['projectId'] as String? ?? '',
      membershipId: json['membershipId'] as String? ?? '',
      status: json['status'] as String? ?? '',
      role: json['role'] as String? ?? '',
    );
  }
}
