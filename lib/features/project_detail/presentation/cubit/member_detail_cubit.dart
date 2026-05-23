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



enum MemberDetailAction { assignCoLeader, removeCoLeader, removeMember }



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

  final bool vffRequestSent;

  final bool isVffRequestLoading;



  const MemberDetailState({

    this.loadStatus = MemberDetailLoadStatus.initial,

    this.activity,

    this.loadErrorMessage,

    this.isActionLoading = false,

    this.loadingAction,

    this.failure,

    this.completedAction,

    this.projectMembersChanged = false,

    this.vffRequestSent = false,

    this.isVffRequestLoading = false,

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

    bool? vffRequestSent,

    bool? isVffRequestLoading,

    bool clearLoadError = false,

    bool clearFailure = false,

    bool clearCompleted = false,

    bool clearActivity = false,

  }) {

    return MemberDetailState(

      loadStatus: loadStatus ?? this.loadStatus,

      activity: clearActivity ? null : (activity ?? this.activity),

      loadErrorMessage:

          clearLoadError ? null : (loadErrorMessage ?? this.loadErrorMessage),

      isActionLoading: isActionLoading ?? this.isActionLoading,

      loadingAction: loadingAction,

      failure: clearFailure ? null : (failure ?? this.failure),

      completedAction:

          clearCompleted ? null : (completedAction ?? this.completedAction),

      projectMembersChanged:

          projectMembersChanged ?? this.projectMembersChanged,

      vffRequestSent: vffRequestSent ?? this.vffRequestSent,

      isVffRequestLoading:

          isVffRequestLoading ?? this.isVffRequestLoading,

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

        vffRequestSent,

        isVffRequestLoading,

      ];

}



class MemberDetailCubit extends Cubit<MemberDetailState> {

  MemberDetailCubit({

    required GetMemberActivityUseCase getMemberActivityUseCase,

    required UpdateCoLeaderRoleUseCase updateCoLeaderRoleUseCase,

    required RemoveMemberUseCase removeMemberUseCase,

  })  : _getMemberActivityUseCase = getMemberActivityUseCase,

        _updateCoLeaderRoleUseCase = updateCoLeaderRoleUseCase,

        _removeMemberUseCase = removeMemberUseCase,

        super(const MemberDetailState());



  final GetMemberActivityUseCase _getMemberActivityUseCase;

  final UpdateCoLeaderRoleUseCase _updateCoLeaderRoleUseCase;

  final RemoveMemberUseCase _removeMemberUseCase;

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
        emit(
          state.copyWith(
            loadStatus: MemberDetailLoadStatus.loaded,
            activity: activity,
            clearLoadError: true,
          ),
        );
      },
    );
    return ok;
  }



  /// Sends a VFF request in place — UI switches to “VFF Request Sent” (no navigation).
  Future<void> sendVffRequest() async {
    if (state.vffRequestSent || state.isVffRequestLoading) return;

    emit(state.copyWith(isVffRequestLoading: true, clearFailure: true));

    // TODO: wire member VFF request API when available (profile flow is local today).
    await Future<void>.delayed(Duration.zero);

    if (isClosed) return;
    emit(
      state.copyWith(
        isVffRequestLoading: false,
        vffRequestSent: true,
      ),
    );
  }

  Future<void> assignCoLeader({

    required String projectId,

    required String userId,

  }) {

    return _setCoLeaderRole(

      projectId: projectId,

      userId: userId,

      assign: true,

    );

  }



  Future<void> removeCoLeader({

    required String projectId,

    required String userId,

  }) {

    return _setCoLeaderRole(

      projectId: projectId,

      userId: userId,

      assign: false,

    );

  }



  Future<void> _setCoLeaderRole({

    required String projectId,

    required String userId,

    required bool assign,

  }) async {
    final resolvedUserId = userId.trim().isNotEmpty
        ? userId.trim()
        : (_userId ?? '').trim();
    if (resolvedUserId.isEmpty) {
      emit(
        state.copyWith(
          failure: const ServerFailure(AppStrings.errorGeneric),
        ),
      );
      return;
    }

    await _run(

      action: assign

          ? MemberDetailAction.assignCoLeader

          : MemberDetailAction.removeCoLeader,

      task: () => _updateCoLeaderRoleUseCase(

        projectId: projectId,

        userId: resolvedUserId,

        assign: assign,

      ),

    );
  }



  Future<void> removeMember({

    required String projectId,

    required String userId,

  }) =>

      _run(

        action: MemberDetailAction.removeMember,

        task: () => _removeMemberUseCase(

          projectId: projectId,

          userId: userId,

        ),

      );



  Future<void> _run({

    required MemberDetailAction action,

    required Future<Either<Failure, void>> Function() task,

  }) async {

    if (state.isActionLoading) return;



    emit(

      state.copyWith(

        isActionLoading: true,

        loadingAction: action,

        clearFailure: true,

        clearCompleted: true,

      ),

    );



    final result = await task();

    await result.fold(
      (Failure failure) async {
        emit(
          state.copyWith(
            isActionLoading: false,
            loadingAction: null,
            failure: failure,
          ),
        );
      },
      (_) async {
        if (action != MemberDetailAction.removeMember) {
          await refresh();
        }
        final coLeaderChanged = action == MemberDetailAction.assignCoLeader ||
            action == MemberDetailAction.removeCoLeader;
        emit(
          state.copyWith(
            isActionLoading: false,
            loadingAction: null,
            completedAction: action,
            projectMembersChanged:
                coLeaderChanged || state.projectMembersChanged,
          ),
        );
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


