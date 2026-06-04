import 'package:vestie/core/utils/project_visibility_utils.dart';

import '../../projects/domain/entities/invite_preview_entity.dart';

extension InvitePreviewVisibilityX on InvitePreviewEntity {
  bool get isPublicInvite => isPublicProjectVisibility(visibility);

  bool get isPrivateInvite => !isPublicInvite;
}
