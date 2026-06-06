import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vestie/core/constants/app_assets.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/theme/app_text_styles.dart';
import 'package:vestie/core/widgets/common/app_svg_icon.dart';
import '../../domain/entities/project.dart';
import 'project_card.dart';

/// Collapsible home project sections as [CustomScrollView] slivers.
///
/// Uses [SliverList] + [SliverChildBuilderDelegate] so 20+ cards lazy-build
/// without [ListView.shrinkWrap] viewport expansion inside the parent scroll view.
class ProjectsSection {
  ProjectsSection._();

  static List<Widget> buildSlivers({
    required String title,
    required List<Project> projects,
    required bool expanded,
    required VoidCallback onToggle,
    required void Function(Project) onProjectAction,
  }) {
    return [
      SliverPadding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        sliver: SliverToBoxAdapter(
          child: _ProjectsSectionHeader(
            title: title,
            expanded: expanded,
            onToggle: onToggle,
          ),
        ),
      ),
      if (expanded && projects.isNotEmpty)
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final project = projects[index];
                return ProjectCard(
                  project: project,
                  onAction: () => onProjectAction(project),
                );
              },
              childCount: projects.length,
            ),
          ),
        ),
    ];
  }
}

class _ProjectsSectionHeader extends StatelessWidget {
  const _ProjectsSectionHeader({
    required this.title,
    required this.expanded,
    required this.onToggle,
  });

  final String title;
  final bool expanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        child: Row(
          children: [
            Text(title, style: AppTextStyles.homeSectionTitle),
            const Spacer(),
            AnimatedRotation(
              turns: expanded ? 0 : -0.25,
              duration: const Duration(milliseconds: 250),
              child: AppSvgIcon(
                assetPath: AppAssets.iconChevronDown,
                size: 22.w,
                color: AppColors.textBody,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
