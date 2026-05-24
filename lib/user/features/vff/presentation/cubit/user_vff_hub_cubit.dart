import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vestie/core/error/failures.dart';
import 'package:vestie/core/error/failure_mapper.dart';

import '../../domain/usecases/vff_usecases.dart';
import '../mappers/user_vff_hub_mapper.dart';
import '../models/user_vff_hub_ui_model.dart';
import '../models/user_vff_inbox_action.dart';
import 'user_vff_hub_state.dart';
import 'user_vff_inbox_sync_mixin.dart';

final class UserVffHubCubit extends Cubit<UserVffHubState>
    with UserVffInboxSyncMixin {
  UserVffHubCubit({
    required ListMyVffsUseCase listMyVffsUseCase,
    required GetVffReceivedInboxUseCase getVffReceivedInboxUseCase,
    required AcceptVffRequestUseCase acceptVffRequestUseCase,
    required DeclineVffRequestUseCase declineVffRequestUseCase,
    required AcceptVffProjectInviteUseCase acceptVffProjectInviteUseCase,
    required DeclineVffProjectInviteUseCase declineVffProjectInviteUseCase,
  })  : _listMyVffsUseCase = listMyVffsUseCase,
        _getVffReceivedInboxUseCase = getVffReceivedInboxUseCase,
        _acceptVffRequestUseCase = acceptVffRequestUseCase,
        _declineVffRequestUseCase = declineVffRequestUseCase,
        _acceptVffProjectInviteUseCase = acceptVffProjectInviteUseCase,
        _declineVffProjectInviteUseCase = declineVffProjectInviteUseCase,
        super(const UserVffHubState());

  final ListMyVffsUseCase _listMyVffsUseCase;
  final GetVffReceivedInboxUseCase _getVffReceivedInboxUseCase;
  final AcceptVffRequestUseCase _acceptVffRequestUseCase;
  final DeclineVffRequestUseCase _declineVffRequestUseCase;
  final AcceptVffProjectInviteUseCase _acceptVffProjectInviteUseCase;
  final DeclineVffProjectInviteUseCase _declineVffProjectInviteUseCase;

  @override
  GetVffReceivedInboxUseCase get inboxUseCase => _getVffReceivedInboxUseCase;

  @override
  ListMyVffsUseCase? get myVffsUseCase => _listMyVffsUseCase;

  Future<void> load() async {
    await _fetchMyVffs(silent: false);
  }

  /// Refreshes My VFFs after profile remove without a full-tab shimmer.
  Future<void> refreshMyVffsSilently() async {
    final connections = await syncMyVffs();
    if (isClosed || connections == null) return;
    emit(
      state.copyWith(
        myVffConnections: connections,
        loadStatus: UserVffHubLoadStatus.loaded,
        clearError: true,
      ),
    );
  }

  /// Refreshes inbox preview after returning from a full list screen.
  Future<void> refreshReceivedInboxSilently() async {
    final inbox = await syncReceivedInbox();
    if (isClosed || inbox == null) return;
    emit(
      state.copyWith(
        incomingVffRequests: inbox.incoming,
        groupInvitations: inbox.invites,
        requestsLoadStatus: UserVffHubRequestsLoadStatus.loaded,
        clearRequestsError: true,
      ),
    );
  }

  Future<void> loadReceivedInbox({bool force = false, bool silent = false}) async {
    if (!silent &&
        state.requestsLoadStatus == UserVffHubRequestsLoadStatus.loading) {
      return;
    }
    if (!force &&
        !silent &&
        state.requestsLoadStatus == UserVffHubRequestsLoadStatus.loaded) {
      return;
    }
    await _fetchReceivedInbox(silent: silent);
  }

  Future<void> _fetchMyVffs({required bool silent}) async {
    if (!silent) {
      emit(
        state.copyWith(
          loadStatus: UserVffHubLoadStatus.loading,
          clearError: true,
        ),
      );
    }

    final vffsResult = await _listMyVffsUseCase();
    if (isClosed) return;

    String? errorMessage;
    var connections = state.myVffConnections;

    vffsResult.fold(
      (f) => errorMessage = FailureMapper.userMessage(f),
      (list) => connections =
          list.map(UserVffHubMapper.connection).toList(growable: false),
    );

    emit(
      state.copyWith(
        loadStatus: errorMessage != null && connections.isEmpty && !silent
            ? UserVffHubLoadStatus.error
            : UserVffHubLoadStatus.loaded,
        errorMessage: errorMessage,
        myVffConnections: connections,
      ),
    );
  }

  Future<void> _fetchReceivedInbox({required bool silent}) async {
    if (!silent) {
      emit(
        state.copyWith(
          requestsLoadStatus: UserVffHubRequestsLoadStatus.loading,
          clearRequestsError: true,
        ),
      );
    }

    if (silent) {
      final inbox = await syncReceivedInbox();
      if (isClosed || inbox == null) return;
      emit(
        state.copyWith(
          incomingVffRequests: inbox.incoming,
          groupInvitations: inbox.invites,
          requestsLoadStatus: UserVffHubRequestsLoadStatus.loaded,
        ),
      );
      return;
    }

    final inboxResult = await _getVffReceivedInboxUseCase();
    if (isClosed) return;

    String? requestsErrorMessage;
    var incoming = state.incomingVffRequests;
    var invites = state.groupInvitations;

    inboxResult.fold(
      (f) => requestsErrorMessage = FailureMapper.userMessage(f),
      (inbox) {
        incoming = inbox.vffRequests
            .map(UserVffHubMapper.inboxRequest)
            .toList(growable: false);
        invites = inbox.projectInvites
            .map(UserVffHubMapper.projectInvite)
            .toList(growable: false);
      },
    );

    emit(
      state.copyWith(
        requestsLoadStatus: requestsErrorMessage != null &&
                incoming.isEmpty &&
                invites.isEmpty
            ? UserVffHubRequestsLoadStatus.error
            : UserVffHubRequestsLoadStatus.loaded,
        requestsErrorMessage: requestsErrorMessage,
        incomingVffRequests: incoming,
        groupInvitations: invites,
      ),
    );
  }

  Future<void> _syncAfterMutation({required bool refreshMyVffs}) async {
    final inbox = await syncReceivedInbox();
    if (isClosed) return;

    List<UserVffConnectionRowUi>? connections;
    if (refreshMyVffs) {
      connections = await syncMyVffs();
    }
    if (isClosed) return;

    emit(
      state.copyWith(
        incomingVffRequests: inbox?.incoming ?? state.incomingVffRequests,
        groupInvitations: inbox?.invites ?? state.groupInvitations,
        myVffConnections: connections ?? state.myVffConnections,
        requestsLoadStatus: UserVffHubRequestsLoadStatus.loaded,
        loadStatus: UserVffHubLoadStatus.loaded,
        clearRequestsError: true,
      ),
    );
  }

  void selectTab(int index) {
    emit(state.copyWith(tabIndex: index));
    if (index == 1) {
      final alreadyLoaded =
          state.requestsLoadStatus == UserVffHubRequestsLoadStatus.loaded;
      loadReceivedInbox(force: alreadyLoaded, silent: alreadyLoaded);
    } else if (index == 0 &&
        state.loadStatus == UserVffHubLoadStatus.loaded) {
      _fetchMyVffs(silent: true);
    }
  }

  void seedFromDemo(UserVffHubUiModel hub) {
    emit(UserVffHubState.fromHub(hub));
  }

  Future<bool> acceptVffRequest(UserVffIncomingRequestUi row) {
    return _runInboxAction(
      call: () => _acceptVffRequestUseCase(row.id),
      itemId: row.id,
      kind: UserVffInboxItemKind.vffRequest,
      isAccept: true,
      refreshMyVffs: true,
    );
  }

  Future<bool> declineVffRequest(UserVffIncomingRequestUi row) {
    return _runInboxAction(
      call: () => _declineVffRequestUseCase(row.id),
      itemId: row.id,
      kind: UserVffInboxItemKind.vffRequest,
      isAccept: false,
      refreshMyVffs: false,
    );
  }

  Future<bool> acceptProjectInvite(UserVffGroupInviteUi row) {
    if (row.projectId.isEmpty) return Future.value(false);
    return _runInboxAction(
      call: () => _acceptVffProjectInviteUseCase(
        projectId: row.projectId,
        inviteId: row.id,
      ),
      itemId: row.id,
      kind: UserVffInboxItemKind.projectInvite,
      isAccept: true,
      refreshMyVffs: false,
    );
  }

  Future<bool> declineProjectInvite(UserVffGroupInviteUi row) {
    if (row.projectId.isEmpty) return Future.value(false);
    return _runInboxAction(
      call: () => _declineVffProjectInviteUseCase(
        projectId: row.projectId,
        inviteId: row.id,
      ),
      itemId: row.id,
      kind: UserVffInboxItemKind.projectInvite,
      isAccept: false,
      refreshMyVffs: false,
    );
  }

  Future<bool> _runInboxAction({
    required Future<Either<Failure, dynamic>> Function() call,
    required String itemId,
    required UserVffInboxItemKind kind,
    required bool isAccept,
    required bool refreshMyVffs,
  }) async {
    if (state.actingRow != null) return false;

    emit(
      state.copyWith(
        actingRow: UserVffInboxRowAction(
          itemId: itemId,
          kind: kind,
          isAccept: isAccept,
        ),
        clearError: true,
        clearRequestsError: true,
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
        await _syncAfterMutation(refreshMyVffs: refreshMyVffs);
        if (isClosed) return false;
        emit(state.copyWith(clearActingRow: true));
        return true;
      },
    );
  }
}
