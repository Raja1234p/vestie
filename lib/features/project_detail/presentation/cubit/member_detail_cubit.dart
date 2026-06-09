import 'package:dartz/dartz.dart';

import 'package:equatable/equatable.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/error/failure_mapper.dart';
import '../../../../core/error/failures.dart';

import '../../domain/entities/member_activity_entity.dart';
import '../../domain/entities/member_entity_extensions.dart';

import '../../domain/usecases/get_member_activity_usecase.dart';

import '../../domain/usecases/project_actions_usecases.dart';
import '../project_detail_reload_coordinator.dart';

import 'package:vestie/user/features/vff/domain/entities/vff_enums.dart';
import 'package:vestie/user/features/vff/domain/usecases/vff_usecases.dart';

enum MemberDetailAction {
  assignCoLeader,
  removeCoLeader,
  removeMember,
  sendVffRequest,
}

enum MemberDetailLoadStatus { initial, loading, loaded, error }

class MemberDetailState extends Equatable {
  final MemberDetailLoadStatus loadStatus;

  final MemberActivityEntity? activity;

  final String? loadErrorMessage;

  final bool isActionLoading;

  final MemberDetailAction? loadingAction;

  final Failure? failure;

  final MemberDetailAction? completedAction;

  final bool projectMembersChanged;

  final bool isVffRequestLoading;

  final bool isRemoveVffLoading;

  const MemberDetailState({
    this.loadStatus = MemberDetailLoadStatus.initial,

    this.activity,

    this.loadErrorMessage,

    this.isActionLoading = false,

    this.loadingAction,

    this.failure,

    this.completedAction,

    this.projectMembersChanged = false,

    this.isVffRequestLoading = false,

    this.isRemoveVffLoading = false,
  });

  bool get isLoading => isActionLoading;

  bool isLoadingAction(MemberDetailAction action) =>
      isActionLoading && loadingAction == action;

  MemberDetailState copyWith({
    MemberDetailLoadStatus? loadStatus,

    MemberActivityEntity? activity,

    String? loadErrorMessage,

    bool? isActionLoading,

    MemberDetailAction? loadingAction,

    Failure? failure,

    MemberDetailAction? completedAction,

    bool? projectMembersChanged,

    bool? isVffRequestLoading,

    bool? isRemoveVffLoading,

    bool clearLoadError = false,

    bool clearFailure = false,

    bool clearCompleted = false,

    bool clearActivity = false,
  }) {
    return MemberDetailState(
      loadStatus: loadStatus ?? this.loadStatus,

      activity: clearActivity ? null : (activity ?? this.activity),

      loadErrorMessage: clearLoadError
          ? null
          : (loadErrorMessage ?? this.loadErrorMessage),

      isActionLoading: isActionLoading ?? this.isActionLoading,

      loadingAction: loadingAction,

      failure: clearFailure ? null : (failure ?? this.failure),

      completedAction: clearCompleted
          ? null
          : (completedAction ?? this.completedAction),

      projectMembersChanged:
          projectMembersChanged ?? this.projectMembersChanged,

      isVffRequestLoading: isVffRequestLoading ?? this.isVffRequestLoading,

      isRemoveVffLoading: isRemoveVffLoading ?? this.isRemoveVffLoading,
    );
  }

  @override
  List<Object?> get props => [
    loadStatus,

    activity,

    loadErrorMessage,

    isActionLoading,

    loadingAction,

    failure,

    completedAction,

    projectMembersChanged,

    isVffRequestLoading,

    isRemoveVffLoading,
  ];
}

class MemberDetailCubit extends Cubit<MemberDetailState> {
  MemberDetailCubit({
    required GetMemberActivityUseCase getMemberActivityUseCase,

    required UpdateCoLeaderRoleUseCase updateCoLeaderRoleUseCase,

    required RemoveMemberUseCase removeMemberUseCase,

    required SendVffRequestUseCase sendVffRequestUseCase,

    required RemoveVffConnectionUseCase removeVffConnectionUseCase,
  }) : _getMemberActivityUseCase = getMemberActivityUseCase,

       _updateCoLeaderRoleUseCase = updateCoLeaderRoleUseCase,

       _removeMemberUseCase = removeMemberUseCase,

       _sendVffRequestUseCase = sendVffRequestUseCase,

       _removeVffConnectionUseCase = removeVffConnectionUseCase,

       super(const MemberDetailState());

