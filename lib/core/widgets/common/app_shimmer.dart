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

/// A high-fidelity full-page Project Detail skeleton shimmer.
class ProjectDetailShimmer extends StatelessWidget {
  const ProjectDetailShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Row(
              children: [
                AppShimmer.box(width: 40, height: 40, borderRadius: 20),
                const SizedBox(width: 16),
                AppShimmer.box(width: 150, height: 24, borderRadius: 4),
              ],
            ),
            const SizedBox(height: 32),
            AppShimmer.box(width: double.infinity, height: 180, borderRadius: 16),
            const SizedBox(height: 24),
            AppShimmer.box(width: double.infinity, height: 50, borderRadius: 25),
            const SizedBox(height: 12),
            AppShimmer.box(width: double.infinity, height: 50, borderRadius: 25),
            const SizedBox(height: 32),
            Row(
              children: [
                AppShimmer.box(width: 100, height: 20, borderRadius: 4),
                const Spacer(),
                AppShimmer.box(width: 100, height: 20, borderRadius: 4),
              ],
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 3,
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    AppShimmer.box(width: 44, height: 44, borderRadius: 22),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppShimmer.box(width: 120, height: 16, borderRadius: 4),
                        const SizedBox(height: 6),
                        AppShimmer.box(width: 80, height: 12, borderRadius: 4),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A high-fidelity premium Home Screen skeleton shimmer.
class HomeShimmer extends StatelessWidget {
  const HomeShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppShimmer.box(width: 120, height: 16, borderRadius: 4),
                    const SizedBox(height: 8),
                    AppShimmer.box(width: 180, height: 28, borderRadius: 4),
                  ],
                ),
                AppShimmer.box(width: 40, height: 40, borderRadius: 20),
              ],
            ),
            const SizedBox(height: 32),
            AppShimmer.box(width: 130, height: 20, borderRadius: 4),
            const SizedBox(height: 16),
            const ProjectCardShimmer(),
            const SizedBox(height: 16),
            AppShimmer.box(width: 130, height: 20, borderRadius: 4),
            const SizedBox(height: 16),
            const ProjectCardShimmer(),
          ],
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



