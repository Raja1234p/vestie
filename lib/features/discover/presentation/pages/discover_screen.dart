import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/common/app_loader.dart';
import '../../../../core/widgets/common/post_auth_gradient_background.dart';
import '../../../home/domain/entities/project.dart';
import '../../../home/presentation/widgets/project_card.dart';
import '../../../project_detail/domain/entities/borrow_request_entity.dart';
import '../../../project_detail/domain/entities/member_entity.dart';
import '../../../project_detail/domain/entities/project_detail_entity.dart';
import '../../../project_detail/domain/entities/project_detail_route_args.dart';
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
      // Discover cards are always joined (not owned) — no leader menu
      isLeader: false,
    );
    context.push(
      AppRoutes.projectDetail,
      extra: ProjectDetailRouteArgs(project: detail),
    );
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
                const SliverFillRemaining(
                  child: AppLoader(),
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
                        onAction: () =>
                            _navigateToDetail(context, state.filtered[i]),
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
