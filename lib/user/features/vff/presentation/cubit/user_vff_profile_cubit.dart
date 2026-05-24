import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vestie/app/router/route_args/user_vff_flow_args.dart';
import 'package:vestie/core/error/failure_mapper.dart';

import '../../domain/usecases/vff_usecases.dart';
import '../mappers/user_vff_profile_mapper.dart';
import '../models/user_vff_profile_ui_model.dart';
import 'user_vff_profile_state.dart';

final class UserVffProfileCubit extends Cubit<UserVffProfileState> {
  UserVffProfileCubit({
    required GetConnectedVffProfileUseCase getConnectedVffProfileUseCase,
    required GetPublicVffProfileUseCase getPublicVffProfileUseCase,
    required SendVffRequestUseCase sendVffRequestUseCase,
    required RemoveVffConnectionUseCase removeVffConnectionUseCase,
    required JoinFromVffProfileUseCase joinFromVffProfileUseCase,
  })  : _getConnectedVffProfileUseCase = getConnectedVffProfileUseCase,
        _getPublicVffProfileUseCase = getPublicVffProfileUseCase,
        _sendVffRequestUseCase = sendVffRequestUseCase,
        _removeVffConnectionUseCase = removeVffConnectionUseCase,
        _joinFromVffProfileUseCase = joinFromVffProfileUseCase,
        super(const UserVffProfileState());

  final GetConnectedVffProfileUseCase _getConnectedVffProfileUseCase;
  final GetPublicVffProfileUseCase _getPublicVffProfileUseCase;
  final SendVffRequestUseCase _sendVffRequestUseCase;
  final RemoveVffConnectionUseCase _removeVffConnectionUseCase;
  final JoinFromVffProfileUseCase _joinFromVffProfileUseCase;

  String? _userId;
  bool _loadAsConnected = false;

  UserVffProfilePopResult? get profilePopResult {
    if (state.vffRequestSent) {
      return UserVffProfilePopResult.vffRequestSent;
    }
    return null;
  }

  void seedPreview(UserVffProfileUiModel profile) {
    emit(
      UserVffProfileState(
        loadStatus: UserVffProfileLoadStatus.loaded,
        profile: profile,
      ),
    );
  }

  Future<void> load({
    required String userId,
    required bool loadAsConnected,
    String? projectId,
  }) async {
    _userId = userId;
    _loadAsConnected = loadAsConnected;

    emit(
      state.copyWith(
        loadStatus: UserVffProfileLoadStatus.loading,
        projectId: projectId,
        clearError: true,
        clearFooterOverride: true,
      ),
    );

  if (loadAsConnected) {
      final result = await _getConnectedVffProfileUseCase(userId);
      if (isClosed) return;
      result.fold(
        (failure) => emit(
          state.copyWith(
            loadStatus: UserVffProfileLoadStatus.error,
            errorMessage: FailureMapper.userMessage(failure),
          ),
        ),
        (entity) => emit(
          state.copyWith(
            loadStatus: UserVffProfileLoadStatus.loaded,
            profile: UserVffProfileMapper.connected(entity),
          ),
        ),
      );
      return;
    }

    final result = await _getPublicVffProfileUseCase(userId);
    if (isClosed) return;
    result.fold(
      (failure) => emit(
        state.copyWith(
          loadStatus: UserVffProfileLoadStatus.error,
          errorMessage: FailureMapper.userMessage(failure),
        ),
      ),
      (entity) {
        final canSend = projectId != null &&
            projectId.trim().isNotEmpty &&
            !entity.isVffConnected;
        emit(
          state.copyWith(
            loadStatus: UserVffProfileLoadStatus.loaded,
            profile: UserVffProfileMapper.public(
              entity,
              canSendVffRequest: canSend,
            ),
          ),
        );
      },
    );
  }

  Future<bool> sendVffRequest() async {
    final projectId = state.projectId?.trim();
    final userId = _userId?.trim();
    if (projectId == null ||
        projectId.isEmpty ||
        userId == null ||
        userId.isEmpty ||
        state.isFooterBusy) {
      return false;
    }

    emit(state.copyWith(isActionLoading: true, clearError: true));

    final result = await _sendVffRequestUseCase(
      projectId: projectId,
      userId: userId,
    );

    if (isClosed) return false;

    var ok = false;
    result.fold(
      (failure) => emit(
        state.copyWith(
          isActionLoading: false,
          errorMessage: FailureMapper.userMessage(failure),
        ),
      ),
      (_) {
        ok = true;
        emit(
          state.copyWith(
            isActionLoading: false,
            footerOverride: UserVffProfileFooterMode.requestSent,
            vffRequestSent: true,
          ),
        );
      },
    );
    return ok;
  }

  Future<bool> removeVffConnection() async {
    final userId = _userId?.trim();
    if (userId == null ||
        userId.isEmpty ||
        state.isFooterBusy) {
      return false;
    }

    emit(state.copyWith(isRemoveVffLoading: true, clearError: true));

    final result = await _removeVffConnectionUseCase(userId);

    if (isClosed) return false;

    return await result.fold(
      (failure) async {
        emit(
          state.copyWith(
            isRemoveVffLoading: false,
            errorMessage: FailureMapper.userMessage(failure),
          ),
        );
        return false;
      },
      (_) async {
        emit(state.copyWith(isRemoveVffLoading: false));
        return true;
      },
    );
  }

  Future<bool> joinFromVff(String projectId) async {
    final trimmed = projectId.trim();
    if (trimmed.isEmpty || state.isActionLoading) return false;

    emit(state.copyWith(isActionLoading: true, clearError: true));

    final result = await _joinFromVffProfileUseCase(projectId: trimmed);

    if (isClosed) return false;

    var ok = false;
    await result.fold(
      (failure) async {
        emit(
          state.copyWith(
            isActionLoading: false,
            errorMessage: FailureMapper.userMessage(failure),
          ),
        );
      },
      (_) async {
        ok = true;
        emit(state.copyWith(isActionLoading: false));
        final userId = _userId;
        if (userId != null) {
          await load(
            userId: userId,
            loadAsConnected: _loadAsConnected,
            projectId: state.projectId,
          );
        }
      },
    );
    return ok;
  }
}
