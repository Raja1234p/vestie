import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:vestie/core/constants/app_assets.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/presentation/paginated_scroll_listener.dart';
import 'package:vestie/core/presentation/widgets/list_load_more_footer.dart';
import 'package:vestie/core/widgets/common/app_shimmer.dart';
import 'package:vestie/core/widgets/common/app_error_view.dart';
import 'package:vestie/core/widgets/common/flow_screen_footer.dart';
import 'package:vestie/core/widgets/common/post_auth_gradient_background.dart';
import 'package:vestie/features/profile/presentation/navigation/open_completed_project_detail.dart';
import 'package:vestie/user/features/home/presentation/widgets/project_card.dart';
import 'package:vestie/user/features/vff/presentation/widgets/user_vff_hub_empty_body.dart';
import '../cubit/completed_projects_cubit.dart';
import '../widgets/profile_sub_header.dart';

class CompletedProjectsScreen extends StatelessWidget {
  const CompletedProjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CompletedProjectsCubit(),
      child: const _CompletedProjectsBody(),
    );
  }
}

class _CompletedProjectsBody extends StatefulWidget {
  const _CompletedProjectsBody();

  @override
  State<_CompletedProjectsBody> createState() => _CompletedProjectsBodyState();
}

class _CompletedProjectsBodyState extends State<_CompletedProjectsBody> {
  final ScrollController _scrollController = ScrollController();
  PaginatedScrollListener? _scrollListener;

  @override
  void initState() {
    super.initState();
    _scrollListener = PaginatedScrollListener(
      controller: _scrollController,
      onLoadMore: () => context.read<CompletedProjectsCubit>().loadMore(),
    );
  }

  @override
  void dispose() {
    _scrollListener?.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CompletedProjectsCubit, CompletedProjectsState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          resizeToAvoidBottomInset: false,
          body: PostAuthGradientBackground(
            child: Column(
              children: [
                ProfileSubHeader(title: AppStrings.completedProjectsTitle),
                Expanded(child: _buildBody(context, state)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, CompletedProjectsState state) {
    if (state.loading) {
      return ListView.builder(
        padding: FlowScreenFooterInsets.listPadding(context, horizontal: 16.w),
        itemCount: 3,
        itemBuilder: (_, __) => const ProjectCardShimmer(),
      );
    }
    if (state.loadFailed) {
      return AppErrorView(
        message: state.errorMessage,
        onRetry: () => context.read<CompletedProjectsCubit>().load(),
      );
    }
    if (state.projects.isEmpty) {
      return const _EmptyView();
    }
    return ListView.builder(
      controller: _scrollController,
      padding: FlowScreenFooterInsets.listPadding(context, horizontal: 16.w),
      itemCount: state.projects.length + 1,
      itemBuilder: (_, i) {
        if (i == state.projects.length) {
          return ListLoadMoreFooter(loadingMore: state.loadingMore);
        }
        final project = state.projects[i];
        return ProjectCard(
          project: project,
          forceShowActionButton: true,
          onAction: () => openCompletedProjectDetail(context, project),
        );
      },
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return const UserVffHubEmptyBody(
      message: AppStrings.completedProjectsEmptyTitle,
      subtitle: AppStrings.completedProjectsEmptySubtitle,
      illustrationAsset: AppAssets.borrowRequestsEmpty,
    );
  }
}
