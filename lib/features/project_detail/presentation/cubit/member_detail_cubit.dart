import 'package:dartz/dartz.dart';

import 'package:equatable/equatable.dart';

import 'package:flutter_bloc/flutter_bloc.dart';



import '../../../../core/error/failure_mapper.dart';
import '../../../../core/error/failures.dart';

import '../../domain/entities/member_activity_entity.dart';

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



  const MemberDetailState({

    this.loadStatus = MemberDetailLoadStatus.initial,

    this.activity,

    this.loadErrorMessage,

    this.isActionLoading = false,

    this.loadingAction,

    this.failure,

    this.completedAction,

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

      ];

}



class MemberDetailCubit extends Cubit<MemberDetailState> {

  MemberDetailCubit({

    required GetMemberActivityUseCase getMemberActivityUseCase,

    required AssignCoLeaderUseCase assignCoLeaderUseCase,

    required RemoveCoLeaderUseCase removeCoLeaderUseCase,

    required RemoveMemberUseCase removeMemberUseCase,

  })  : _getMemberActivityUseCase = getMemberActivityUseCase,

        _assignCoLeaderUseCase = assignCoLeaderUseCase,

        _removeCoLeaderUseCase = removeCoLeaderUseCase,

        _removeMemberUseCase = removeMemberUseCase,

        super(const MemberDetailState());



  final GetMemberActivityUseCase _getMemberActivityUseCase;

  final AssignCoLeaderUseCase _assignCoLeaderUseCase;

  final RemoveCoLeaderUseCase _removeCoLeaderUseCase;

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



  Future<void> assignCoLeader({

    required String projectId,

    required String userId,

  }) =>

      _run(

        action: MemberDetailAction.assignCoLeader,

        task: () => _assignCoLeaderUseCase(

          projectId: projectId,

          userId: userId,

        ),

      );



  Future<void> removeCoLeader({

    required String projectId,

    required String userId,

  }) =>

      _run(

        action: MemberDetailAction.removeCoLeader,

        task: () => _removeCoLeaderUseCase(

          projectId: projectId,

          userId: userId,

        ),

      );



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
        emit(
          state.copyWith(
            isActionLoading: false,
            loadingAction: null,
            completedAction: action,
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


