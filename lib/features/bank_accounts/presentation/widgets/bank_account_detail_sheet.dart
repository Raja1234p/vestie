import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:vestie/core/constants/app_assets.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/common/app_svg_icon.dart';
import 'package:vestie/core/widgets/text/app_text.dart';
import 'package:vestie/features/bank_accounts/domain/entities/bank_account_entity.dart';
import 'package:vestie/features/bank_accounts/presentation/widgets/bank_account_primary_badge.dart';

class BankAccountDetailSheet extends StatelessWidget {
  final BankAccountEntity account;

  const BankAccountDetailSheet({super.key, required this.account});

  static Future<void> show(BuildContext context, BankAccountEntity account) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (_) => BankAccountDetailSheet(account: account),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = math.max(
      60.h,
      MediaQuery.viewPaddingOf(context).bottom + 8.h,
    );

    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: context.pop,
            child: AppSvgIcon(
              assetPath: AppAssets.iconClose,
              size: 24.w,
              color: AppColors.grey900,
            ),
          ),
          SizedBox(height: 20.h),
          _BankSummaryCard(account: account),
        ],
      ),
    );
  }
}

class _BankSummaryCard extends StatelessWidget {
  const _BankSummaryCard({required this.account});

  final BankAccountEntity account;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.appBgBottom,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: AppText(
                  account.displayName,
                  style: GoogleFonts.lato(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    height: 1.25,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (account.isDefault) const BankAccountPrimaryBadge(),
            ],
          ),
          if (account.last4.isNotEmpty) ...[
            SizedBox(height: 8.h),
            AppText(
              '•••• ${account.last4}',
              style: GoogleFonts.lato(
                fontSize: 15.sp,
                color: AppColors.neutral500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
