import 'package:vestie/user/features/home/domain/entities/project.dart';
import 'package:vestie/user/features/home/domain/entities/project_category_extensions.dart';

import '../../projects/domain/entities/invite_preview_entity.dart';

extension InvitePreviewCategoryX on InvitePreviewEntity {
  ProjectCategory get category {
    final t = projectType.toLowerCase().trim();
    if (t.contains('invest')) return ProjectCategory.investment;
    if (t.contains('emerg')) return ProjectCategory.emergency;
    return ProjectCategory.vacations;
  }

  String get categoryChipLabel => category.detailLabel;
  String? get categoryIconAsset => category.iconAsset;
}
