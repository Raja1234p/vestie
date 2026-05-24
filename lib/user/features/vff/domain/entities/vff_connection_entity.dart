import 'vff_enums.dart';

/// Row from `GET /users/me/vffs`.
class VffConnectionEntity {
  final String userId;
  final String fullName;
  final String? username;
  final String? profilePhotoUrl;
  final int mutualProjectsCount;
  final VffOutgoingRequestStatus? outgoingRequestStatus;

  const VffConnectionEntity({
    required this.userId,
    required this.fullName,
    this.username,
    this.profilePhotoUrl,
    this.mutualProjectsCount = 0,
    this.outgoingRequestStatus,
  });

  bool get isPendingOutgoing =>
      outgoingRequestStatus == VffOutgoingRequestStatus.requestSent;
}
