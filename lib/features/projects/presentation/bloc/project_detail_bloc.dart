import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/error/failures.dart';
import '../../../project_detail/domain/entities/member_entity.dart';
import '../../../project_detail/domain/entities/member_entity_extensions.dart';
import '../../../project_detail/domain/entities/project_detail_entity.dart';
import '../../../project_detail/domain/entities/project_detail_entity_extensions.dart';
import '../../../project_detail/domain/entities/viewer_membership_role.dart';
import '../../../project_detail/domain/repositories/project_detail_repository.dart';
import '../../../project_detail/domain/usecases/list_pending_join_requests_usecase.dart';
import 'package:vestie/core/error/failure_mapper.dart';
import 'package:vestie/user/features/vff/domain/entities/vff_enums.dart';
import 'package:vestie/user/features/vff/domain/usecases/vff_usecases.dart';

enum ProjectDetailTab { borrowRequests, members }

// EVENTS
abstract class ProjectDetailEvent extends Equatable {
  const ProjectDetailEvent();
  @override
  List<Object?> get props => [];
}

class LoadProjectDetailEvent extends ProjectDetailEvent {
  final String projectId;
  const LoadProjectDetailEvent({required this.projectId});
  @override
  List<Object?> get props => [projectId];
}

class ChangeTabEvent extends ProjectDetailEvent {
  final ProjectDetailTab activeTab;
  const ChangeTabEvent({required this.activeTab});
  @override
  List<Object?> get props => [activeTab];
}

/// Sends VFF request from project detail member row (no profile navigation).
class SendMemberVffRequestEvent extends ProjectDetailEvent {
  final MemberEntity member;

  const SendMemberVffRequestEvent({required this.member});

  @override
  List<Object?> get props => [member];
}

class ClearMemberVffSendErrorEvent extends ProjectDetailEvent {
  const ClearMemberVffSendErrorEvent();
}

// STATES
abstract class ProjectDetailState extends Equatable {
  const ProjectDetailState();
  @override
  List<Object?> get props => [];
}

class ProjectDetailInitial extends ProjectDetailState {}
class ProjectDetailLoading extends ProjectDetailState {}

class ProjectDetailLoaded extends ProjectDetailState {
  final ProjectDetailEntity project;
  final ViewerMembershipRole viewerRole;
  final ProjectDetailTab activeTab;
  /// From Week 3 `GET /projects/{id}/memberships/pending` when viewer can manage.
  final int pendingJoinRequestCount;

  /// `member.apiUserId` while POST VFF request is in flight.
  final String? sendingVffUserId;

  /// Shown once via UI listener (snackbar).
  final String? vffSendErrorMessage;

  ProjectDetailLoaded({
    required this.project,
    this.activeTab = ProjectDetailTab.borrowRequests,
    int? pendingJoinRequestCount,
    this.sendingVffUserId,
    this.vffSendErrorMessage,
  })  : viewerRole = project.viewerRole,
        pendingJoinRequestCount =
            pendingJoinRequestCount ?? project.pendingJoinRequestCount;

  bool get isGroupLeader => viewerRole.isGroupLeader;

  ProjectDetailLoaded copyWith({
    ProjectDetailEntity? project,
    ProjectDetailTab? activeTab,
    int? pendingJoinRequestCount,
    String? sendingVffUserId,
    bool clearSendingVffUserId = false,
    String? vffSendErrorMessage,
    bool clearVffSendError = false,
  }) {
    return ProjectDetailLoaded(
      project: project ?? this.project,
      activeTab: activeTab ?? this.activeTab,
      pendingJoinRequestCount:
          pendingJoinRequestCount ?? this.pendingJoinRequestCount,
      sendingVffUserId: clearSendingVffUserId
          ? null
          : (sendingVffUserId ?? this.sendingVffUserId),
      vffSendErrorMessage: clearVffSendError
          ? null
          : (vffSendErrorMessage ?? this.vffSendErrorMessage),
    );
  }

  @override
  List<Object?> get props => [
        project,
        viewerRole,
        activeTab,
        pendingJoinRequestCount,
        sendingVffUserId,
        vffSendErrorMessage,
      ];
}

class ProjectDetailError extends ProjectDetailState {
  final String message;
  const ProjectDetailError({required this.message});
  @override
  List<Object?> get props => [message];
}

// BLOC
class ProjectDetailBloc extends Bloc<ProjectDetailEvent, ProjectDetailState> {
  final ProjectDetailRepository repository;
  final ListPendingJoinRequestsUseCase? _listPendingJoinRequests;
  final SendVffRequestUseCase? _sendVffRequestUseCase;

