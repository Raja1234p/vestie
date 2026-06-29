import 'package:dartz/dartz.dart';

import 'package:vestie/core/domain/entities/paginated_result.dart';
import 'package:vestie/core/error/failures.dart';
import 'package:vestie/core/models/pagination_dto.dart';

import '../entities/vff_connection_entity.dart';
import '../entities/vff_inbox_entity.dart';
import '../entities/vff_profile_entity.dart';

abstract class VffRepository {
  Future<Either<Failure, PaginatedResult<VffConnectionEntity>>> listMyVffs({
    int page = PaginationQuery.defaultPage,
    int? pageSize,
  });

  Future<Either<Failure, VffConnectedProfileEntity>> getConnectedProfile(
    String userId, {
    int projectsPage = PaginationQuery.defaultPage,
    int? projectsPageSize,
  });

  Future<Either<Failure, VffPublicProfileEntity>> getPublicProfile(
    String userId, {
    int projectsPage = PaginationQuery.defaultPage,
    int? projectsPageSize,
  });

  Future<Either<Failure, VffRemoveConnectionResultEntity>> removeConnection(
    String userId,
  );

  Future<Either<Failure, VffReceivedInboxEntity>> getReceivedInbox({
    int vffRequestsPage = PaginationQuery.defaultPage,
    int? vffRequestsPageSize,
    int projectInvitesPage = PaginationQuery.defaultPage,
    int? projectInvitesPageSize,
  });

  Future<Either<Failure, VffSentInboxEntity>> getSentInbox({
    int vffRequestsPage = PaginationQuery.defaultPage,
    int? vffRequestsPageSize,
    int projectInvitesPage = PaginationQuery.defaultPage,
    int? projectInvitesPageSize,
    int joinRequestsPage = PaginationQuery.defaultPage,
    int? joinRequestsPageSize,
  });

  Future<Either<Failure, VffSendRequestResultEntity>> sendVffRequest({
    required String projectId,
    required String userId,
  });

  Future<Either<Failure, VffInboxRequestEntity>> acceptVffRequest(
    String requestId,
  );

  Future<Either<Failure, VffInboxRequestEntity>> declineVffRequest(
    String requestId,
  );

  Future<Either<Failure, List<VffInviteResultEntity>>> inviteVffsToProject({
    required String projectId,
    required List<String> userIds,
  });

  Future<Either<Failure, VffInviteResultEntity>> acceptProjectInvite({
    required String projectId,
    required String inviteId,
  });

  Future<Either<Failure, VffInviteResultEntity>> declineProjectInvite({
    required String projectId,
    required String inviteId,
  });

  Future<Either<Failure, VffJoinFromVffResultEntity>> joinFromVffProfile({
    required String projectId,
  });
}
