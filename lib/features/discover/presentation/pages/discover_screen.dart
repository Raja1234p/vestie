import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/common/app_loader.dart';
import '../../../home/presentation/widgets/project_card.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dashBg,
      body: BlocBuilder<DiscoverCubit, DiscoverState>(
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
                        onAction: () {},
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
    );
  }
}