  final GetMemberActivityUseCase _getMemberActivityUseCase;

  final UpdateCoLeaderRoleUseCase _updateCoLeaderRoleUseCase;

  final RemoveMemberUseCase _removeMemberUseCase;

  final SendVffRequestUseCase _sendVffRequestUseCase;

  final RemoveVffConnectionUseCase _removeVffConnectionUseCase;

  String? _projectId;
  String? _userId;
  String? _projectName;

  Future<void> load({
    required String projectId,

    required String userId,

    required String projectName,
  }) async {
    _projectId = projectId;
    _userId = userId;
    _projectName = projectName;

    emit(
      state.copyWith(
        loadStatus: MemberDetailLoadStatus.loading,

        clearLoadError: true,
      ),
    );

    await _fetchActivity(showLoading: true);
  }

  /// Reloads activity without full-screen shimmer (e.g. after penalty / co-leader).
  Future<bool> refresh() => _fetchActivity(showLoading: false);

  /// Member activity GET, then active project detail reload (when detail is open).
  Future<void> syncWithProjectDetail({bool refreshMember = true}) =>
      _syncConnectedApis(refreshMember: refreshMember);

  Future<void> _syncConnectedApis({bool refreshMember = true}) async {
    if (refreshMember) {
      await refresh();
    }
    final projectId = _projectId;
    if (projectId == null || projectId.trim().isEmpty) return;
    await ProjectDetailReloadCoordinator.reload(projectId);
  }

  Future<bool> _fetchActivity({required bool showLoading}) async {
    final projectId = _projectId;
    final userId = _userId;
    final projectName = _projectName;
    if (projectId == null || userId == null || projectName == null) {
      return false;
    }

    final result = await _getMemberActivityUseCase(
      projectId: projectId,
      userId: userId,
      projectName: projectName,
    );

    var ok = false;
    result.fold(
      (failure) {
        if (showLoading) {
          emit(
            state.copyWith(
              loadStatus: MemberDetailLoadStatus.error,
              loadErrorMessage: messageForFailure(failure),
            ),
          );
        }
      },
      (activity) {
        ok = true;
        final apiUserId = activity.member.apiUserId.trim();
        if (apiUserId.isNotEmpty) {
          _userId = apiUserId;
        }
        final previous = state.activity;
        final merged = previous == null
            ? activity
            : _mergeActivityVffState(previous: previous, fetched: activity);
        emit(
          state.copyWith(
            loadStatus: MemberDetailLoadStatus.loaded,
            activity: merged,
            clearLoadError: true,
          ),
        );
      },
    );
    return ok;
  }

  /// Sends a VFF request in place — UI switches to “VFF Request Sent” (no navigation).
  Future<void> sendVffRequest() async {
    if (state.isVffRequestLoading) return;

    final projectId = _projectId;
    final userId = _userId;
    if (projectId == null || userId == null) return;

    final vffState =
        state.activity?.vffConnectionState ?? VffConnectionState.none;
    if (vffState == VffConnectionState.pendingOutgoing ||
        vffState == VffConnectionState.connected) {
      return;
    }

    emit(state.copyWith(isVffRequestLoading: true, clearFailure: true));

    final result = await _sendVffRequestUseCase(
      projectId: projectId,
      userId: userId,
    );

    if (isClosed) return;

    await result.fold(
      (failure) async {
        emit(state.copyWith(isVffRequestLoading: false, failure: failure));
      },
      (sent) async {
        final current = state.activity;
        if (current != null) {
          emit(
            state.copyWith(
              activity: current.copyWith(
                vffConnectionState: VffConnectionState.pendingOutgoing,
                canSendVffRequest: false,
                pendingVffRequestId: sent.id.isNotEmpty
                    ? sent.id
                    : current.pendingVffRequestId,
              ),
              projectMembersChanged: true,
            ),
          );
        } else {
          emit(state.copyWith(projectMembersChanged: true));
        }
        await _syncConnectedApis();
        if (isClosed) return;
        emit(
          state.copyWith(
            isVffRequestLoading: false,
            completedAction: MemberDetailAction.sendVffRequest,
          ),
        );
      },
    );
  }

