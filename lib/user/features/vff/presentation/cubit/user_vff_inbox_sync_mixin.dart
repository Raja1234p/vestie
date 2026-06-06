import 'package:dartz/dartz.dart';

import 'package:vestie/core/error/failures.dart';

import '../../domain/entities/vff_inbox_entity.dart';
import '../../domain/usecases/vff_usecases.dart';
import '../mappers/user_vff_hub_mapper.dart';
import '../models/user_vff_hub_ui_model.dart';

/// Shared silent refresh after inbox accept / decline.
mixin UserVffInboxSyncMixin {
  GetVffReceivedInboxUseCase get inboxUseCase;

  ListMyVffsUseCase? get myVffsUseCase;

  /// Maps received inbox to UI rows.
  ({
    List<UserVffIncomingRequestUi> incoming,
    List<UserVffGroupInviteUi> invites,
  })
  _mapReceivedInbox(VffReceivedInboxEntity inbox) => (
    incoming: inbox.vffRequests
        .map(UserVffHubMapper.inboxRequest)
        .toList(growable: false),
    invites: inbox.projectInvites
        .map(UserVffHubMapper.projectInvite)
        .toList(growable: false),
  );

  /// Returns `null` on API failure so callers keep the current lists.
  Future<
    ({
      List<UserVffIncomingRequestUi> incoming,
      List<UserVffGroupInviteUi> invites,
    })?
  >
  syncReceivedInbox() async {
    final result = await inboxUseCase();
    return result.fold((_) => null, _mapReceivedInbox);
  }

  /// Reload after accept / decline — surfaces API failure to the caller.
  Future<
    Either<
      Failure,
      ({
        List<UserVffIncomingRequestUi> incoming,
        List<UserVffGroupInviteUi> invites,
      })
    >
  >
  reloadReceivedInbox() async {
    final result = await inboxUseCase();
    return result.map(_mapReceivedInbox);
  }

  Future<List<UserVffConnectionRowUi>?> syncMyVffs() async {
    final listUseCase = myVffsUseCase;
    if (listUseCase == null) return null;

    final Either<Failure, dynamic> result = await listUseCase();
    return result.fold(
      (_) => null,
      (list) => list
          .map<UserVffConnectionRowUi>(UserVffHubMapper.connection)
          .toList(growable: false),
    );
  }
}
