import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/features/project_detail/domain/entities/project_detail_entity.dart';
import 'package:vestie/features/project_detail/presentation/widgets/project_detail_members_only_section.dart';
import 'package:vestie/features/project_detail/presentation/widgets/project_detail_scroll_insets.dart';
import 'package:vestie/features/project_detail/presentation/widgets/project_info_card.dart';

/// Profile → Completed Projects → outcome → View Details: goal card + members.
///
/// Preview member rows are read-only; **View All Members** opens a read-only list.
class CompletedProjectsProfileDetailContent extends StatelessWidget {
  final ProjectDetailEntity project;

  const CompletedProjectsProfileDetailContent({
    super.key,
    required this.project,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: 12.h),
        ProjectInfoCard(
          project: project,
          displayAsCompleted: true,
        ),
        SizedBox(height: 16.h),
        ProjectDetailMembersOnlySection(
          project: project,
          title: AppStrings.tabMembers,
          fromCompletedProjectsProfileDetail: true,
        ),
        SizedBox(height: ProjectDetailScrollInsets.scrollBottomGap(context)),
      ],
    );
  }
}
