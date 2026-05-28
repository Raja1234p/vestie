import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:vestie/core/constants/app_dimens.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/common/app_back_button.dart';
import 'package:vestie/core/widgets/common/post_auth_gradient_background.dart';
import 'package:vestie/core/widgets/common/post_auth_header.dart';
import 'package:vestie/features/profile/domain/mock_profile_data.dart';
import 'package:vestie/features/wallet/presentation/widgets/wallet_recent_activity_empty.dart';
import 'package:vestie/features/wallet/presentation/widgets/wallet_recent_activity_list.dart';

/// Full wallet Recent Activity screen.
/// Reuses the same card/list UI as the wallet tab section.
class WalletRecentActivityScreen extends StatelessWidget {
  const WalletRecentActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final transactions = MockProfileData.transactions;

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
                child: transactions.isEmpty
                    ? const WalletRecentActivityEmpty()
                    : WalletRecentActivityList(transactions: transactions),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
