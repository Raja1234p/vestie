import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vestie/core/di/service_locator.dart';
import 'package:vestie/core/utils/app_snackbar.dart';

import 'package:vestie/core/widgets/common/app_button.dart';
import 'package:vestie/core/widgets/common/app_shimmer.dart';
import 'package:vestie/core/widgets/common/post_auth_gradient_background.dart';
import 'package:vestie/core/widgets/text/app_text.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import 'package:vestie/app/router/app_routes.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/theme/app_colors.dart';
import '../../../home/domain/entities/project.dart';
import '../../../home/presentation/widgets/project_card.dart';
import 'package:vestie/features/project_detail/presentation/navigation/open_project_from_card.dart';
import 'package:vestie/user/features/create_project_member_fund/presentation/widgets/create_project_member_walkthrough_sheet.dart';
import 'package:vestie/user/features/investment/presentation/models/user_investment_ui_snapshot.dart';
import '../cubit/discover_cubit.dart';
import 'package:vestie/user/features/home/presentation/widgets/home_empty_view.dart';
import '../widgets/discover_filter_row.dart';
import '../widgets/discover_header.dart';
import '../widgets/discover_search_bar.dart';

/// Discover tab. [activate] true when selected — loads API only then (see [DashboardScreen]).
class DiscoverScreen extends StatefulWidget {
  final bool activate;

  const DiscoverScreen({super.key, required this.activate});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  late final DiscoverCubit _cubit = DiscoverCubit();

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

  void _showUserInvestmentChooser(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: AppText(
                    AppStrings.userInvestmentChooserTitle,
                    style: GoogleFonts.lato(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                ListTile(
                  title: AppText(
                    AppStrings.userInvestmentChooserWithMembers,
                    style: GoogleFonts.lato(fontWeight: FontWeight.w700),
                  ),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    context.push(
                      AppRoutes.userInvestmentProjectDetail,
                      extra: UserInvestmentUiSnapshot.demoInvestmentFlow(),
                    );
                  },
                ),
                ListTile(
                  title: AppText(
                    AppStrings.userInvestmentChooserEmptyMembers,
                    style: GoogleFonts.lato(fontWeight: FontWeight.w700),
                  ),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    context.push(
                      AppRoutes.userInvestmentProjectDetail,
                      extra: UserInvestmentUiSnapshot.demoEmptyMembers(),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!visible) {
      return const SizedBox.shrink();
    }
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: PostAuthGradientBackground(
        child: BlocBuilder<DiscoverCubit, DiscoverState>(
          builder: (context, state) {
            final hasProjects = state.allProjects.isNotEmpty;
            final filteredEmpty = state.filtered.isEmpty;
            final loadFailed = state.errorMessage != null;

            return CustomScrollView(
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
                          SizedBox(height: 4.h),
                          TextButton(
                            onPressed: () =>
                                showCreateProjectMemberWalkthroughSheet(
                                    context),
                            child: AppText(
                              AppStrings.createProjectMemberWalkthroughLink,
                              style: GoogleFonts.lato(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                                decoration: TextDecoration.underline,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          TextButton(
                            onPressed: () =>
                                _showUserInvestmentChooser(context),
                            child: AppText(
                              AppStrings.userInvestmentDiscoverEntry,
                              style: GoogleFonts.lato(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                                decoration: TextDecoration.underline,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          SizedBox(height: 8.h),
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
                            onAction: () {
                              final project = state.filtered[i];
                              final isJoinAction = project.status ==
                                      ProjectStatus.ongoing &&
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
                ],

                SliverToBoxAdapter(child: SizedBox(height: 16.h)),
              ],
            );
          },
        ),
      ),
    );
  }
}
