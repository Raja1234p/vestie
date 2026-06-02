import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:vestie/core/constants/app_dimens.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/error/failure_mapper.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/common/app_back_button.dart';
import 'package:vestie/core/widgets/common/app_error_view.dart';
import 'package:vestie/core/widgets/common/post_auth_gradient_background.dart';
import 'package:vestie/core/widgets/common/post_auth_header.dart';
import 'package:vestie/features/wallet/presentation/cubit/wallet_cubit.dart';
import 'package:vestie/features/wallet/presentation/cubit/wallet_state.dart';
import 'package:vestie/features/wallet/presentation/widgets/wallet_recent_activity_empty.dart';
import 'package:vestie/features/wallet/presentation/widgets/wallet_recent_activity_list.dart';

/// Full wallet recent activity — same `GET /wallet` data as the wallet tab.
class WalletRecentActivityScreen extends StatelessWidget {
  const WalletRecentActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WalletCubit, WalletState>(
      builder: (context, state) {
        final transactions = state.recentActivity;

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
                    AppDimens.v8,
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
                      AppDimens.v8,
                      AppDimens.p16,
                      0,
                    ),
                    child: state.hasLoadError
                        ? AppErrorView(
                            message:
                                FailureMapper.userMessage(state.failure!),
                            onRetry: () => context
                                .read<WalletCubit>()
                                .load(forceRefresh: true),
                          )
                        : transactions.isEmpty
                            ? const WalletRecentActivityEmpty()
                            : WalletRecentActivityList(
                                transactions: transactions,
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
