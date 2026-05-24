import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vestie/core/error/failure_mapper.dart';

import '../../domain/usecases/vff_usecases.dart';
import '../mappers/invite_members_mapper.dart';
import 'invite_members_sheet_state.dart';

final class InviteMembersSheetCubit extends Cubit<InviteMembersSheetState> {
  InviteMembersSheetCubit({
    required ListMyVffsUseCase listMyVffsUseCase,
    required InviteVffsToProjectUseCase inviteVffsToProjectUseCase,
  })  : _listMyVffsUseCase = listMyVffsUseCase,
        _inviteVffsToProjectUseCase = inviteVffsToProjectUseCase,
        super(const InviteMembersSheetState());

  final ListMyVffsUseCase _listMyVffsUseCase;
  final InviteVffsToProjectUseCase _inviteVffsToProjectUseCase;
  Set<String> _excludeUserIds = const {};

  Future<void> load({Set<String> excludeUserIds = const {}}) async {
    _excludeUserIds = excludeUserIds;
    emit(
      state.copyWith(
        status: InviteMembersSheetLoadStatus.loading,
        clearError: true,
      ),
    );

    final result = await _listMyVffsUseCase();

    if (isClosed) return;

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: InviteMembersSheetLoadStatus.error,
          errorMessage: FailureMapper.userMessage(failure),
        ),
      ),
      (connections) => emit(
        state.copyWith(
          status: InviteMembersSheetLoadStatus.loaded,
          vffs: InviteMembersMapper.fromConnections(
            connections,
            excludeUserIds: excludeUserIds,
          ),
        ),
      ),
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
        emit(
          state.copyWith(status: InviteMembersSheetLoadStatus.loaded),
        );
      },
    );
    return count;
  }

  Future<void> retryLoad() => load(excludeUserIds: _excludeUserIds);
}
