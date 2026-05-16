import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../theme/app_colors.dart';

/// Shimmer loading skeleton wrapper.
/// Wrap any placeholder widget to give it the shimmer effect.
class AppShimmer extends StatelessWidget {
  final Widget child;

  const AppShimmer({super.key, required this.child});

  /// Solid color block designed for skeleton placeholders.
  static Widget box({
    required double width,
    required double height,
    double borderRadius = 8,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.border,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.border,
      highlightColor: AppColors.divider,
      child: child,
    );
  }
}

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
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
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
  AppShimmer.box(
                  width: double.infinity,
                  height: 72,
    borderRadius: 14,
  ),
  const SizedBox(height: 12),
  AppShimmer.box(
    width: double.infinity,
    height: 120,
    borderRadius: 16,
  ),
  const SizedBox(height: 16),
  AppShimmer.box(
    width: double.infinity,
    height: 48,
    borderRadius: 10,
  ),
  const SizedBox(height: 12),
  AppShimmer.box(
    width: double.infinity,
    height: 48,
    borderRadius: 10,
  ),
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
                AppShimmer.box(
                  width: 140,
                  height: 14,
                  borderRadius: 4,
                ),
                const SizedBox(height: 6),
                AppShimmer.box(
                  width: 90,
                  height: 12,
                  borderRadius: 4,
                ),
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
        SliverSafeArea(
          bottom: false,
          sliver: ProjectDetailContentShimmer(),
        ),
      ],
    );
  }
}

/// Join requests list skeleton (Week 3 pending memberships).
class JoinRequestsListShimmer extends StatelessWidget {
  const JoinRequestsListShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        itemCount: 4,
        separatorBuilder: (_, _) => const SizedBox(height: 2),
        itemBuilder: (_, _) => Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  AppShimmer.box(width: 52, height: 52, borderRadius: 26),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppShimmer.box(
                          width: 120,
                          height: 16,
                          borderRadius: 4,
                        ),
                        const SizedBox(height: 6),
                        AppShimmer.box(width: 80, height: 12, borderRadius: 4),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: AppShimmer.box(
                      width: double.infinity,
                      height: 40,
                      borderRadius: 8,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: AppShimmer.box(
                      width: double.infinity,
                      height: 40,
                      borderRadius: 8,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A premium user profile header skeleton shimmer.
class ProfileHeaderShimmer extends StatelessWidget {
  const ProfileHeaderShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Row(
        children: [
          AppShimmer.box(width: 80, height: 80, borderRadius: 40),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppShimmer.box(width: 140, height: 20, borderRadius: 4),
              const SizedBox(height: 8),
              AppShimmer.box(width: 180, height: 14, borderRadius: 4),
            ],
          ),
        ],
      ),
    );
  }
}



