import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/utils/app_snackbar.dart';

import '../../../../core/widgets/common/app_shimmer.dart';
import '../../../../core/widgets/common/post_auth_gradient_background.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../home/domain/entities/project.dart';
import '../../../home/presentation/widgets/project_card.dart';
import '../../../project_detail/presentation/navigation/open_project_from_card.dart';
import '../cubit/discover_cubit.dart';
import '../widgets/discover_filter_row.dart';
import '../widgets/discover_header.dart';
import '../widgets/discover_search_bar.dart';

/// Shell — provides DiscoverCubit. Stateless.
class DiscoverScreen extends StatelessWidget {
  const DiscoverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DiscoverCubit(),
      child: const _DiscoverBody(),
    );
  }
}

class _DiscoverBody extends StatelessWidget {
  const _DiscoverBody();

  Future<void> _handleJoinAction(BuildContext context, Project p) async {
    final inviteCode = await _askInviteCode(context);
    if (!context.mounted || inviteCode == null || inviteCode.isEmpty) return;

    final previewResult =
        await ServiceLocator.instance.previewInviteUseCase(inviteCode);
    if (!context.mounted) return;

    await previewResult.fold(
      (failure) async => AppSnackBar.showError(context, failure.message),
      (preview) async {
        if (!preview.isJoinable || preview.isExpired) {
          AppSnackBar.showInfo(context, AppStrings.errorGeneric);
          return;
        }

        final joinResult = await ServiceLocator.instance.joinProjectUseCase(
          projectId: p.id,
          inviteCode: inviteCode,
        );
        if (!context.mounted) return;
        joinResult.fold(
          (failure) => AppSnackBar.showError(context, failure.message),
          (_) async {
            AppSnackBar.showSuccess(context, AppStrings.btnDone);
            await context.read<DiscoverCubit>().refresh();
          },
        );
      },
    );
  }

  Future<String?> _askInviteCode(BuildContext context) async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Enter Invite Code'),
          content: TextField(
            controller: controller,
            autofocus: true,
            textCapitalization: TextCapitalization.characters,
            decoration: const InputDecoration(
              hintText: 'INV-XXXXXX',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(controller.text.trim()),
              child: const Text('Join'),
            ),
          ],
        );
      },
    );
  }

  void _navigateToDetail(BuildContext context, Project p) {
    openProjectFromCard(context, p, isLeaderView: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: PostAuthGradientBackground(
        child: BlocBuilder<DiscoverCubit, DiscoverState>(
          builder: (context, state) {
            return CustomScrollView(
              slivers: [
              // ── Header (gradient) ─────────────────────────
              const SliverToBoxAdapter(child: DiscoverHeader()),

              // ── Search + Filter ───────────────────────────
              SliverPadding(
                padding:
                    EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    children: [
                      DiscoverSearchBar(
                        onChanged: context
                            .read<DiscoverCubit>()
                            .search,
                      ),
                      SizedBox(height: 12.h),
                      DiscoverFilterRow(
                        selected: state.selectedFilter,
                        onSelect:
                            context.read<DiscoverCubit>().selectFilter,
                      ),
                      SizedBox(height: 4.h),
                    ],
                  ),
                ),
              ),

              // ── Loading ───────────────────────────────────
              if (state.loading)
                SliverPadding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => const ProjectCardShimmer(),
                      childCount: 3,
                    ),
                  ),
                ),

              // ── Project list ──────────────────────────────
              if (!state.loading)
                SliverPadding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) => ProjectCard(
                        project: state.filtered[i],
                        onAction: () {
                          final project = state.filtered[i];
                          final isJoinAction = project.status == ProjectStatus.ongoing &&
                              project.relation != ProjectRelation.owned &&
                              !project.requestPending;
                          if (isJoinAction) {
                            _handleJoinAction(context, project);
                            return;
                          }
                          _navigateToDetail(context, project);
                        },
                      ),
                      childCount: state.filtered.length,
                    ),
                  ),
                ),

              SliverToBoxAdapter(child: SizedBox(height: 16.h)),
              ],
            );
          },
        ),
      ),
    );
  }
}
