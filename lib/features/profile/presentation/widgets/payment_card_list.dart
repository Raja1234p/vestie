import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:vestie/core/constants/app_assets.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/common/app_purple_dashed_line.dart';
import 'package:vestie/core/widgets/common/app_svg_icon.dart';
import 'package:vestie/core/widgets/common/flow_screen_footer.dart';
import 'package:vestie/core/widgets/text/app_text.dart';
import 'package:vestie/features/profile/domain/entities/payment_card.dart';
import 'package:vestie/features/profile/domain/entities/payment_method_selection.dart';
import 'package:vestie/features/profile/presentation/widgets/card_detail_sheet.dart';
import 'package:vestie/features/profile/presentation/widgets/payment_method_select_row.dart';
import 'package:vestie/features/profile/presentation/widgets/payment_primary_button.dart';

class PaymentCardList extends StatefulWidget {
  final List<PaymentCard> cards;
  final VoidCallback onAdd;
  final bool isSelectionMode;

  const PaymentCardList({
    super.key,
    required this.cards,
    required this.onAdd,
    this.isSelectionMode = false,
  });

  @override
  State<PaymentCardList> createState() => _PaymentCardListState();
}

class _PaymentCardListState extends State<PaymentCardList> {
  /// `null` = wallet selected; otherwise selected card id.
  String? _selectedCardId;

  @override
  void initState() {
    super.initState();
    if (widget.isSelectionMode && widget.cards.isNotEmpty) {
      PaymentCard? primary;
      for (final c in widget.cards) {
        if (c.isPrimary) {
          primary = c;
          break;
        }
      }
      _selectedCardId = (primary ?? widget.cards.first).id;
    }
  }

  void _selectCard(PaymentCard card) {
    if (!widget.isSelectionMode) {
      CardDetailSheet.show(context, card);
      return;
    }
    setState(() => _selectedCardId = card.id);
    context.pop(CardPaymentMethodSelection(card));
  }

  void _selectWallet() {
    setState(() => _selectedCardId = null);
    context.pop(const WalletPaymentMethodSelection());
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isSelectionMode) {
      return _SelectionList(
        cards: widget.cards,
        selectedCardId: _selectedCardId,
        onSelectCard: _selectCard,
        onSelectWallet: _selectWallet,
        onAdd: widget.onAdd,
      );
    }

    return Column(
      children: [
        SizedBox(height: 10.h),
        Expanded(
          child: ListView.separated(
            padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 0),
            itemCount: widget.cards.length,
            separatorBuilder: (context, index) => SizedBox(height: 8.h),
            itemBuilder: (_, i) => _ManageCardItem(
              card: widget.cards[i],
              onTap: () => _selectCard(widget.cards[i]),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 32.h),
          child: PaymentPrimaryButton(
            label: AppStrings.btnAddCard,
            onTap: widget.onAdd,
          ),
        ),
      ],
    );
  }
}

class _SelectionList extends StatelessWidget {
  const _SelectionList({
    required this.cards,
    required this.selectedCardId,
    required this.onSelectCard,
    required this.onSelectWallet,
    required this.onAdd,
  });

  final List<PaymentCard> cards;
  final String? selectedCardId;
  final ValueChanged<PaymentCard> onSelectCard;
  final VoidCallback onSelectWallet;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 10.h),
        Expanded(
          child: ListView(
            padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 0),
            children: [
              for (var i = 0; i < cards.length; i++) ...[
                if (i > 0) SizedBox(height: 8.h),
                PaymentMethodSelectRow(
                  selected: selectedCardId == cards[i].id,
                  leading: SvgPicture.asset(
                    cards[i].brand == CardBrand.visa
                        ? AppAssets.iconVisa
                        : AppAssets.iconMastercard,
                    width: 28.w,
                    height: 15.h,
                  ),
                  title: cards[i].brandName,
                  subtitle: cards[i].maskedNumber,
                  onTap: () => onSelectCard(cards[i]),
                ),
              ],
              SizedBox(height: 16.h),
              const AppPurpleDashedLine(
                color: AppColors.purple300,
                height: 1,
              ),
              SizedBox(height: 16.h),
              PaymentMethodSelectRow(
                selected: selectedCardId == null,
                leading: const PaymentMethodWalletIcon(),
                title: AppStrings.walletTitle,
                onTap: onSelectWallet,
              ),
            ],
          ),
        ),
        FlowScreenFooter(
          child: PaymentPrimaryButton(
            label: AppStrings.btnAddCard,
            onTap: onAdd,
          ),
        ),
      ],
    );
  }
}

class _ManageCardItem extends StatelessWidget {
  const _ManageCardItem({required this.card, required this.onTap});

  final PaymentCard card;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.appBgBottom,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.neutral500),
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
                  card.brand == CardBrand.visa
                      ? AppAssets.iconVisa
                      : AppAssets.iconMastercard,
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
                      style: GoogleFonts.lato(
                        fontSize: 14.sp,
                        color: AppColors.neutral500,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                if (card.isPrimary) ...[
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 3.h,
                    ),
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
    );
  }
}
