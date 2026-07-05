import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/di/service_locator.dart';
import 'package:vestie/core/presentation/paginated_scroll_listener.dart';
import 'package:vestie/core/presentation/widgets/list_load_more_footer.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/utils/formatters.dart';
import 'package:vestie/core/widgets/common/app_back_button.dart';
import 'package:vestie/core/widgets/common/app_error_view.dart';
import 'package:vestie/core/widgets/common/app_shimmer_lists.dart';
import 'package:vestie/core/widgets/common/app_toast.dart';
import 'package:vestie/core/widgets/common/post_auth_gradient_background.dart';
import 'package:vestie/core/widgets/common/post_auth_header.dart';
import 'package:vestie/core/widgets/text/app_text.dart';

import 'package:vestie/app/router/route_args/project_detail_flow_args.dart';
import 'package:vestie/features/project_detail/domain/entities/project_funds_history_entity.dart';
import 'package:vestie/features/project_detail/presentation/cubit/project_funds_history_cubit.dart';
import '../widgets/project_funds_history/project_funds_history_row.dart';
import '../widgets/project_funds_history/project_funds_history_summary.dart';

/// Pooled pot ledger for vacation / emergency project detail.
///
/// Loads `GET /projects/{projectId}/funds-history` via [ProjectFundsHistoryCubit].
class ProjectFundsHistoryScreen extends StatelessWidget {
  final ProjectFundsHistoryRouteArgs args;

  const ProjectFundsHistoryScreen({super.key, required this.args});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ServiceLocator.instance.createProjectFundsHistoryCubit(
        args.projectId,
      ),
      child: _ProjectFundsHistoryBody(args: args),
    );
  }
}

class _ProjectFundsHistoryBody extends StatefulWidget {
  final ProjectFundsHistoryRouteArgs args;

  const _ProjectFundsHistoryBody({required this.args});

  @override
  State<_ProjectFundsHistoryBody> createState() =>
      _ProjectFundsHistoryBodyState();
}

class _ProjectFundsHistoryBodyState extends State<_ProjectFundsHistoryBody> {
  final ScrollController _scrollController = ScrollController();
  PaginatedScrollListener? _scrollListener;

  @override
  void initState() {
    super.initState();
    _scrollListener = PaginatedScrollListener(
      controller: _scrollController,
      onLoadMore: () => context.read<ProjectFundsHistoryCubit>().loadMore(),
    );
  }

  @override
  void dispose() {
    _scrollListener?.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  ProjectFundsHistoryEntryArgs _toEntryArgs(
    ProjectFundsHistoryEntryEntity entry,
  ) {
    return ProjectFundsHistoryEntryArgs(
      memberName: entry.name,
      dateLabel: entry.date != null
          ? AppFormatters.formatShortDate(entry.date!)
          : '',
      amount: entry.signedAmount,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: PostAuthGradientBackground(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PostAuthHeader(
              title: AppStrings.menuProjectFundsHistory,
              leading: AppBackButton(onPressed: () => context.pop()),
            ),
            Expanded(
              child:
                  BlocConsumer<ProjectFundsHistoryCubit, ProjectFundsHistoryState>(
                    listenWhen: (prev, curr) =>
                        curr.loadFailed &&
                        !prev.loadFailed &&
                        curr.entries.isNotEmpty,
                    listener: (context, state) {
                      AppToast.showError(
                        context,
                        state.errorMessage ??
                            AppStrings.errorLoadProjectFundsHistory,
                      );
                    },
                    builder: (context, state) {
                      if (state.loading) {
                        return const SingleChildScrollView(
                          padding: EdgeInsets.fromLTRB(16, 0, 16, 32),
                          physics: NeverScrollableScrollPhysics(),
                          child: ProjectFundsHistoryListShimmer(),
                        );
                      }

                      if (state.loadFailed && state.entries.isEmpty) {
                        return AppErrorView(
                          message: state.errorMessage,
                          onRetry: () =>
                              context.read<ProjectFundsHistoryCubit>().load(),
                        );
                      }

                      final entries = state.entries
                          .map(_toEntryArgs)
                          .toList(growable: false);

                      return SingleChildScrollView(
                        controller: _scrollController,
                        padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 32.h),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ProjectFundsHistorySummary(
                              currentPotBalance: state.currentPotBalance,
                              layout: widget.args.isInvestment
                                  ? ProjectFundsHistorySummaryLayout.investment
                                  : ProjectFundsHistorySummaryLayout.pooled,
                              totalContribution: state.totalContribution,
                              activeBorrows: state.activeBorrows,
                              useBreakdownSectionTitle:
                                  widget.args.useBreakdownSectionTitle,
                            ),
                            if (entries.isEmpty)
                              _EmptyLedgerCard()
                            else
                              ...entries.map(
                                (e) => ProjectFundsHistoryRow(entry: e),
                              ),
                            ListLoadMoreFooter(loadingMore: state.loadingMore),
                          ],
                        ),
                      );
                    },
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyLedgerCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 28.h, horizontal: 16.w),
      decoration: BoxDecoration(
        color: AppColors.projectFundsLedgerCardBg,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.projectFundsLedgerBorder, width: 1),
      ),
      child: AppText(
        AppStrings.projectFundsHistoryEmpty,
        textAlign: TextAlign.center,
        style: GoogleFonts.lato(
          fontSize: 15.sp,
          fontWeight: FontWeight.w500,
          color: AppColors.grey800,
        ),
      ),
    );
  }
}
