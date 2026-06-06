import 'package:equatable/equatable.dart';

import 'package:vestie/core/widgets/common/invite_vff_pick_ui.dart';

enum InviteMembersSheetLoadStatus {
  initial,
  loading,
  loaded,
  error,
  submitting,
}

final class InviteMembersSheetState extends Equatable {
  final InviteMembersSheetLoadStatus status;
  final List<InviteVffPickUi> vffs;
  final int loadedConnectionCount;
  final String? errorMessage;

  const InviteMembersSheetState({
    this.status = InviteMembersSheetLoadStatus.initial,
    this.vffs = const [],
    this.loadedConnectionCount = 0,
    this.errorMessage,
  });

  /// API returned VFFs, but every row is pending or already in this project.
  bool get allConnectionsAlreadyInProject =>
      status == InviteMembersSheetLoadStatus.loaded &&
      loadedConnectionCount > 0 &&
      vffs.isEmpty;

  bool get isLoading =>
      status == InviteMembersSheetLoadStatus.loading ||
      status == InviteMembersSheetLoadStatus.initial;

  bool get isSubmitting => status == InviteMembersSheetLoadStatus.submitting;

  InviteMembersSheetState copyWith({
    InviteMembersSheetLoadStatus? status,
    List<InviteVffPickUi>? vffs,
    int? loadedConnectionCount,
    String? errorMessage,
    bool clearError = false,
  }) {
    return InviteMembersSheetState(
      status: status ?? this.status,
      vffs: vffs ?? this.vffs,
      loadedConnectionCount:
          loadedConnectionCount ?? this.loadedConnectionCount,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
    status,
    vffs,
    loadedConnectionCount,
    errorMessage,
  ];
}