  /// Activity GET can lag behind POST …/vff-requests — keep “sent” UI until API catches up.
  MemberActivityEntity _mergeActivityVffState({
    required MemberActivityEntity previous,
    required MemberActivityEntity fetched,
  }) {
    if (fetched.vffConnectionState == VffConnectionState.connected ||
        fetched.member.isVffConnected) {
      return fetched;
    }
    final fetchedPendingId = fetched.pendingVffRequestId?.trim() ?? '';
    if (fetched.member.hasPendingVffOutgoing || fetchedPendingId.isNotEmpty) {
      return fetched.copyWith(
        vffConnectionState: VffConnectionState.pendingOutgoing,
      );
    }
    if (previous.vffConnectionState != VffConnectionState.pendingOutgoing) {
      return fetched;
    }
    if (fetched.vffConnectionState == VffConnectionState.pendingOutgoing ||
        fetched.vffConnectionState == VffConnectionState.connected) {
      return fetched;
    }
    if (fetched.vffConnectionState == VffConnectionState.none &&
        !fetched.canSendVffRequest) {
      return fetched.copyWith(
        vffConnectionState: VffConnectionState.pendingOutgoing,
        pendingVffRequestId:
            fetched.pendingVffRequestId ?? previous.pendingVffRequestId,
      );
    }
    return fetched;
  }

  /// Remove VFF from member profile — loader on confirm dialog primary button.
  Future<bool> removeVffConnection() async {
    final userId = _userId;
    if (userId == null || userId.trim().isEmpty) return false;

    emit(state.copyWith(clearFailure: true));

    final result = await _removeVffConnectionUseCase(userId);
    if (isClosed) return false;

    return result.fold(
      (failure) {
        emit(state.copyWith(failure: failure));
        return false;
      },
      (_) async {
        final current = state.activity;
        if (current != null) {
          emit(
            state.copyWith(
              projectMembersChanged: true,
              activity: current.copyWith(
                member: current.member.copyWith(
                  vffConnectionState: VffConnectionState.none,
                  vffAdded: false,
                  canSendVffRequest: true,
                  clearPendingVffRequestId: true,
                ),
                vffConnectionState: VffConnectionState.none,
                canSendVffRequest: true,
                clearPendingVffRequestId: true,
              ),
            ),
          );
        } else {
          emit(state.copyWith(projectMembersChanged: true));
        }
        await _syncConnectedApis();
        if (isClosed) return false;
        return true;
      },
    );
  }

  Future<bool> assignCoLeader({
    required String projectId,
    required String userId,
  }) {
    return _setCoLeaderRole(projectId: projectId, userId: userId, assign: true);
  }

  Future<bool> removeCoLeader({
    required String projectId,
    required String userId,
  }) {
    return _setCoLeaderRole(
      projectId: projectId,
      userId: userId,
      assign: false,
    );
  }

  Future<bool> _setCoLeaderRole({
    required String projectId,
    required String userId,
    required bool assign,
  }) async {
    final resolvedUserId = userId.trim().isNotEmpty
        ? userId.trim()
        : (_userId ?? '').trim();
    if (resolvedUserId.isEmpty) {
      emit(
        state.copyWith(failure: const ServerFailure(AppStrings.errorGeneric)),
      );
      return false;
    }

    return _runDialogAction(
      refreshMember: true,
      task: () => _updateCoLeaderRoleUseCase(
        projectId: projectId,
        userId: resolvedUserId,
        assign: assign,
      ),
    );
  }

  Future<bool> removeMember({
    required String projectId,
    required String userId,
  }) {
    return _runDialogAction(
      refreshMember: false,
      task: () => _removeMemberUseCase(projectId: projectId, userId: userId),
    );
  }

  Future<bool> _runDialogAction({
    required Future<Either<Failure, void>> Function() task,
    required bool refreshMember,
  }) async {
    emit(state.copyWith(clearFailure: true, clearCompleted: true));

    final result = await task();
    if (isClosed) return false;

    return result.fold(
      (Failure failure) {
        emit(state.copyWith(failure: failure));
        return false;
      },
      (_) async {
        await _syncConnectedApis(refreshMember: refreshMember);
        if (isClosed) return false;
        emit(state.copyWith(projectMembersChanged: true));
        return true;
      },
    );
  }

  void clearStatus() {
    emit(
      state.copyWith(
        clearFailure: true,

        clearCompleted: true,

        loadingAction: null,

        isActionLoading: false,
      ),
    );
  }

  static String messageForFailure(Failure failure) =>
      FailureMapper.userMessage(failure);

  static String titleForFailure(Failure failure) =>
      FailureMapper.dialogTitle(failure);
}