  ProjectDetailBloc({
    required this.repository,
    ListPendingJoinRequestsUseCase? listPendingJoinRequests,
    SendVffRequestUseCase? sendVffRequestUseCase,
  })  : _listPendingJoinRequests = listPendingJoinRequests,
        _sendVffRequestUseCase = sendVffRequestUseCase,
        super(ProjectDetailInitial()) {
    on<LoadProjectDetailEvent>(_onLoadProjectDetail);
    on<ChangeTabEvent>(_onChangeTab);
    on<SendMemberVffRequestEvent>(_onSendMemberVffRequest);
    on<ClearMemberVffSendErrorEvent>(_onClearMemberVffSendError);
  }

  Future<void> _onLoadProjectDetail(
    LoadProjectDetailEvent event,
    Emitter<ProjectDetailState> emit,
  ) async {
    final preservedTab = switch (state) {
      ProjectDetailLoaded(:final activeTab) => activeTab,
      _ => ProjectDetailTab.borrowRequests,
    };
    final isSilentRefresh = state is ProjectDetailLoaded;
    if (!isSilentRefresh) {
      emit(ProjectDetailLoading());
    }
    final result = await repository.getProjectDetail(projectId: event.projectId);

    await result.fold(
      (failure) async {
        emit(ProjectDetailError(message: _messageFor(failure)));
      },
      (project) async {
        var pendingCount = project.pendingJoinRequestCount;
        final listPending = _listPendingJoinRequests;
        if (project.showsJoinRequestsHeaderChip && listPending != null) {
          final pendingResult = await listPending(event.projectId);
          pendingResult.fold(
            (_) {},
            (list) => pendingCount = list.length,
          );
        }
        emit(
          ProjectDetailLoaded(
            project: project,
            activeTab: preservedTab,
            pendingJoinRequestCount: pendingCount,
          ),
        );
      },
    );
  }

  Future<void> _onSendMemberVffRequest(
    SendMemberVffRequestEvent event,
    Emitter<ProjectDetailState> emit,
  ) async {
    final curr = state;
    if (curr is! ProjectDetailLoaded) return;

    final sendUseCase = _sendVffRequestUseCase;
    if (sendUseCase == null) return;

    final member = event.member;
    final userId = member.apiUserId;
    if (userId.isEmpty) return;

    if (member.hasPendingVffOutgoing || member.isVffConnected) return;
    if (curr.sendingVffUserId != null) return;

    emit(
      curr.copyWith(
        sendingVffUserId: userId,
        clearVffSendError: true,
      ),
    );

    final result = await sendUseCase(
      projectId: curr.project.id,
      userId: userId,
    );

    final afterSend = state;
    if (afterSend is! ProjectDetailLoaded) return;

    await result.fold(
      (failure) async {
        emit(
          afterSend.copyWith(
            clearSendingVffUserId: true,
            vffSendErrorMessage: FailureMapper.userMessage(failure),
          ),
        );
      },
      (sent) async {
        final optimistic = afterSend.project.withUpdatedMember(
          member,
          (m) => m.copyWith(
            vffConnectionState: VffConnectionState.pendingOutgoing,
            canSendVffRequest: false,
            pendingVffRequestId:
                sent.id.isNotEmpty ? sent.id : m.pendingVffRequestId,
          ),
        );
        emit(
          afterSend.copyWith(
            project: optimistic,
            clearSendingVffUserId: true,
          ),
        );
        add(LoadProjectDetailEvent(projectId: afterSend.project.id));
      },
    );
  }

  void _onClearMemberVffSendError(
    ClearMemberVffSendErrorEvent event,
    Emitter<ProjectDetailState> emit,
  ) {
    final curr = state;
    if (curr is! ProjectDetailLoaded) return;
    emit(curr.copyWith(clearVffSendError: true));
  }

  static String _messageFor(Failure failure) {
    if (failure is NetworkFailure) return AppStrings.errorNetwork;
    if (failure is ForbiddenFailure) return AppStrings.errorForbidden;
    final msg = failure.message.toLowerCase();
    if (msg.contains('not found')) return AppStrings.projectNotFound;
    return failure.message;
  }

  void _onChangeTab(ChangeTabEvent event, Emitter<ProjectDetailState> emit) {
    final curr = state;
    if (curr is ProjectDetailLoaded) {
      emit(curr.copyWith(activeTab: event.activeTab));
    }
  }
}
