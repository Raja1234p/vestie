import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/common/app_text.dart';
import '../../domain/entities/payment_card.dart';
import 'card_detail_sheet.dart';
import 'payment_primary_button.dart';

class PaymentCardList extends StatelessWidget {
  final List<PaymentCard> cards;
  final VoidCallback onAdd;

  const PaymentCardList({super.key, required this.cards, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 0),
            itemCount: cards.length,
            separatorBuilder: (context, _) => SizedBox(height: 8.h),
            itemBuilder: (_, i) => _PaymentCardItem(
              card: cards[i],
              onTap: () => CardDetailSheet.show(context, cards[i]),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 32.h),
          child: PaymentPrimaryButton(
            label: AppStrings.btnAddCard,
            onTap: onAdd,
          ),
        ),
      ],
    );
  }
}

class _PaymentCardItem extends StatelessWidget {
  final PaymentCard card;
  final VoidCallback onTap;

  const _PaymentCardItem({required this.card, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: Ink(
        decoration: BoxDecoration(
          color: AppColors.settingsCardBg,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
          child: Row(
            children: [
              SvgPicture.asset(
                card.brand == CardBrand.visa ? AppAssets.iconVisa : AppAssets.iconMastercard,
                width: 40.w,
                height: 26.h,
              ),
              SizedBox(width: 10.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    card.brandName,
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  AppText(
                    card.maskedNumber,
                    style: GoogleFonts.inter(fontSize: 11.sp, color: AppColors.textBody),
                  ),
                ],
              ),
              const Spacer(),
              if (card.isPrimary) ...[
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: AppColors.badgeOnGoingBg,
                    borderRadius: BorderRadius.circular(100.r),
                  ),
                  child: AppText(
                    AppStrings.cardPrimary,
                    style: GoogleFonts.inter(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.badgeOnGoingText,
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
              ],
              Icon(Icons.chevron_right_rounded, size: 18.w, color: AppColors.primary),
            ],
          ),
        ),
      ),
    );
  }
}
