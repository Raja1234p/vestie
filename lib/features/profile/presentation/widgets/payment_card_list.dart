import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
  final bool isSelectionMode;

  const PaymentCardList({super.key, required this.cards, required this.onAdd, this.isSelectionMode = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 10,),
        Expanded(
          child: ListView.separated(
            padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 0),
            itemCount: cards.length,
            separatorBuilder: (context, _) => SizedBox(height: 8.h),
            itemBuilder: (_, i) => _PaymentCardItem(
              card: cards[i],
              onTap: () {
                if (isSelectionMode) {
                  context.pop(cards[i]);
                } else {
                  CardDetailSheet.show(context, cards[i]);
                }
              },
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
    return Container(
      decoration: BoxDecoration(
        color: AppColors.appBgBottom,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.neutral500)
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14.r),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            child: Row(
              children: [
                SvgPicture.asset(
                  card.brand == CardBrand.visa ? AppAssets.iconVisa : AppAssets.iconMastercard,
                  width: 28.w,
                  height: 15.h,
                ),
                SizedBox(width: 10.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      card.brandName,
                      style: GoogleFonts.lato(
                        fontSize: 17.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    AppText(
                      card.maskedNumber,
                      style: GoogleFonts.lato(fontSize: 14.sp, color: AppColors.neutral500),
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
                      style: GoogleFonts.lato(
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
      ),
    );
  }
}
