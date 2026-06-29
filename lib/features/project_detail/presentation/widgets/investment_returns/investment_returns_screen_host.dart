import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vestie/app/router/route_args/project_detail_flow_args.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/di/service_locator.dart';
import 'package:vestie/core/presentation/paginated_scroll_listener.dart';
import 'package:vestie/core/presentation/widgets/list_load_more_footer.dart';
import 'package:vestie/core/widgets/common/app_error_view.dart';
import 'package:vestie/core/widgets/common/app_loader.dart';
import 'package:vestie/features/project_detail/presentation/cubit/investment_returns_cubit.dart';
import 'package:vestie/features/project_detail/presentation/cubit/investment_returns_state.dart';
import 'package:vestie/features/project_detail/presentation/models/investment_returns_ui_data.dart';
import 'package:vestie/features/project_detail/presentation/widgets/investment_returns/investment_returns_screen_shell.dart';

class InvestmentReturnsScreenHost extends StatelessWidget {
  final InvestmentReturnsRouteArgs args;
  final String title;
  final Widget? Function(BuildContext context, InvestmentReturnsUiData data)?
  footerBuilder;

  const InvestmentReturnsScreenHost({
    super.key,
    required this.args,
    required this.title,
    this.footerBuilder,
  });

  bool get _usesApiLoad =>
      !args.isPreview &&
      args.projectId != null &&
      args.projectId!.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    if (!_usesApiLoad) {
      final data = args.data;
      if (data == null) {
        return InvestmentReturnsScreenShell(
          title: title,
          data: InvestmentReturnsUiData(
            projectId: '',
            projectName: args.projectName ?? '',
            myContributionUsd: 0,
            receivedSoFarUsd: 0,
            distributions: const [],
            primarySummaryLabel: AppStrings.userInvestmentMyContributionLabel,
            receivedCardLabel: AppStrings.userInvestmentReceivedSoFarLabel,
            defaultLeftColumnLabel: AppStrings.investmentLeaderDistributionLabel,
          ),
          footer: null,
        );
      }
      return InvestmentReturnsScreenShell(
        title: title,
        data: data,
        footer: footerBuilder?.call(context, data),
      );
    }

    return BlocProvider(
      create: (_) => ServiceLocator.instance.createInvestmentReturnsCubit(args)
        ..load(),
      child: _InvestmentReturnsProductionBody(
        title: title,
        footerBuilder: footerBuilder,
      ),
    );
  }
}

class _InvestmentReturnsProductionBody extends StatefulWidget {
  final String title;
  final Widget? Function(BuildContext context, InvestmentReturnsUiData data)?
  footerBuilder;

  const _InvestmentReturnsProductionBody({
    required this.title,
    this.footerBuilder,
  });

  @override
  State<_InvestmentReturnsProductionBody> createState() =>
      _InvestmentReturnsProductionBodyState();
}

class _InvestmentReturnsProductionBodyState
    extends State<_InvestmentReturnsProductionBody> {
  final ScrollController _scrollController = ScrollController();
  PaginatedScrollListener? _scrollListener;

  @override
  void initState() {
    super.initState();
    _scrollListener = PaginatedScrollListener(
      controller: _scrollController,
      onLoadMore: () {
        if (!mounted) return;
        context.read<InvestmentReturnsCubit>().loadMoreDistributions();
      },
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
    return BlocBuilder<InvestmentReturnsCubit, InvestmentReturnsState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Scaffold(
            body: Center(child: AppLoader()),
          );
        }

        if (state.loadFailed) {
          return Scaffold(
            body: AppErrorView(
              message: state.loadErrorMessage ?? AppStrings.errorGeneric,
              onRetry: () => context.read<InvestmentReturnsCubit>().load(),
            ),
          );
        }

        final data = state.data;
        if (data == null) {
          return Scaffold(
            body: AppErrorView(
              message: AppStrings.errorGeneric,
              onRetry: () => context.read<InvestmentReturnsCubit>().load(),
            ),
          );
        }

        return InvestmentReturnsScreenShell(
          title: widget.title,
          data: data,
          footer: widget.footerBuilder?.call(context, data),
          scrollController: _scrollController,
          listFooter: ListLoadMoreFooter(
            loadingMore: state.distributionsLoadingMore,
          ),
        );
      },
    );
  }
}
