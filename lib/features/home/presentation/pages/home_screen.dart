import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/common/app_loader.dart';
import '../../../home/domain/entities/project.dart';
import '../../../project_detail/domain/entities/borrow_request_entity.dart';
import '../../../project_detail/domain/entities/member_entity.dart';
import '../../../project_detail/domain/entities/project_detail_entity.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';
import '../cubit/home_sections_cubit.dart';
import '../widgets/home_empty_view.dart';
import '../widgets/home_gradient_background.dart';
import '../widgets/home_header.dart';
import '../widgets/projects_section.dart';

/// Shell — provides HomeBloc + HomeSectionsCubit. Stateless.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
            create: (_) => HomeBloc()..add(const HomeFetchStarted())),
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
          return const Scaffold(
            backgroundColor: Colors.transparent,
            body: HomeGradientBackground(
              child: AppLoader(),
            ),
          );
        }

        if (state is HomeError) {
          return Scaffold(
            backgroundColor: Colors.transparent,
            body: HomeGradientBackground(
              child: Center(child: Text(state.message)),
            ),
          );
        }

        if (state is HomeLoaded) {
          final isEmpty =
              state.myProjects.isEmpty && state.joinedProjects.isEmpty;

          if (isEmpty) {
            return HomeEmptyView(
              onCreateProject: () =>
                  context.push(AppRoutes.createProjectAmount),
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
  void _navigateToDetail(BuildContext context, Project p) {
    final detail = ProjectDetailEntity(
      id: p.id,
      name: p.name,
      category: p.category,
      status: p.status,
      goalAmount: p.goalAmount ?? 5000,
      currentAmount: p.currentAmount ?? 2700,
      endsIn: p.endsIn ?? '2 months',
      announcement: AppStrings.announcementPlaceholder,
      members: const [
        MemberEntity(id: '1', initials: 'EL', name: 'Emma L.',
            role: MemberRole.leader, contributedAmount: 45),
        MemberEntity(id: '2', initials: 'OR', name: 'Olivia R.',
            role: MemberRole.coLeader, contributedAmount: 65),
        MemberEntity(id: '3', initials: 'LN', name: 'Lien N.',
            role: MemberRole.member, contributedAmount: 19),
      ],
      borrowRequests: const [
        BorrowRequestEntity(id: 'b1', initials: 'OR', memberName: 'Olivia R.',
            loanType: AppStrings.educationLoan, requestedAmount: 2500, upvotes: 78, downvotes: 6),
        BorrowRequestEntity(id: 'b2', initials: 'OR', memberName: 'Olivia R.',
            loanType: AppStrings.educationLoan, requestedAmount: 2500, upvotes: 78, downvotes: 6),
        BorrowRequestEntity(id: 'b3', initials: 'OR', memberName: 'Olivia R.',
            loanType: AppStrings.educationLoan, requestedAmount: 2500, upvotes: 78, downvotes: 6),
      ],
      isLeader: p.relation == ProjectRelation.owned,
    );
    context.push(AppRoutes.projectDetail, extra: detail);
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
                            onProjectAction: (p) =>
                                _navigateToDetail(context, p),
                          ),
                          ProjectsSection(
                            title: AppStrings.joinedProjects,
                            projects: data.joinedProjects,
                            expanded: sections.joinedProjectsExpanded,
                            onToggle: cubit.toggleJoined,
                            onProjectAction: (p) =>
                                _navigateToDetail(context, p),
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
