import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vestie/core/error/failures.dart';
import 'package:vestie/core/error/failure_mapper.dart';

import '../../domain/usecases/vff_usecases.dart';
import '../mappers/user_vff_hub_mapper.dart';
import '../models/user_vff_hub_ui_model.dart';
import '../models/user_vff_inbox_action.dart';
import 'user_vff_inbox_sync_mixin.dart';

enum UserVffIncomingRequestListStatus { loading, loaded, error }

final class UserVffIncomingRequestListState extends Equatable {
  final UserVffIncomingRequestListStatus status;
  final List<UserVffIncomingRequestUi> items;
  final String? errorMessage;
  final UserVffInboxRowAction? actingRow;

  const UserVffIncomingRequestListState({
    this.status = UserVffIncomingRequestListStatus.loading,
    this.items = const [],
    this.errorMessage,
    this.actingRow,
  });

  UserVffIncomingRequestListState copyWith({
    UserVffIncomingRequestListStatus? status,
    List<UserVffIncomingRequestUi>? items,
    String? errorMessage,
    bool clearError = false,
    UserVffInboxRowAction? actingRow,
    bool clearActingRow = false,
  }) {
    return UserVffIncomingRequestListState(
      status: status ?? this.status,
      items: items ?? this.items,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      actingRow: clearActingRow ? null : (actingRow ?? this.actingRow),
    );
  }

  @override
  List<Object?> get props => [status, items, errorMessage, actingRow];
}

final class UserVffIncomingRequestListCubit
    extends Cubit<UserVffIncomingRequestListState>
    with UserVffInboxSyncMixin {
  UserVffIncomingRequestListCubit({
    required GetVffReceivedInboxUseCase getVffReceivedInboxUseCase,
    required AcceptVffRequestUseCase acceptVffRequestUseCase,
    required DeclineVffRequestUseCase declineVffRequestUseCase,
    required ListMyVffsUseCase listMyVffsUseCase,
  })  : _getVffReceivedInboxUseCase = getVffReceivedInboxUseCase,
        _acceptVffRequestUseCase = acceptVffRequestUseCase,
        _declineVffRequestUseCase = declineVffRequestUseCase,
        _listMyVffsUseCase = listMyVffsUseCase,
        super(const UserVffIncomingRequestListState()) {
    load();
  }

  final GetVffReceivedInboxUseCase _getVffReceivedInboxUseCase;
  final AcceptVffRequestUseCase _acceptVffRequestUseCase;
  final DeclineVffRequestUseCase _declineVffRequestUseCase;
  final ListMyVffsUseCase _listMyVffsUseCase;

  @override
  GetVffReceivedInboxUseCase get inboxUseCase => _getVffReceivedInboxUseCase;

  @override
  ListMyVffsUseCase? get myVffsUseCase => _listMyVffsUseCase;

  Future<void> load() async {
    emit(
      state.copyWith(
        status: UserVffIncomingRequestListStatus.loading,
        clearError: true,
      ),
    );

    final result = await _getVffReceivedInboxUseCase();
    if (isClosed) return;

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: UserVffIncomingRequestListStatus.error,
          errorMessage: FailureMapper.userMessage(failure),
        ),
      ),
      (inbox) => emit(
        state.copyWith(
          status: UserVffIncomingRequestListStatus.loaded,
          items: inbox.vffRequests
              .map(UserVffHubMapper.inboxRequest)
              .toList(growable: false),
        ),
      ),
    );
  }

  Future<void> _reloadSilent() async {
    final inbox = await syncReceivedInbox();
    if (isClosed || inbox == null) return;
    emit(
      state.copyWith(
        status: UserVffIncomingRequestListStatus.loaded,
        items: inbox.incoming,
      ),
    );
  }

  Future<bool> accept(UserVffIncomingRequestUi row) {
    return _run(
      () => _acceptVffRequestUseCase(row.id),
      row: row,
      isAccept: true,
      refreshMyVffs: true,
    );
  }

  Future<bool> decline(UserVffIncomingRequestUi row) {
    return _run(
      () => _declineVffRequestUseCase(row.id),
      row: row,
      isAccept: false,
      refreshMyVffs: false,
    );
  }

  Future<bool> _run(
    Future<Either<Failure, dynamic>> Function() call, {
    required UserVffIncomingRequestUi row,
    required bool isAccept,
    required bool refreshMyVffs,
  }) async {
    if (state.actingRow != null) return false;

    emit(
      state.copyWith(
        actingRow: UserVffInboxRowAction(
          itemId: row.id,
          kind: UserVffInboxItemKind.vffRequest,
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
        await _reloadSilent();
        if (refreshMyVffs) {
          await syncMyVffs();
        }
        if (isClosed) return false;
        emit(state.copyWith(clearActingRow: true));
        return true;
      },
    );
  }
}
