import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vestie/core/error/failure_mapper.dart';

import '../../domain/usecases/vff_usecases.dart';
import '../mappers/invite_members_mapper.dart';
import 'invite_members_sheet_state.dart';

final class InviteMembersSheetCubit extends Cubit<InviteMembersSheetState> {
  InviteMembersSheetCubit({
    required ListMyVffsUseCase listMyVffsUseCase,
    required InviteVffsToProjectUseCase inviteVffsToProjectUseCase,
  }) : _listMyVffsUseCase = listMyVffsUseCase,
       _inviteVffsToProjectUseCase = inviteVffsToProjectUseCase,
       super(const InviteMembersSheetState());

  final ListMyVffsUseCase _listMyVffsUseCase;
  final InviteVffsToProjectUseCase _inviteVffsToProjectUseCase;
  Set<String> _excludeUserIds = const {};

  Future<void> load({Set<String> excludeUserIds = const {}}) async {
    _excludeUserIds = excludeUserIds;
    await _fetch(page: 1, replace: true);
  }

  Future<void> loadMore() async {
    if (state.isLoading ||
        state.loadingMore ||
        !state.hasMore ||
        state.isSubmitting) {
      return;
    }
    await _fetch(page: state.currentPage + 1, replace: false, loadingMore: true);
  }

  Future<void> _fetch({
    required int page,
    required bool replace,
    bool loadingMore = false,
  }) async {
    if (!loadingMore) {
      emit(
        state.copyWith(
          status: InviteMembersSheetLoadStatus.loading,
          loadingMore: false,
          clearError: true,
        ),
      );
    } else {
      emit(state.copyWith(loadingMore: true, clearError: true));
    }

    final result = await _listMyVffsUseCase(page: page);

    if (isClosed) return;

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: replace && state.vffs.isEmpty
              ? InviteMembersSheetLoadStatus.error
              : InviteMembersSheetLoadStatus.loaded,
          loadingMore: false,
          errorMessage: FailureMapper.userMessage(failure),
        ),
      ),
      (pageResult) {
        final connections = pageResult.items;
        final inviteable = InviteMembersMapper.fromConnections(
          connections,
          excludeUserIds: _excludeUserIds,
        );
        final existingIds = replace
            ? const <String>{}
            : state.vffs.map((v) => v.id).toSet();
        final mergedVffs = replace
            ? inviteable
            : [
                ...state.vffs,
                ...inviteable.where((v) => !existingIds.contains(v.id)),
              ];
        final loadedCount = replace
            ? connections.length
            : state.loadedConnectionCount + connections.length;

        emit(
          state.copyWith(
            status: InviteMembersSheetLoadStatus.loaded,
            loadedConnectionCount: loadedCount,
            totalConnectionCount: pageResult.totalCount,
            currentPage: pageResult.page,
            vffs: mergedVffs,
            loadingMore: false,
          ),
        );
      },
    );
  }

  Future<int?> inviteSelected({
    required String projectId,
    required List<String> userIds,
  }) async {
    if (userIds.isEmpty || state.isSubmitting) return null;

    emit(
      state.copyWith(
        status: InviteMembersSheetLoadStatus.submitting,
        clearError: true,
      ),
    );

    final result = await _inviteVffsToProjectUseCase(
      projectId: projectId,
      userIds: userIds,
    );

    if (isClosed) return null;

    int? count;
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: InviteMembersSheetLoadStatus.loaded,
          errorMessage: FailureMapper.userMessage(failure),
        ),
      ),
      (invites) {
        count = invites.length;
        emit(state.copyWith(status: InviteMembersSheetLoadStatus.loaded));
      },
    );
    return count;
  }

  Future<void> retryLoad() => load(excludeUserIds: _excludeUserIds);
}
