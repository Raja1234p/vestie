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
  final int totalConnectionCount;
  final int currentPage;
  final bool loadingMore;
  final String? errorMessage;

  const InviteMembersSheetState({
    this.status = InviteMembersSheetLoadStatus.initial,
    this.vffs = const [],
    this.loadedConnectionCount = 0,
    this.totalConnectionCount = 0,
    this.currentPage = 0,
    this.loadingMore = false,
    this.errorMessage,
  });

  bool get hasMore => loadedConnectionCount < totalConnectionCount;

  /// API returned VFFs, but every row is pending or already in this project.
  bool get allConnectionsAlreadyInProject =>
      status == InviteMembersSheetLoadStatus.loaded &&
      loadedConnectionCount > 0 &&
      vffs.isEmpty &&
      !hasMore;

  bool get isLoading =>
      status == InviteMembersSheetLoadStatus.loading ||
      status == InviteMembersSheetLoadStatus.initial;

  bool get isSubmitting => status == InviteMembersSheetLoadStatus.submitting;

  InviteMembersSheetState copyWith({
    InviteMembersSheetLoadStatus? status,
    List<InviteVffPickUi>? vffs,
    int? loadedConnectionCount,
    int? totalConnectionCount,
    int? currentPage,
    bool? loadingMore,
    String? errorMessage,
    bool clearError = false,
  }) {
    return InviteMembersSheetState(
      status: status ?? this.status,
      vffs: vffs ?? this.vffs,
      loadedConnectionCount:
          loadedConnectionCount ?? this.loadedConnectionCount,
      totalConnectionCount: totalConnectionCount ?? this.totalConnectionCount,
      currentPage: currentPage ?? this.currentPage,
      loadingMore: loadingMore ?? this.loadingMore,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
    status,
    vffs,
    loadedConnectionCount,
    totalConnectionCount,
    currentPage,
    loadingMore,
    errorMessage,
  ];
}
