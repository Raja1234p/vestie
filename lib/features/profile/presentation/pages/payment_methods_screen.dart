import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/common/app_loader.dart';
import '../../domain/entities/payment_card.dart';
import '../cubit/payment_methods_cubit.dart';
import '../widgets/card_detail_sheet.dart';
import '../widgets/profile_sub_header.dart';

class PaymentMethodsScreen extends StatelessWidget {
  const PaymentMethodsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PaymentMethodsCubit(),
      child: const _PaymentBody(),
    );
  }
}

class _PaymentBody extends StatelessWidget {
  const _PaymentBody();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PaymentMethodsCubit, PaymentMethodsState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.dashBg,
          body: Column(
            children: [
              ProfileSubHeader(title: AppStrings.paymentMethodsTitle),
              Expanded(
                child: state.loading
                    ? const AppLoader()
                    : state.cards.isEmpty
                        ? _EmptyPayment(
                            onAdd: () => context.push(AppRoutes.addCard))
                        : _CardList(
                            cards: state.cards,
                            onAdd: () => context.push(AppRoutes.addCard)),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _EmptyPayment extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyPayment({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Spacer(),
        SvgPicture.asset(
          AppAssets.iconPaymentMethods,
          width: 72.w,
          height: 72.w,
          colorFilter: ColorFilter.mode(AppColors.primary, BlendMode.srcIn),
        ),
        SizedBox(height: 16.h),
        Text(AppStrings.emptyPaymentTitle,
            style: GoogleFonts.inter(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary)),
        SizedBox(height: 8.h),
        Text(AppStrings.emptyPaymentSubtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
                fontSize: 13.sp, color: AppColors.textBody, height: 1.5)),
        const Spacer(flex: 2),
        Padding(
          padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 32.h),
          child: _AddCardButton(onTap: onAdd),
        ),
      ],
    );
  }
}

class _CardList extends StatelessWidget {
  final List<PaymentCard> cards;
  final VoidCallback onAdd;
  const _CardList({required this.cards, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 0),
            itemCount: cards.length,
            separatorBuilder: (context, _) => const Divider(height: 1),
            itemBuilder: (_, i) => _CardItem(
              card: cards[i],
              onTap: () => CardDetailSheet.show(context, cards[i]),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 32.h),
          child: _AddCardButton(onTap: onAdd),
        ),
      ],
    );
  }
}

class _CardItem extends StatelessWidget {
  final PaymentCard card;
  final VoidCallback onTap;
  const _CardItem({required this.card, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        child: Row(
          children: [
            SvgPicture.asset(
              card.brand == CardBrand.visa
                  ? AppAssets.iconVisa
                  : AppAssets.iconMastercard,
              width: 40.w,
              height: 26.h,
            ),
            SizedBox(width: 12.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(card.brandName,
                    style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary)),
                Text(card.maskedNumber,
                    style: GoogleFonts.inter(
                        fontSize: 12.sp, color: AppColors.textBody)),
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
                child: Text(AppStrings.cardPrimary,
                    style: GoogleFonts.inter(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.badgeOnGoingText)),
              ),
              SizedBox(width: 8.w),
            ],
            Icon(Icons.chevron_right_rounded,
                size: 20.w, color: AppColors.textBody),
          ],
        ),
      ),
    );
  }
}

class _AddCardButton extends StatelessWidget {
  final VoidCallback onTap;
  const _AddCardButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50.h,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.cardActionBtn,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r)),
        ),
        child: Text(AppStrings.btnAddCard,
            style: GoogleFonts.inter(
                fontSize: 15.sp, fontWeight: FontWeight.w600)),
      ),
    );
  }
}
