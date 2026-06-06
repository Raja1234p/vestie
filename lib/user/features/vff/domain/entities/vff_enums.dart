/// API `vffConnectionState` on member activity.
enum VffConnectionState {
  none,
  pendingOutgoing,
  pendingIncoming,
  connected;

  static VffConnectionState parse(String? raw) {
    final key = raw?.trim().toLowerCase();
    if (key == null || key.isEmpty || key == 'none') {
      return VffConnectionState.none;
    }
    return switch (key) {
      'pendingoutgoing' => VffConnectionState.pendingOutgoing,
      'pendingincoming' => VffConnectionState.pendingIncoming,
      'connected' => VffConnectionState.connected,
      _ => VffConnectionState.none,
    };
  }
}

enum VffOutgoingRequestStatus {
  requestSent;

  static VffOutgoingRequestStatus? parse(String? raw) {
    return switch (raw?.trim()) {
      'RequestSent' => VffOutgoingRequestStatus.requestSent,
      _ => null,
    };
  }
}

enum VffRequestStatus {
  pending,
  accepted,
  declined;

  static VffRequestStatus parse(String? raw) {
    return switch (raw?.trim()) {
      'Accepted' => VffRequestStatus.accepted,
      'Declined' => VffRequestStatus.declined,
      _ => VffRequestStatus.pending,
    };
  }
}

enum VffProjectVisibility {
  public,
  private;

  static VffProjectVisibility parse(String? raw) {
    return raw?.trim().toLowerCase() == 'private'
        ? VffProjectVisibility.private
        : VffProjectVisibility.public;
  }
}

enum VffProjectJoinState {
  join,
  requestToJoin,
  requestSent,
  alreadyMember,
  pending;

  /// API `joinState` / `viewerJoinState` values (PascalCase), e.g.
  /// `AlreadyMember`, `RequestToJoin`, `RequestSent`, `Join`.
  static VffProjectJoinState parse(String? raw) {
    final key = raw?.trim().replaceAll(RegExp(r'[\s_-]'), '').toLowerCase();
    if (key == null || key.isEmpty) return VffProjectJoinState.join;
    return switch (key) {
      'requesttojoin' ||
      'canrequesttojoin' => VffProjectJoinState.requestToJoin,
      'requestsent' => VffProjectJoinState.requestSent,
      'alreadymember' => VffProjectJoinState.alreadyMember,
      'pending' => VffProjectJoinState.pending,
      'canjoin' || 'join' => VffProjectJoinState.join,
      _ => VffProjectJoinState.join,
    };
  }
}
