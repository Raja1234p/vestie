/// Week 10 `POST /projects/{id}/cancel` response.
class CancelProjectResultEntity {
  final String projectId;
  final String status;
  final double totalRefunded;
  final int refundedMemberCount;
  final int defaultedMemberCount;
  final double defaultedMembersReceived;

  const CancelProjectResultEntity({
    required this.projectId,
    required this.status,
    required this.totalRefunded,
    required this.refundedMemberCount,
    required this.defaultedMemberCount,
    required this.defaultedMembersReceived,
  });
}
