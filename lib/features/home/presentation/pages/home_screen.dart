import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/common/app_loader.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';
import '../cubit/home_sections_cubit.dart';
import '../widgets/home_empty_view.dart';
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
            backgroundColor: AppColors.dashBg,
            body: AppLoader(),
          );
        }

        if (state is HomeError) {
          return Scaffold(
            backgroundColor: AppColors.dashBg,
            body: Center(child: Text(state.message)),
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

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeSectionsCubit, HomeSectionsState>(
      builder: (context, sections) {
        final cubit = context.read<HomeSectionsCubit>();
        return Scaffold(
          backgroundColor: AppColors.dashBg,
          body: RefreshIndicator(
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
                          onProjectAction: (_) {},
                        ),
                        ProjectsSection(
                          title: AppStrings.joinedProjects,
                          projects: data.joinedProjects,
                          expanded: sections.joinedProjectsExpanded,
                          onToggle: cubit.toggleJoined,
                          onProjectAction: (_) {},
                        ),
                        SizedBox(height: 16.h),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
