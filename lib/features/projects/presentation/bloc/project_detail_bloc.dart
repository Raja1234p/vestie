import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/error/failures.dart';
import '../../../project_detail/domain/entities/member_entity.dart';
import '../../../project_detail/domain/entities/member_entity_extensions.dart';
import '../../../project_detail/domain/entities/project_detail_closure_extensions.dart';
import '../../../project_detail/domain/entities/project_detail_entity.dart';
import '../../../project_detail/domain/entities/project_detail_entity_extensions.dart';
import '../../../project_detail/domain/entities/viewer_membership_role.dart';
import '../../../project_detail/domain/repositories/project_detail_repository.dart';
import '../../../project_detail/domain/usecases/get_active_closure_vote_usecase.dart';
import '../../../project_detail/domain/usecases/list_pending_join_requests_usecase.dart';
import 'package:vestie/core/error/failure_mapper.dart';
import 'package:vestie/user/features/vff/domain/entities/vff_enums.dart';
import 'package:vestie/features/project_detail/domain/entities/project_detail_pot_extensions.dart';
import 'package:vestie/features/project_pot/domain/entities/project_pot_entity.dart';
import 'package:vestie/features/project_pot/domain/usecases/get_project_pot_use_case.dart';
import 'package:vestie/user/features/borrow/domain/usecases/list_borrow_requests_use_case.dart';
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

/// Reloads `GET /projects/{id}/pot` and merges raised amount into loaded detail.
class RefreshProjectPotEvent extends ProjectDetailEvent {
  final String projectId;
  const RefreshProjectPotEvent({required this.projectId});
  @override
  List<Object?> get props => [projectId];
}

/// Applies `POST /contributions` 201 payload before refreshing pot from API.
class ApplyContributionSubmitResultEvent extends ProjectDetailEvent {
  final String projectId;
  final double projectPot;
  final List<String> vffMemberUserIds;

  const ApplyContributionSubmitResultEvent({
    required this.projectId,
    required this.projectPot,
    required this.vffMemberUserIds,
  });

  @override
  List<Object?> get props => [projectId, projectPot, vffMemberUserIds];
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

  /// Shown once via UI listener (toast).
  final String? vffSendErrorMessage;

  ProjectDetailLoaded({
    required this.project,
    this.activeTab = ProjectDetailTab.borrowRequests,
    int? pendingJoinRequestCount,
    this.sendingVffUserId,
    this.vffSendErrorMessage,
  }) : viewerRole = project.viewerRole,
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
  final GetProjectPotUseCase? _getProjectPotUseCase;
  final ListPendingJoinRequestsUseCase? _listPendingJoinRequests;
  final ListBorrowRequestsUseCase? _listBorrowRequests;
  final SendVffRequestUseCase? _sendVffRequestUseCase;
  final GetActiveClosureVoteUseCase? _getActiveClosureVoteUseCase;
  final List<Completer<void>> _detailLoadWaiters = [];
  bool _detailLoadInFlight = false;
  String? _detailLoadProjectId;
  bool _detailReloadQueued = false;

  ProjectDetailBloc({
    required this.repository,
    GetProjectPotUseCase? getProjectPotUseCase,
    ListPendingJoinRequestsUseCase? listPendingJoinRequests,
    ListBorrowRequestsUseCase? listBorrowRequests,
    SendVffRequestUseCase? sendVffRequestUseCase,
    GetActiveClosureVoteUseCase? getActiveClosureVoteUseCase,
  }) : _getProjectPotUseCase = getProjectPotUseCase,
       _listPendingJoinRequests = listPendingJoinRequests,
       _listBorrowRequests = listBorrowRequests,
       _sendVffRequestUseCase = sendVffRequestUseCase,
       _getActiveClosureVoteUseCase = getActiveClosureVoteUseCase,
       super(ProjectDetailInitial()) {
    on<LoadProjectDetailEvent>(_onLoadProjectDetail);
    on<RefreshProjectPotEvent>(_onRefreshProjectPot);
    on<ApplyContributionSubmitResultEvent>(_onApplyContributionSubmitResult);
    on<ChangeTabEvent>(_onChangeTab);
    on<SendMemberVffRequestEvent>(_onSendMemberVffRequest);
    on<ClearMemberVffSendErrorEvent>(_onClearMemberVffSendError);
  }

  /// Reloads project detail and completes when this load finishes (silent or full).
  Future<void> reloadDetailAndWait(String projectId) {
    final waiter = Completer<void>();
    _detailLoadWaiters.add(waiter);
    add(LoadProjectDetailEvent(projectId: projectId));
    return waiter.future;
  }

  void _completeDetailLoadWaiters() {
    for (final waiter in _detailLoadWaiters) {
      if (!waiter.isCompleted) waiter.complete();
    }
    _detailLoadWaiters.clear();
  }

