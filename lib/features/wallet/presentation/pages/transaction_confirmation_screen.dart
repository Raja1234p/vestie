import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../app/router/app_routes.dart';
import '../../../../../core/constants/app_assets.dart';
import '../../../../../core/constants/app_strings.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/common/app_button.dart';
import '../../../../../core/widgets/text/app_text.dart';
import '../../../profile/domain/entities/payment_card.dart';
import '../../domain/wallet_transaction_type.dart';
import '../cubit/wallet_transaction_cubit.dart';

class TransactionConfirmationScreen extends StatelessWidget {
  const TransactionConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WalletTransactionCubit, WalletTransactionState>(
      builder: (context, state) {
        final isDeposit = state.transactionType == WalletTransactionType.deposit;
        final title = isDeposit ? AppStrings.confirmDepositTitle : AppStrings.confirmWithdrawTitle;
        final card = state.selectedCard;

        return Scaffold(
          backgroundColor: AppColors.appBgBottom,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary, size: 20.w),
              onPressed: () => context.pop(),
            ),
            title: AppText(
              title,
              style: GoogleFonts.lato(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            centerTitle: true,
          ),
          body: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 32.h),
                Center(
                  child: Column(
                    children: [
                      AppText(
                        AppStrings.labelAmount,
                        style: GoogleFonts.lato(
                          fontSize: 14.sp,
                          color: AppColors.neutral500,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      AppText(
                        state.formattedAmount,
                        style: GoogleFonts.lato(
                          fontSize: 48.sp,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 48.h),
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildSummaryRow(AppStrings.labelFee, '\$0.00'),
                      Divider(height: 32.h, color: AppColors.neutral200),
                      if (card != null) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            AppText(
                              isDeposit ? AppStrings.labelFrom : AppStrings.labelTo,
                              style: GoogleFonts.lato(
                                fontSize: 15.sp,
                                color: AppColors.neutral500,
                              ),
                            ),
                            Row(
                              children: [
                                SvgPicture.asset(
                                  card.brand == CardBrand.visa ? AppAssets.iconVisa : AppAssets.iconMastercard,
                                  width: 24.w,
                                ),
                                SizedBox(width: 8.w),
                                AppText(
                                  card.maskedNumber,
                                  style: GoogleFonts.lato(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const Spacer(),
                SafeArea(
                  minimum: EdgeInsets.only(bottom: 24.h),
                  child: AppButton(
                    text: AppStrings.btnConfirm,
                    onPressed: () {
                      // Perform API call theoretically
                      
                      // Navigate to success
                      context.pushReplacement(AppRoutes.transactionSuccess);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        AppText(
          label,
          style: GoogleFonts.lato(
            fontSize: 15.sp,
            color: AppColors.neutral500,
          ),
        ),
        AppText(
          value,
          style: GoogleFonts.lato(
            fontSize: 15.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
