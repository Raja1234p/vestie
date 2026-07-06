import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:vestie/core/constants/app_dimens.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/di/service_locator.dart';
import 'package:vestie/core/presentation/paginated_scroll_listener.dart';
import 'package:vestie/core/presentation/widgets/list_load_more_footer.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/common/app_error_view.dart';
import 'package:vestie/core/widgets/common/app_shimmer.dart';
import 'package:vestie/core/widgets/common/post_auth_gradient_background.dart';
import 'package:vestie/features/profile/presentation/cubit/transaction_history_cubit.dart';
import 'package:vestie/features/profile/presentation/pages/tx_filter_bar.dart';
import 'package:vestie/features/profile/presentation/widgets/profile_sub_header.dart';
import 'package:vestie/features/profile/presentation/widgets/transaction_history_empty_view.dart';
import 'package:vestie/features/wallet/presentation/widgets/wallet_recent_activity_list.dart';

/// Profile transaction history — paginated `GET /wallet/transactions`.
class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  final ScrollController _scrollController = ScrollController();
  PaginatedScrollListener? _scrollListener;

  @override
  void initState() {
    super.initState();
    _scrollListener = PaginatedScrollListener(
      controller: _scrollController,
      onLoadMore: () {
        if (!mounted) return;
        context.read<TransactionHistoryCubit>().loadMore();
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
    return BlocProvider(
      create: (_) => TransactionHistoryCubit(
        getWalletTransactionsUseCase:
            ServiceLocator.instance.getWalletTransactionsUseCase,
      )..load(),
      child: BlocBuilder<TransactionHistoryCubit, TransactionHistoryState>(
        builder: (context, state) {
          return Scaffold(
            backgroundColor: Colors.transparent,
            resizeToAvoidBottomInset: false,
            body: PostAuthGradientBackground(
              child: Column(
                children: [
                  ProfileSubHeader(title: AppStrings.transactionHistoryTitle),
                  TxFilterBar(activeFilter: state.activeFilter),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      color: AppColors.surface,
                      padding: EdgeInsets.fromLTRB(
                        AppDimens.p16,
                        0,
                        AppDimens.p16,
                        0,
                      ),
                      child: _buildBody(context, state),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, TransactionHistoryState state) {
    if (state.loading) {
      return ListView.builder(
        padding: EdgeInsets.only(top: 16.h, bottom: 16.h),
        physics: const BouncingScrollPhysics(),
        itemCount: 7,
        itemBuilder: (context, index) => Padding(
          padding: EdgeInsets.only(bottom: 10.h),
          child: const WalletRecentActivityRowShimmer(),
        ),
      );
    }

    if (state.hasLoadError) {
      return AppErrorView(
        message: state.errorMessage ?? AppStrings.errorGeneric,
        onRetry: () => context.read<TransactionHistoryCubit>().load(),
      );
    }

    if (state.filtered.isEmpty) {
      return TransactionHistoryEmptyView(isFilterEmpty: state.isFilterEmpty);
    }

    return WalletRecentActivityList(
      transactions: state.filtered,
      scrollController: _scrollController,
      footer: ListLoadMoreFooter(loadingMore: state.loadingMore),
    );
  }
}
