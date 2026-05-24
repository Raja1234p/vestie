import 'package:equatable/equatable.dart';

/// Week 3 `GET /projects/{id}/memberships/pending` item.
class PendingJoinRequestEntity extends Equatable {
  final String membershipId;
  final String userId;
  final String status;
  final String displayName;
  final String username;
  final String initials;
  final String? photoUrl;

  const PendingJoinRequestEntity({
    required this.membershipId,
    required this.userId,
    required this.status,
    this.displayName = '',
    this.username = '',
    this.initials = 'NA',
    this.photoUrl,
  });

  @override
  List<Object?> get props =>
      [membershipId, userId, status, displayName, username, initials, photoUrl];
}