  Future<void> _onLoadProjectDetail(
    LoadProjectDetailEvent event,
    Emitter<ProjectDetailState> emit,
  ) async {
    if (_detailLoadInFlight && _detailLoadProjectId == event.projectId) {
      _detailReloadQueued = true;
      return;
    }

    _detailLoadInFlight = true;
    _detailLoadProjectId = event.projectId;

    final preservedTab = switch (state) {
      ProjectDetailLoaded(:final activeTab) => activeTab,
      _ => ProjectDetailTab.borrowRequests,
    };
    final isSilentRefresh = state is ProjectDetailLoaded;
    if (!isSilentRefresh) {
      emit(ProjectDetailLoading());
    }
    final result = await repository.getProjectDetail(
      projectId: event.projectId,
    );

    try {
      await result.fold(
        (failure) async {
          emit(ProjectDetailError(message: _messageFor(failure)));
        },
        (project) async {
          var pendingCount = project.pendingJoinRequestCount;
          // After moderation / member sync, refresh chip count from pending list.
          final listPending = _listPendingJoinRequests;
          if (isSilentRefresh &&
              project.showsJoinRequestsHeaderChip &&
              listPending != null) {
            final pendingResult = await listPending(event.projectId);
            pendingResult.fold((_) {}, (list) => pendingCount = list.length);
          }
          var loadedProject = project;
          final potUseCase = _getProjectPotUseCase;
          if (potUseCase != null) {
            final potResult = await potUseCase(event.projectId);
            potResult.fold((_) {}, (pot) {
              loadedProject = loadedProject.withProjectPot(pot);
            });
          }

          final listBorrow = _listBorrowRequests;
          if (listBorrow != null && loadedProject.borrowingEnabled) {
            final borrowResult = await listBorrow(
              projectId: event.projectId,
              status: 'Pending',
            );
            borrowResult.fold((_) {}, (requests) {
              loadedProject = loadedProject.withBorrowRequests(requests);
            });
          }

          final activeVoteUseCase = _getActiveClosureVoteUseCase;
          if (activeVoteUseCase != null && !loadedProject.votingIsInProgress) {
            final activeResult = await activeVoteUseCase(event.projectId);
            activeResult.fold((_) {}, (vote) {
              loadedProject = loadedProject.withActiveClosureVote(vote);
            });
          } else if (loadedProject.votingIsInProgress) {
            loadedProject =
                loadedProject.withSyntheticClosureVoteFromDetailVoting();
          }

          emit(
            ProjectDetailLoaded(
              project: loadedProject,
              activeTab: preservedTab,
              pendingJoinRequestCount: pendingCount,
            ),
          );
        },
      );
    } finally {
      final shouldReload = _detailReloadQueued;
      _detailReloadQueued = false;
      _detailLoadInFlight = false;
      _detailLoadProjectId = null;

      if (shouldReload) {
        // Sync waiters must see post-mutation data from the queued reload.
        add(LoadProjectDetailEvent(projectId: event.projectId));
      } else {
        _completeDetailLoadWaiters();
      }
    }
  }

  void _onApplyContributionSubmitResult(
    ApplyContributionSubmitResultEvent event,
    Emitter<ProjectDetailState> emit,
  ) {
    final curr = state;
    if (curr is! ProjectDetailLoaded) return;
    if (curr.project.id != event.projectId) return;

    final pot = ProjectPotEntity(
      potAmount: event.projectPot,
      contributorCount: curr.project.contributorCount,
      vffMemberUserIds: event.vffMemberUserIds,
    );
    emit(curr.copyWith(project: curr.project.withProjectPot(pot)));
    add(RefreshProjectPotEvent(projectId: event.projectId));
  }

  Future<void> _onRefreshProjectPot(
    RefreshProjectPotEvent event,
    Emitter<ProjectDetailState> emit,
  ) async {
    final curr = state;
    if (curr is! ProjectDetailLoaded) return;
    if (curr.project.id != event.projectId) return;

    final potUseCase = _getProjectPotUseCase;
    if (potUseCase == null) return;

    final potResult = await potUseCase(event.projectId);
    potResult.fold((_) {}, (pot) {
      if (state is! ProjectDetailLoaded) return;
      final loaded = state as ProjectDetailLoaded;
      if (loaded.project.id != event.projectId) return;
      emit(loaded.copyWith(project: loaded.project.withProjectPot(pot)));
    });
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

    if (member.hasPendingVffOutgoing || member.isViewerVffLinked) return;
    if (curr.sendingVffUserId != null) return;

    emit(curr.copyWith(sendingVffUserId: userId, clearVffSendError: true));

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
        final projectId = afterSend.project.id;
        final optimistic = afterSend.project.withUpdatedMember(
          member,
          (m) => m.copyWith(
            vffConnectionState: VffConnectionState.pendingOutgoing,
            canSendVffRequest: false,
            pendingVffRequestId: sent.id.isNotEmpty
                ? sent.id
                : m.pendingVffRequestId,
          ),
        );
        emit(afterSend.copyWith(project: optimistic));
        await reloadDetailAndWait(projectId);
        final latest = state;
        if (latest is ProjectDetailLoaded && latest.project.id == projectId) {
          emit(latest.copyWith(clearSendingVffUserId: true));
        }
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
