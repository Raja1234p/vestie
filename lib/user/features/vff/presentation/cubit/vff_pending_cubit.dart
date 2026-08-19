import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vestie/core/services/notifications/vff_pending_refresh.dart';
import 'package:vestie/user/features/vff/domain/usecases/vff_usecases.dart';

import 'vff_pending_state.dart';

/// App-wide flag that drives the dot on the VFF hub icon.
///
/// Source of truth is [GetVffReceivedInboxUseCase] — the same endpoint that
/// powers the Requests tab in the VFF hub.  A dot is shown whenever
/// `vffRequests.isNotEmpty || projectInvites.isNotEmpty`.
class VffPendingCubit extends Cubit<VffPendingState> {
  final GetVffReceivedInboxUseCase getVffReceivedInboxUseCase;
  bool _refreshInFlight = false;

  VffPendingCubit({required this.getVffReceivedInboxUseCase})
    : super(const VffPendingState()) {
    VffPendingRefresh.register(
      markPending: _markPending,
      clearPending: _clearPending,
      refresh: refresh,
    );
  }

  void _markPending() {
    if (state.hasPending) return;
    emit(state.copyWith(hasPending: true));
  }

  void _clearPending() {
    if (!state.hasPending) return;
    emit(state.copyWith(hasPending: false));
  }

  /// Sync from VFF hub inbox without an extra GET (called after hub loads/mutates).
  void setHasPending(bool value) {
    if (state.hasPending == value) return;
    emit(state.copyWith(hasPending: value));
  }

  void reset() => emit(const VffPendingState());

  /// Lightweight probe — checks received inbox for any pending items.
  Future<void> refresh() async {
    if (_refreshInFlight) return;
    _refreshInFlight = true;
    try {
      final result = await getVffReceivedInboxUseCase(
        vffRequestsPageSize: 1,
        projectInvitesPageSize: 1,
      );
      result.fold(
        (_) {},
        (inbox) => emit(
          state.copyWith(
            hasPending:
                inbox.vffRequests.isNotEmpty ||
                inbox.projectInvites.isNotEmpty,
          ),
        ),
      );
    } finally {
      _refreshInFlight = false;
    }
  }

  @override
  Future<void> close() {
    VffPendingRefresh.unregister();
    return super.close();
  }
}
