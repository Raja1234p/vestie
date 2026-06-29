import '../../domain/entities/cancel_project_entities.dart';

class CancelProjectResponseModel {
  final String projectId;
  final String status;
  final double totalRefunded;
  final int refundedMemberCount;
  final int defaultedMemberCount;
  final double defaultedMembersReceived;

  const CancelProjectResponseModel({
    required this.projectId,
    required this.status,
    required this.totalRefunded,
    required this.refundedMemberCount,
    required this.defaultedMemberCount,
    required this.defaultedMembersReceived,
  });

  factory CancelProjectResponseModel.fromJson(Map<String, dynamic> json) {
    return CancelProjectResponseModel(
      projectId: _string(json['projectId']),
      status: _string(json['status']),
      totalRefunded: (json['totalRefunded'] as num?)?.toDouble() ?? 0,
      refundedMemberCount: (json['refundedMemberCount'] as num?)?.toInt() ?? 0,
      defaultedMemberCount: (json['defaultedMemberCount'] as num?)?.toInt() ?? 0,
      defaultedMembersReceived:
          (json['defaultedMembersReceived'] as num?)?.toDouble() ?? 0,
    );
  }

  CancelProjectResultEntity toEntity() {
    return CancelProjectResultEntity(
      projectId: projectId,
      status: status,
      totalRefunded: totalRefunded,
      refundedMemberCount: refundedMemberCount,
      defaultedMemberCount: defaultedMemberCount,
      defaultedMembersReceived: defaultedMembersReceived,
    );
  }
}

Map<String, dynamic> parseCancelProjectResponseMap(dynamic data) {
  if (data is Map<String, dynamic>) return data;
  if (data is Map) return Map<String, dynamic>.from(data);
  return <String, dynamic>{};
}

String _string(dynamic value) => value?.toString().trim() ?? '';
