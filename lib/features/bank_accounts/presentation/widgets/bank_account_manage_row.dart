import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:vestie/core/constants/app_assets.dart';
import 'package:vestie/core/constants/app_dimens.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/common/app_svg_icon.dart';
import 'package:vestie/core/widgets/text/app_text.dart';
import 'package:vestie/features/bank_accounts/domain/entities/bank_account_entity.dart';
import 'package:vestie/features/bank_accounts/presentation/widgets/bank_account_primary_badge.dart';

class BankAccountManageRow extends StatelessWidget {
  final BankAccountEntity account;
  final VoidCallback onTap;
  final bool showChevron;

  const BankAccountManageRow({
    super.key,
    required this.account,
    required this.onTap,
    this.showChevron = true,
  });

  @override
  Widget build(BuildContext context) {
    final subtitle = account.last4.isNotEmpty
        ? '•••• ${account.last4}'
        : account.bankName;

    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: AppDimens.paymentMethodRowHeight),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.appBgBottom,
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(14.r),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 32.w,
                    height: 32.h,
                    child: SvgPicture.asset(
                      AppAssets.iconDollarCircle,
                      fit: BoxFit.contain,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText(
                          account.displayName,
                          style: GoogleFonts.lato(
                            fontSize: 17.sp,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                            height: 1.25,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (subtitle.isNotEmpty)
                          AppText(
                            subtitle,
                            style: GoogleFonts.lato(
                              fontSize: 14.sp,
                              color: AppColors.neutral500,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (account.isDefault) ...[
                    const BankAccountPrimaryBadge(),
                    SizedBox(width: 8.w),
                  ],
                  if (showChevron)
                    AppSvgIcon(
                      assetPath: AppAssets.iconChevronRight,
                      size: 18.w,
                      color: AppColors.primary,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
