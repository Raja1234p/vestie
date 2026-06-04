/// POST `/projects/join` body — API allows exactly one identifier.
Map<String, dynamic> buildJoinProjectRequestBody({
  String? projectId,
  String? inviteCode,
}) {
  final id = projectId?.trim();
  final code = inviteCode?.trim();
  final hasProjectId = id != null && id.isNotEmpty;
  final hasInviteCode = code != null && code.isNotEmpty;
  if (hasProjectId == hasInviteCode) {
    throw ArgumentError(
      'Specify exactly one of projectId (public join) or inviteCode.',
    );
  }
  return hasInviteCode
      ? <String, dynamic>{'inviteCode': code}
      : <String, dynamic>{'projectId': id};
}
