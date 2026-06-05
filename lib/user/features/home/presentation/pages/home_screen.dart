import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/services/bank_accounts_prefetch.dart';
import 'package:vestie/core/services/payment_methods_prefetch.dart';
import 'package:vestie/core/services/home_project_list_sync.dart';
import 'package:vestie/core/services/wallet_prefetch.dart';
import 'package:vestie/core/theme/app_colors.dart';
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
import '../widgets/home_header.dart';
import '../widgets/projects_section.dart';

/// Shell — provides HomeBloc + HomeSectionsCubit.
/// [activate] is true when the Home tab is selected (see [DashboardScreen]).
class HomeScreen extends StatefulWidget {
  final bool activate;

  /// When true (from [DashboardShellArgs]), runs a full reload after create-project.
  final bool reloadHomeProjectList;

  const HomeScreen({
    super.key,
    this.activate = true,
    this.reloadHomeProjectList = false,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final HomeBloc _homeBloc = HomeBloc();
  late final HomeSectionsCubit _sectionsCubit = HomeSectionsCubit();

  @override
  void initState() {
    super.initState();
    HomeProjectListSync.onProjectPotUpdated = (projectId, projectPot) {
      if (!mounted) return;
      _homeBloc.add(
        HomeProjectPotPatched(
          projectId: projectId,
          projectPot: projectPot,
        ),
      );
    };
    if (widget.reloadHomeProjectList) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _homeBloc.add(const HomeRefreshRequested());
        }
      });
      return;
    }
    if (widget.activate) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _onTabActivated();
      });
    }
  }

  @override
  void didUpdateWidget(covariant HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.activate && !oldWidget.activate) {
      _onTabActivated();
    }
  }

  void _onTabActivated() {
    unawaited(PaymentMethodsPrefetch.warmIfNeeded());
    unawaited(BankAccountsPrefetch.warmIfNeeded());
    unawaited(WalletPrefetch.warmIfNeeded());

    final state = _homeBloc.state;
    if (state is HomeLoading) return;
    if (state is HomeInitial || state is HomeError) {
      _homeBloc.add(const HomeFetchStarted());
      return;
    }
    _homeBloc.add(const HomeRefreshRequested(silent: true));
  }

  @override
  void dispose() {
    if (HomeProjectListSync.onProjectPotUpdated != null) {
      HomeProjectListSync.onProjectPotUpdated = null;
    }
    _homeBloc.close();
    _sectionsCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _homeBloc),
        BlocProvider.value(value: _sectionsCubit),
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
      buildWhen: (previous, current) =>
          previous.runtimeType != current.runtimeType || previous != current,
      builder: (context, state) {
        if (state is HomeLoading || state is HomeInitial) {
          return Scaffold(
            backgroundColor: Colors.transparent,
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const HomeHeader(totalContributed: 0),
                Expanded(
                    child: ColoredBox(
                      color: Colors.white,
                      child: CustomScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        slivers: [
                          SliverPadding(
                            padding: EdgeInsets.symmetric(horizontal: 16.w),
                            sliver: SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) =>
                                    const ProjectCardShimmer(),
                                childCount: 3,
                              ),
                            ),
                          ),
                          SliverToBoxAdapter(child: SizedBox(height: 16.h)),
                        ],
                      ),
                    ),
                  ),
                ],
            ),
          );
        }

        if (state is HomeError) {
          return Scaffold(
            backgroundColor: Colors.transparent,
            body: SafeArea(
              bottom: false,
              child: CustomScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  slivers: [
                    SliverFillRemaining(
                      hasScrollBody: false,
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

  void _openProjectDetail(BuildContext context, Project p) {
    openProjectFromCard(context, p);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeSectionsCubit, HomeSectionsState>(
      buildWhen: (previous, current) => previous != current,
      builder: (context, sections) {
        final cubit = context.read<HomeSectionsCubit>();
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              HomeHeader(totalContributed: data.totalContributed),
              Expanded(
                  child: ColoredBox(
                    color: Colors.white,
                    child: RefreshIndicator(
                      color: AppColors.primary,
                      onRefresh: () async => context
                          .read<HomeBloc>()
                          .add(const HomeRefreshRequested()),
                      child: CustomScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        slivers: [
                          SliverPadding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 4.h,
                            ),
                            sliver: SliverToBoxAdapter(
                              child: Column(
                                children: [
                                  ProjectsSection(
                                    title: AppStrings.myProjects,
                                    projects: data.myProjects,
                                    expanded: sections.myProjectsExpanded,
                                    onToggle: cubit.toggleMyProjects,
                                    onProjectAction: (p) =>
                                        _openProjectDetail(context, p),
                                  ),
                                  ProjectsSection(
                                    title: AppStrings.joinedProjects,
                                    projects: data.joinedProjects,
                                    expanded: sections.joinedProjectsExpanded,
                                    onToggle: cubit.toggleJoined,
                                    onProjectAction: (p) =>
                                        _openProjectDetail(context, p),
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
                ),
            ],
          ),
        );
      },
    );
  }
}
