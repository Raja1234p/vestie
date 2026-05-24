import 'package:vestie/core/widgets/common/invite_vff_pick_ui.dart';
import 'package:vestie/features/project_detail/domain/entities/member_entity_extensions.dart';
import 'package:vestie/features/project_detail/domain/entities/project_detail_entity.dart';

import '../../data/models/vff_json_parsing.dart';
import '../../domain/entities/vff_connection_entity.dart';
import 'user_vff_profile_mapper.dart';

abstract final class InviteMembersMapper {
  static InviteVffPickUi fromConnection(VffConnectionEntity entity) {
    return InviteVffPickUi(
      id: entity.userId,
      name: entity.fullName,
      initials: UserVffHubMapperInitials.initials(entity.fullName),
      photoUrl: entity.profilePhotoUrl,
    );
  }

  /// User ids already in [project] — normalized for comparison with VFF rows.
  static Set<String> excludeUserIdsForProject(ProjectDetailEntity project) {
    return project.members
        .map((m) => VffJsonParsing.normalizeUserId(m.apiUserId))
        .where((id) => id.isNotEmpty)
        .toSet();
  }

  static bool isExcludedFromInvite({
    required VffConnectionEntity connection,
    Set<String> excludeUserIds = const {},
  }) {
    final userId = VffJsonParsing.normalizeUserId(connection.userId);
    if (userId.isEmpty) return true;
    return excludeUserIds.contains(userId);
  }

  static List<InviteVffPickUi> fromConnections(
    List<VffConnectionEntity> connections, {
    Set<String> excludeUserIds = const {},
  }) {
    return connections
        .where((c) => !c.isPendingOutgoing)
        .where((c) => !isExcludedFromInvite(
              connection: c,
              excludeUserIds: excludeUserIds,
            ))
        .map(fromConnection)
        .toList(growable: false);
  }
}
