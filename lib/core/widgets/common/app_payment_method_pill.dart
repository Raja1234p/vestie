import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../constants/app_assets.dart';
import '../../constants/app_strings.dart';
import '../../theme/app_colors.dart';
import 'package:vestie/core/widgets/common/app_svg_icon.dart';
import 'package:vestie/features/profile/domain/entities/payment_card.dart';
import 'package:vestie/features/profile/presentation/widgets/payment_card_brand_icon.dart';

/// Wallet balance or saved card pill for contribute / payment confirm rows.
enum _AppPaymentMethodPillKind { wallet, card, placeholder }

class AppPaymentMethodPill extends StatelessWidget {
  const AppPaymentMethodPill.wallet({
    super.key,
    required this.formattedBalance,
    this.showChevron = false,
    this.onTap,
    this.hasError = false,
  }) : card = null,
       placeholderLabel = null,
       _kind = _AppPaymentMethodPillKind.wallet;

  const AppPaymentMethodPill.card({
    super.key,
    required this.card,
    this.showChevron = false,
    this.onTap,
    this.hasError = false,
  }) : formattedBalance = '',
       placeholderLabel = null,
       _kind = _AppPaymentMethodPillKind.card;

  const AppPaymentMethodPill.placeholder({
    super.key,
    required this.placeholderLabel,
    this.showChevron = true,
    this.onTap,
    this.hasError = false,
  }) : formattedBalance = '',
       card = null,
       _kind = _AppPaymentMethodPillKind.placeholder;

  final _AppPaymentMethodPillKind _kind;
  final String formattedBalance;
  final PaymentCard? card;
  final String? placeholderLabel;
  final bool showChevron;
  final VoidCallback? onTap;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(999.r);
    final child = switch (_kind) {
      _AppPaymentMethodPillKind.wallet => _walletContent(),
      _AppPaymentMethodPillKind.card => _cardContent(),
      _AppPaymentMethodPillKind.placeholder => _placeholderContent(),
    };

    final pill = Container(
      constraints: BoxConstraints(minWidth: 140.w),
      height: 40.h,
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: radius,
        border: Border.all(
          color: hasError ? AppColors.error : AppColors.neutral400,
          width: hasError ? 1.5 : 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(child: child),
          if (showChevron) ...[
            SizedBox(width: 8.w),
            AppSvgIcon(assetPath: AppAssets.walletPaymentChevron, size: 8.sp),
          ],
        ],
      ),
    );

    if (onTap == null) return pill;

    return Material(
      type: MaterialType.transparency,
      child: InkWell(onTap: onTap, borderRadius: radius, child: pill),
    );
  }

  Widget _walletContent() {
    final base = GoogleFonts.lato(
      fontSize: 14.sp,
      color: AppColors.neutral1200,
    );
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

  Widget _placeholderContent() {
    return Text(
      placeholderLabel ?? AppStrings.labelSelectPaymentCard,
      style: GoogleFonts.lato(
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
        color: hasError ? AppColors.error : AppColors.neutral700,
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
          child: PaymentCardBrandIcon(
            brand: c.brand,
            width: 32.w,
            height: 20.h,
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
