import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vestie/core/di/service_locator.dart';
import 'package:vestie/core/error/failure_mapper.dart';
import 'package:vestie/core/auth/app_auth_session.dart';
import 'package:vestie/core/storage/pending_project_invite_store.dart';
import 'package:vestie/features/projects/domain/usecases/join_project_usecase.dart';
import 'package:vestie/features/projects/domain/usecases/preview_invite_usecase.dart';

import 'project_invitation_join_effect.dart';
import 'project_invitation_state.dart';

class ProjectInvitationCubit extends Cubit<ProjectInvitationState> {
  final String inviteCode;
  final PreviewInviteUseCase _previewInviteUseCase;
  final JoinProjectUseCase _joinProjectUseCase;

  ProjectInvitationCubit({
    required this.inviteCode,
    PreviewInviteUseCase? previewInviteUseCase,
    JoinProjectUseCase? joinProjectUseCase,
  }) : _previewInviteUseCase =
           previewInviteUseCase ?? ServiceLocator.instance.previewInviteUseCase,
       _joinProjectUseCase =
           joinProjectUseCase ?? ServiceLocator.instance.joinProjectUseCase,
       super(const ProjectInvitationState(loading: true));

  Future<void> load() async {
    emit(state.copyWith(loading: true, clearError: true));
    await PendingProjectInviteStore.save(inviteCode);

    final result = await _previewInviteUseCase(inviteCode);
    result.fold(
      (failure) => emit(
        state.copyWith(
          loading: false,
          errorMessage: FailureMapper.userMessage(failure),
        ),
      ),
      (preview) => emit(state.copyWith(loading: false, preview: preview)),
    );
  }

  Future<void> join() async {
    final preview = state.preview;
    if (preview == null || state.joining) return;

    await AppAuthSession.instance.syncFromStorage();
    if (!AppAuthSession.instance.isAuthenticated) {
      await PendingProjectInviteStore.save(inviteCode);
      emit(state.copyWith(joinEffect: const ProjectInvitationJoinNeedsAuth()));
      return;
    }

    if (preview.isExpired || !preview.isJoinable) return;

    emit(state.copyWith(joining: true, clearJoinEffect: true));

    final result = await _joinProjectUseCase(inviteCode: inviteCode);

    result.fold(
      (failure) => emit(
        state.copyWith(
          joining: false,
          joinEffect: ProjectInvitationJoinShowError(
            FailureMapper.userMessage(failure),
            title: failure.title,
          ),
        ),
      ),
      (joinResult) {
        if (joinResult.isPendingMembership) {
          emit(
            state.copyWith(
              joining: false,
              joinEffect: ProjectInvitationJoinShowRequestSubmitted(
                projectId: joinResult.projectId.isNotEmpty
                    ? joinResult.projectId
                    : preview.projectId,
                projectName: preview.projectName,
                isInvestment: preview.isInvestment,
              ),
            ),
          );
          return;
        }

        final projectId = joinResult.projectId.isNotEmpty
            ? joinResult.projectId
            : preview.projectId;
        emit(
          state.copyWith(
            joining: false,
            joinEffect: ProjectInvitationJoinOpenDetail(
              projectId: projectId,
              projectName: preview.projectName,
              isInvestment: preview.isInvestment,
            ),
          ),
        );
      },
    );
  }

  void clearJoinEffect() {
    if (state.joinEffect == null) return;
    emit(state.copyWith(clearJoinEffect: true));
  }
}
