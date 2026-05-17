import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vestie/core/widgets/common/app_button.dart';
import 'package:vestie/core/widgets/common/app_shimmer.dart';
import 'package:vestie/core/widgets/common/post_auth_gradient_background.dart';
import 'package:vestie/core/widgets/text/app_text.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/theme/app_colors.dart';
import '../../../home/domain/entities/project.dart';
import '../../../home/presentation/widgets/project_card.dart';
import 'package:vestie/features/project_detail/presentation/navigation/open_project_from_card.dart';
import '../cubit/discover_cubit.dart';
import 'package:vestie/user/features/home/presentation/widgets/home_empty_view.dart';
import '../widgets/discover_filter_row.dart';
import '../widgets/discover_header.dart';
import '../widgets/discover_join_effects_listener.dart';
import '../widgets/discover_search_bar.dart';

/// Discover tab. [activate] true when selected — loads API only then (see [DashboardScreen]).
class DiscoverScreen extends StatefulWidget {
  final bool activate;
  /// From [DashboardShellArgs] — forces a fresh discover list the next time the tab loads.
  final bool reloadDiscoverProjectList;

  const DiscoverScreen({
    super.key,
    required this.activate,
    this.reloadDiscoverProjectList = false,
  });

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  late final DiscoverCubit _cubit = DiscoverCubit(
    reloadDiscoverProjectList: widget.reloadDiscoverProjectList,
  );

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (widget.activate) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _cubit.loadIfNeeded();
      });
    }
  }

  @override
  void didUpdateWidget(covariant DiscoverScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.activate && !oldWidget.activate) {
      _cubit.loadIfNeeded();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: _DiscoverBody(visible: widget.activate),
    );
  }
}

class _DiscoverBody extends StatelessWidget {
  final bool visible;

  const _DiscoverBody({required this.visible});

  void _navigateToDetail(BuildContext context, Project p) {
    openProjectFromCard(context, p);
  }

  @override
  Widget build(BuildContext context) {
    if (!visible) {
      return const SizedBox.shrink();
    }
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: PostAuthGradientBackground(
        child: DiscoverJoinEffectsListener(
          child: BlocBuilder<DiscoverCubit, DiscoverState>(
          builder: (context, state) {
            final hasProjects = state.allProjects.isNotEmpty;
            final filteredEmpty = state.filtered.isEmpty;
            final loadFailed = state.errorMessage != null;
            final emptyIdle =
                !state.loading && !loadFailed && !hasProjects;

            return RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () =>
                  context.read<DiscoverCubit>().refresh(),
              child: CustomScrollView(
              physics: emptyIdle
                  ? const NeverScrollableScrollPhysics()
                  : const AlwaysScrollableScrollPhysics(),
              slivers: [
                // No [DiscoverHeader] when there are zero projects — full-screen empty state only.
                if (state.loading || hasProjects)
                  const SliverToBoxAdapter(child: DiscoverHeader()),

                if (state.loading)
                  SliverPadding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => const ProjectCardShimmer(),
                        childCount: 3,
                      ),
                    ),
                  )
                else if (loadFailed)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: SafeArea(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 28.w),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            AppText(
                              state.errorMessage!,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.lato(
                                fontSize: 15.sp,
                                height: 1.45,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textBody,
                              ),
                            ),
                            SizedBox(height: 20.h),
                            AppButton(
                              text: AppStrings.btnRetry,
                              width: 280.w,
                              onPressed: () =>
                                  context.read<DiscoverCubit>().retry(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else if (!hasProjects)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: HomeEmptyView.forDiscover(),
                  )
                else ...[
                  SliverPadding(
                    padding:
                        EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
                    sliver: SliverToBoxAdapter(
                      child: Column(
                        children: [
                          DiscoverSearchBar(
                            onChanged:
                                context.read<DiscoverCubit>().search,
                          ),
                          SizedBox(height: 12.h),
                          DiscoverFilterRow(
                            selected: state.selectedFilter,
                            onSelect:
                                context.read<DiscoverCubit>().selectFilter,
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (filteredEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(28.w, 48.h, 28.w, 24.h),
                        child: Column(
                          children: [
                            Text(
                              AppStrings.discoverNoMatchingTitle,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.lato(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            SizedBox(height: 10.h),
                            Text(
                              AppStrings.discoverNoMatchingSubtitle,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.lato(
                                fontSize: 14.sp,
                                height: 1.45,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textBody,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (_, i) => ProjectCard(
                            project: state.filtered[i],
                            discoverCtaStyle: true,
                            actionLoading:
                                state.joiningProjectId == state.filtered[i].id,
                            onAction: () {
                              final project = state.filtered[i];
                              final isJoinAction = project.status ==
                                      ProjectStatus.ongoing &&
                                  project.relation != ProjectRelation.owned &&
                                  !project.requestPending;
                              if (isJoinAction) {
                                context.read<DiscoverCubit>().joinProject(project);
                                return;
                              }
                              _navigateToDetail(context, project);
                            },
                          ),
                          childCount: state.filtered.length,
                        ),
                      ),
                    ),
                ],

                if (!emptyIdle)
                  SliverToBoxAdapter(child: SizedBox(height: 16.h)),
              ],
            ),
            );
          },
        ),
        ),
      ),
    );
  }
}
