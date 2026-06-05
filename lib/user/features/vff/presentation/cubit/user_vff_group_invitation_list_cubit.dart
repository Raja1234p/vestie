import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/error/failures.dart';
import 'package:vestie/core/error/failure_mapper.dart';

import '../../domain/usecases/vff_usecases.dart';
import '../mappers/user_vff_hub_mapper.dart';
import '../models/user_vff_hub_ui_model.dart';
import '../models/user_vff_inbox_action.dart';
import 'user_vff_inbox_mutation_guard_mixin.dart';
import 'user_vff_inbox_sync_mixin.dart';

enum UserVffGroupInvitationListStatus { loading, loaded, error }

final class UserVffGroupInvitationListState extends Equatable {
  final UserVffGroupInvitationListStatus status;
  final List<UserVffGroupInviteUi> items;
  final String? errorMessage;
  final UserVffInboxRowAction? actingRow;

  const UserVffGroupInvitationListState({
    this.status = UserVffGroupInvitationListStatus.loading,
    this.items = const [],
    this.errorMessage,
    this.actingRow,
  });

  UserVffGroupInvitationListState copyWith({
    UserVffGroupInvitationListStatus? status,
    List<UserVffGroupInviteUi>? items,
    String? errorMessage,
    bool clearError = false,
    UserVffInboxRowAction? actingRow,
    bool clearActingRow = false,
  }) {
    return UserVffGroupInvitationListState(
      status: status ?? this.status,
      items: items ?? this.items,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      actingRow: clearActingRow ? null : (actingRow ?? this.actingRow),
    );
  }

  @override
  List<Object?> get props => [status, items, errorMessage, actingRow];
}

final class UserVffGroupInvitationListCubit
    extends Cubit<UserVffGroupInvitationListState>
    with UserVffInboxSyncMixin, UserVffInboxMutationGuardMixin {
  UserVffGroupInvitationListCubit({
    required GetVffReceivedInboxUseCase getVffReceivedInboxUseCase,
    required AcceptVffProjectInviteUseCase acceptVffProjectInviteUseCase,
    required DeclineVffProjectInviteUseCase declineVffProjectInviteUseCase,
  })  : _getVffReceivedInboxUseCase = getVffReceivedInboxUseCase,
        _acceptVffProjectInviteUseCase = acceptVffProjectInviteUseCase,
        _declineVffProjectInviteUseCase = declineVffProjectInviteUseCase,
        super(const UserVffGroupInvitationListState()) {
    load();
  }

  final GetVffReceivedInboxUseCase _getVffReceivedInboxUseCase;
  final AcceptVffProjectInviteUseCase _acceptVffProjectInviteUseCase;
  final DeclineVffProjectInviteUseCase _declineVffProjectInviteUseCase;

  @override
  GetVffReceivedInboxUseCase get inboxUseCase => _getVffReceivedInboxUseCase;

  @override
  ListMyVffsUseCase? get myVffsUseCase => null;

  Future<void> load() async {
    emit(
      state.copyWith(
        status: UserVffGroupInvitationListStatus.loading,
        clearError: true,
      ),
    );

    final result = await _getVffReceivedInboxUseCase();
    if (isClosed) return;

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: UserVffGroupInvitationListStatus.error,
          errorMessage: FailureMapper.userMessage(failure),
        ),
      ),
      (inbox) => emit(
        state.copyWith(
          status: UserVffGroupInvitationListStatus.loaded,
          items: inbox.projectInvites
              .map(UserVffHubMapper.projectInvite)
              .toList(growable: false),
        ),
      ),
    );
  }

  Future<void> _reloadAfterMutation() async {
    final reloadResult = await reloadReceivedInbox();
    if (isClosed) return;

    reloadResult.fold(
      (failure) => emit(
        state.copyWith(
          errorMessage: FailureMapper.userMessage(failure),
        ),
      ),
      (inbox) => emit(
        state.copyWith(
          status: UserVffGroupInvitationListStatus.loaded,
          items: inbox.invites,
          clearError: true,
        ),
      ),
    );
  }

  Future<bool> accept(UserVffGroupInviteUi row) {
    if (row.projectId.isEmpty) {
      emit(state.copyWith(errorMessage: AppStrings.errorGeneric));
      return Future.value(false);
    }
    return _run(
      () => _acceptVffProjectInviteUseCase(
        projectId: row.projectId,
        inviteId: row.id,
      ),
      row: row,
      isAccept: true,
    );
  }

  Future<bool> decline(UserVffGroupInviteUi row) {
    if (row.projectId.isEmpty) {
      emit(state.copyWith(errorMessage: AppStrings.errorGeneric));
      return Future.value(false);
    }
    return _run(
      () => _declineVffProjectInviteUseCase(
        projectId: row.projectId,
        inviteId: row.id,
      ),
      row: row,
      isAccept: false,
    );
  }

  Future<bool> _run(
    Future<Either<Failure, dynamic>> Function() call, {
    required UserVffGroupInviteUi row,
    required bool isAccept,
  }) async {
    if (!beginInboxMutation()) return false;
    if (state.actingRow != null) {
      endInboxMutation();
      return false;
    }

    try {
      emit(
        state.copyWith(
          actingRow: UserVffInboxRowAction(
            itemId: row.id,
            kind: UserVffInboxItemKind.projectInvite,
            isAccept: isAccept,
          ),
          clearError: true,
        ),
      );

      final result = await call();
      if (isClosed) return false;

      return await result.fold(
        (failure) async {
          emit(
            state.copyWith(
              clearActingRow: true,
              errorMessage: FailureMapper.userMessage(failure),
            ),
          );
          return false;
        },
        (_) async {
          emit(
            state.copyWith(
              items: state.items
                  .where((item) => item.id != row.id)
                  .toList(growable: false),
              clearActingRow: true,
            ),
          );
          await _reloadAfterMutation();
          if (isClosed) return false;
          return true;
        },
      );
    } finally {
      endInboxMutation();
    }
  }
}
