import 'package:vestie/core/widgets/common/invite_vff_pick_ui.dart';

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

  static List<InviteVffPickUi> fromConnections(
    List<VffConnectionEntity> connections, {
    Set<String> excludeUserIds = const {},
  }) {
    return connections
        .where((c) => !c.isPendingOutgoing)
        .where((c) => c.userId.isNotEmpty && !excludeUserIds.contains(c.userId))
        .map(fromConnection)
        .toList(growable: false);
  }
}
