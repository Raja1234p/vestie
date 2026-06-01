import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../constants/app_assets.dart';
import '../../constants/app_strings.dart';
import '../../theme/app_colors.dart';
import 'package:vestie/core/widgets/common/app_svg_icon.dart';
import 'package:vestie/features/profile/domain/entities/payment_card.dart';

/// Wallet balance or saved card pill for contribute / payment confirm rows.
class AppPaymentMethodPill extends StatelessWidget {
  const AppPaymentMethodPill.wallet({
    super.key,
    required this.formattedBalance,
    this.showChevron = false,
    this.onTap,
  })  : card = null,
        _isWallet = true;

  const AppPaymentMethodPill.card({
    super.key,
    required this.card,
    this.showChevron = false,
    this.onTap,
  })  : formattedBalance = '',
        _isWallet = false;

  final bool _isWallet;
  final String formattedBalance;
  final PaymentCard? card;
  final bool showChevron;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(999.r);
    final child = _isWallet ? _walletContent() : _cardContent();

    final pill = Container(
      constraints: BoxConstraints(minWidth: 140.w),
      height: 40.h,
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: radius,
        border: Border.all(color: AppColors.neutral400, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(child: child),
          if (showChevron) ...[
            SizedBox(width: 8.w),
            AppSvgIcon(
              assetPath: AppAssets.iconChevronWallet,
              size: 12.r,
            ),
          ],
        ],
      ),
    );

    if (onTap == null) return pill;

    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: pill,
      ),
    );
  }

  Widget _walletContent() {
    final base = GoogleFonts.lato(fontSize: 14.sp, color: AppColors.neutral1200);
    return Text.rich(
      TextSpan(
        style: base.copyWith(height: 1.0),
        children: [
          TextSpan(
            text: '${AppStrings.walletBalanceLabel} ',
            style: base.copyWith(fontWeight: FontWeight.w400),
          ),
          TextSpan(
            text: '\$$formattedBalance',
            style: base.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _cardContent() {
    final c = card!;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 32.w,
          height: 20.h,
          child: SvgPicture.asset(
            c.brand == CardBrand.visa
                ? AppAssets.iconVisa
                : AppAssets.iconMastercard,
            fit: BoxFit.contain,
          ),
        ),
        SizedBox(width: 8.w),
        Text(
          '••',
          style: GoogleFonts.lato(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.neutral700,
          ),
        ),
        SizedBox(width: 6.w),
        Text(
          c.last4,
          style: GoogleFonts.lato(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.neutral1200,
          ),
        ),
      ],
    );
  }
}
