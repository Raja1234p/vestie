import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:vestie/core/constants/app_dimens.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/di/service_locator.dart';
import 'package:vestie/core/presentation/paginated_scroll_listener.dart';
import 'package:vestie/core/presentation/widgets/list_load_more_footer.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/common/app_back_button.dart';
import 'package:vestie/core/widgets/common/app_error_view.dart';
import 'package:vestie/core/widgets/common/post_auth_gradient_background.dart';
import 'package:vestie/core/widgets/common/post_auth_header.dart';
import 'package:vestie/features/wallet/presentation/cubit/wallet_transactions_cubit.dart';
import 'package:vestie/features/wallet/presentation/widgets/wallet_recent_activity_empty.dart';
import 'package:vestie/features/wallet/presentation/widgets/wallet_recent_activity_list.dart';

/// Full wallet recent activity — paginated `GET /wallet/transactions`.
class WalletRecentActivityScreen extends StatefulWidget {
  const WalletRecentActivityScreen({super.key});

  @override
  State<WalletRecentActivityScreen> createState() =>
      _WalletRecentActivityScreenState();
}

class _WalletRecentActivityScreenState extends State<WalletRecentActivityScreen> {
  final ScrollController _scrollController = ScrollController();
  PaginatedScrollListener? _scrollListener;

  @override
  void initState() {
    super.initState();
    _scrollListener = PaginatedScrollListener(
      controller: _scrollController,
      onLoadMore: () {
        if (!mounted) return;
        context.read<WalletTransactionsCubit>().loadMore();
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
      create: (_) => WalletTransactionsCubit(
        getWalletTransactionsUseCase:
            ServiceLocator.instance.getWalletTransactionsUseCase,
      )..load(),
      child: BlocBuilder<WalletTransactionsCubit, WalletTransactionsState>(
        builder: (context, state) {
          return Scaffold(
            backgroundColor: Colors.transparent,
            body: PostAuthGradientBackground(
              child: Column(
                children: [
                  PostAuthHeader(
                    title: AppStrings.recentActivityHeader,
                    padding: EdgeInsets.fromLTRB(
                      AppDimens.p16,
                      AppDimens.v16,
                      AppDimens.p16,
                      0,
                    ),
                    leading: AppBackButton(
                      onPressed: context.pop,
                      color: AppColors.textPrimary,
                    ),
                  ),
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
                      child: state.loading
                          ? const Center(child: CircularProgressIndicator())
                          : state.hasLoadError
                          ? AppErrorView(
                              message: state.errorMessage ?? AppStrings.errorGeneric,
                              onRetry: () =>
                                  context.read<WalletTransactionsCubit>().load(),
                            )
                          : state.items.isEmpty
                          ? const WalletRecentActivityEmpty()
                          : WalletRecentActivityList(
                              transactions: state.items,
                              scrollController: _scrollController,
                              footer: ListLoadMoreFooter(
                                loadingMore: state.loadingMore,
                              ),
                            ),
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
}
