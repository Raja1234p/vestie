import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:vestie/core/constants/app_dimens.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/text/app_text.dart';

/// One selectable payment row (card or wallet) with Figma radio trailing.
class PaymentMethodSelectRow extends StatelessWidget {
  const PaymentMethodSelectRow({
    super.key,
    required this.selected,
    required this.leading,
    required this.title,
    this.subtitle,
    required this.onTap,
    this.enabled = true,
  });

  final bool selected;
  final Widget leading;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.45,
      child: SizedBox(
        height: AppDimens.paymentMethodRowHeight,
        child: Container(
        decoration: BoxDecoration(
          color: AppColors.grey100,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: enabled ? onTap : null,
            borderRadius: BorderRadius.circular(12.r),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  leading,
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                      AppText(
                        title,
                        style: GoogleFonts.lato(
                          fontSize: 17.sp,
                          fontWeight: FontWeight.w800,
                          color: AppColors.grey1100,
                        ),
                      ),
                      if (subtitle != null) ...[
                        SizedBox(height: 2.h),
                        AppText(
                          subtitle!,
                          style: GoogleFonts.lato(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: AppColors.grey700,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                _PaymentMethodRadio(selected: selected),
                ],
              ),
            ),
          ),
        ),
      ),
      ),
    );
  }
}

class _PaymentMethodRadio extends StatelessWidget {
  const _PaymentMethodRadio({required this.selected});

  final bool selected;

  static const double _size = 20;

  @override
  Widget build(BuildContext context) {
    final outer = _size.w;
    if (selected) {
      final inner = outer / 3;
      return SizedBox(
        width: outer,
        height: outer,
        child: DecoratedBox(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.neutral1200,
          ),
          child: Center(
            child: SizedBox(
              width: inner,
              height: inner,
              child: const DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.surface,
                ),
              ),
            ),
          ),
        ),
      );
    }
    return SizedBox(
      width: outer,
      height: outer,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.neutral400,
            width: 2,
          ),
        ),
      ),
    );
  }
}
