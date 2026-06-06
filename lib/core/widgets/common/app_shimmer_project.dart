import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import 'app_shimmer_base.dart';

/// A high-fidelity premium Project Card skeleton shimmer.
class ProjectCardShimmer extends StatelessWidget {
  const ProjectCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.projectCardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.projectCardBorder, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AppShimmer.box(width: 80, height: 20, borderRadius: 10),
                AppShimmer.box(width: 60, height: 20, borderRadius: 10),
              ],
            ),
            const SizedBox(height: 12),
            AppShimmer.box(width: double.infinity, height: 24, borderRadius: 4),
            const SizedBox(height: 8),
            AppShimmer.box(width: 200, height: 16, borderRadius: 4),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AppShimmer.box(width: 100, height: 14, borderRadius: 4),
                AppShimmer.box(width: 80, height: 14, borderRadius: 4),
              ],
            ),
            const SizedBox(height: 8),
            AppShimmer.box(width: double.infinity, height: 8, borderRadius: 4),
          ],
        ),
      ),
    );
  }
}

/// Skeleton blocks below project-detail header (info card, actions, members).
class ProjectDetailContentShimmer extends StatelessWidget {
  const ProjectDetailContentShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      sliver: SliverToBoxAdapter(
        child: AppShimmer(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: _projectDetailShimmerChildren(),
          ),
        ),
      ),
    );
  }
}

List<Widget> _projectDetailShimmerChildren() => [
  AppShimmer.box(width: double.infinity, height: 72, borderRadius: 14),
  const SizedBox(height: 12),
  AppShimmer.box(width: double.infinity, height: 120, borderRadius: 16),
  const SizedBox(height: 16),
  AppShimmer.box(width: double.infinity, height: 48, borderRadius: 10),
  const SizedBox(height: 12),
  AppShimmer.box(width: double.infinity, height: 48, borderRadius: 10),
  const SizedBox(height: 20),
  Row(
    children: [
      Expanded(
        child: AppShimmer.box(
          width: double.infinity,
          height: 36,
          borderRadius: 8,
        ),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: AppShimmer.box(
          width: double.infinity,
          height: 36,
          borderRadius: 8,
        ),
      ),
    ],
  ),
  const SizedBox(height: 16),
  ...List.generate(
    3,
    (_) => Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          AppShimmer.box(width: 48, height: 48, borderRadius: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppShimmer.box(width: 140, height: 14, borderRadius: 4),
                const SizedBox(height: 6),
                AppShimmer.box(width: 90, height: 12, borderRadius: 4),
              ],
            ),
          ),
        ],
      ),
    ),
  ),
];

/// Full-page skeleton when no header title is available yet.
class ProjectDetailShimmer extends StatelessWidget {
  const ProjectDetailShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const NeverScrollableScrollPhysics(),
      slivers: const [
        SliverSafeArea(bottom: false, sliver: ProjectDetailContentShimmer()),
      ],
    );
  }
}
