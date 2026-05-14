import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/di/service_locator.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/utils/app_snackbar.dart';
import 'package:vestie/core/widgets/common/app_button.dart';
import 'package:vestie/core/widgets/common/app_shimmer.dart';
import 'package:vestie/core/widgets/text/app_text.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../home/domain/entities/project.dart';
import 'package:vestie/features/project_detail/presentation/navigation/open_project_from_card.dart';
import 'package:vestie/leader/features/create_project/presentation/widgets/create_project_amount_sheet.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';
import '../cubit/home_sections_cubit.dart';
import '../widgets/home_empty_view.dart';
import '../widgets/home_gradient_background.dart';
import '../widgets/home_header.dart';
import '../widgets/projects_section.dart';

/// Shell — provides HomeBloc + HomeSectionsCubit.
class HomeScreen extends StatelessWidget {
  /// When true (from [DashboardShellArgs]), runs the same load as pull-to-refresh
  /// so `GET /projects?scope=mine` runs once with a fresh list after create-project.
  final bool reloadHomeProjectList;

  const HomeScreen({
    super.key,
    this.reloadHomeProjectList = false,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => HomeBloc()
            ..add(
              reloadHomeProjectList
                  ? const HomeRefreshRequested()
                  : const HomeFetchStarted(),
            ),
        ),
        BlocProvider(create: (_) => HomeSectionsCubit()),
      ],
      child: const _HomeBody(),
    );
  }
}

class _HomeBody extends StatelessWidget {
  const _HomeBody();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        if (state is HomeLoading || state is HomeInitial) {
          return Scaffold(
            backgroundColor: Colors.transparent,
            body: HomeGradientBackground(
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: HomeHeader(totalContributed: 0),
                  ),
                  SliverPadding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => const ProjectCardShimmer(),
                        childCount: 3,
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(child: SizedBox(height: 16.h)),
                ],
              ),
            ),
          );
        }

        if (state is HomeError) {
          return Scaffold(
            backgroundColor: Colors.transparent,
            body: HomeGradientBackground(
              child: CustomScrollView(
                physics: const NeverScrollableScrollPhysics(),
                slivers: [
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
                              state.message,
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
                              onPressed: () => context
                                  .read<HomeBloc>()
                                  .add(const HomeFetchStarted()),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        if (state is HomeLoaded) {
          final isEmpty =
              state.myProjects.isEmpty && state.joinedProjects.isEmpty;

          if (isEmpty) {
            return HomeEmptyView.forHome(
              onCreateProject: () => showCreateProjectAmountSheet(context),
            );
          }

          return _HomeContent(data: state);
        }

        return const SizedBox.shrink();
      },
    );
  }
}

class _HomeContent extends StatelessWidget {
  final HomeLoaded data;
  const _HomeContent({required this.data});

  /// Builds mock detail data from the card project and navigates.
  void _navigateToLeaderDetail(BuildContext context, Project p) {
    _navigateToDetail(context, p, isLeaderView: true);
  }

  /// Builds mock detail data from the card project and navigates.
  void _navigateToUserDetail(BuildContext context, Project p) {
    _navigateToDetail(context, p, isLeaderView: false);
  }

  void _navigateToDetail(BuildContext context, Project p,
      {required bool isLeaderView}) {
    openProjectFromCard(
      context,
      p,
      isLeaderView: isLeaderView,
    );
  }

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
          (result) {
            if (result.status.toLowerCase().contains('pending')) {
              AppSnackBar.showSuccess(context, AppStrings.joinRequestApprovedTitle);
            } else {
              AppSnackBar.showSuccess(context, AppStrings.btnDone);
            }
            context.read<HomeBloc>().add(const HomeRefreshRequested());
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

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeSectionsCubit, HomeSectionsState>(
      builder: (context, sections) {
        final cubit = context.read<HomeSectionsCubit>();
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: HomeGradientBackground(
            child: RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () async =>
                  context.read<HomeBloc>().add(const HomeRefreshRequested()),
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: HomeHeader(
                        totalContributed: data.totalContributed),
                  ),
                  SliverPadding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
                    sliver: SliverToBoxAdapter(
                      child: Column(
                        children: [
                          ProjectsSection(
                            title: AppStrings.myProjects,
                            projects: data.myProjects,
                            expanded: sections.myProjectsExpanded,
                            onToggle: cubit.toggleMyProjects,
                            onProjectAction: (p) => _navigateToLeaderDetail(context, p),
                          ),
                          ProjectsSection(
                            title: AppStrings.joinedProjects,
                            projects: data.joinedProjects,
                            expanded: sections.joinedProjectsExpanded,
                            onToggle: cubit.toggleJoined,
                            onProjectAction: (p) {
                              final isJoinAction = p.status == ProjectStatus.ongoing &&
                                  p.relation != ProjectRelation.owned &&
                                  !p.requestPending;
                              if (isJoinAction) {
                                _handleJoinAction(context, p);
                                return;
                              }
                              _navigateToUserDetail(context, p);
                            },
                          ),
                          SizedBox(height: 16.h),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
