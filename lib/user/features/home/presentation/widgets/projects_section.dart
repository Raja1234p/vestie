import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vestie/core/constants/app_assets.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/theme/app_text_styles.dart';
import 'package:vestie/core/widgets/common/app_svg_icon.dart';
import '../../domain/entities/project.dart';
import 'project_card.dart';

/// Collapsible section showing a list of project cards.
class ProjectsSection extends StatelessWidget {
  final String title;
  final List<Project> projects;
  final bool expanded;
  final VoidCallback onToggle;
  final void Function(Project) onProjectAction;

  const ProjectsSection({
    super.key,
    required this.title,
    required this.projects,
    required this.expanded,
    required this.onToggle,
    required this.onProjectAction,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Section header ─────────────────────────────────
        GestureDetector(
          onTap: onToggle,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 12.h),
            child: Row(
              children: [
                Text(
                  title,
                  style: AppTextStyles.homeSectionTitle,
                ),
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
        ),

        // ── Cards ──────────────────────────────────────────
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 280),
          crossFadeState: expanded
              ? CrossFadeState.showFirst
              : CrossFadeState.showSecond,
          firstChild: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: projects.length,
            itemBuilder: (context, index) {
              final project = projects[index];
              return ProjectCard(
                project: project,
                onAction: () => onProjectAction(project),
              );
            },
          ),
          secondChild: const SizedBox.shrink(),
        ),
      ],
    );
  }
}
