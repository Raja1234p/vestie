import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../app/router/app_routes.dart';
import '../../../../../core/constants/app_assets.dart';
import '../../../../../core/constants/app_strings.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/common/app_success_screen.dart';
import '../../../../../core/widgets/text/app_text.dart';
import '../../domain/wallet_transaction_type.dart';
import '../cubit/wallet_transaction_cubit.dart';

class TransactionSuccessScreen extends StatelessWidget {
  const TransactionSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WalletTransactionCubit, WalletTransactionState>(
      builder: (context, state) {
        final isDeposit = state.transactionType == WalletTransactionType.deposit;
        final amountText = "${state.formattedAmount} ";
        
        return AppSuccessScreen(
          svgAssetPath: AppAssets.projectCreatedImage,
          title: isDeposit ? AppStrings.depositSuccessTitle : AppStrings.withdrawSuccessTitle,
          subtitleWidget: isDeposit
              ? Column(
                  children: [
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: GoogleFonts.lato(
                          fontSize: 18.sp,
                          color: AppColors.textBody,
                          height: 1,
                        ),
                        children: [
                          TextSpan(
                            text: amountText,
                            style: GoogleFonts.lato(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const TextSpan(text: AppStrings.depositAddedPrefix),
                        ],
                      ),
                    ),
                    AppText(
                      AppStrings.depositAddedLineTwo,
                      style: GoogleFonts.lato(
                        fontSize: 18.sp,
                        color: AppColors.textBody,
                        height: 1.1,
                      ),
                    ),
                  ],
                )
              : Column(
                  children: [
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: GoogleFonts.lato(
                          fontSize: 16.sp,
                          color: AppColors.textBody,
                          height: 1,
                        ),
                        children: [
                          const TextSpan(text: AppStrings.withdrawEtaPrefix),
                          TextSpan(
                            text: amountText,
                            style: GoogleFonts.lato(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const TextSpan(text: AppStrings.withdrawEtaSuffix),
                        ],
                      ),
                    ),
                    AppText(
                      AppStrings.withdrawEtaLineTwo,
                      style: GoogleFonts.lato(
                        fontSize: 16.sp,
                        color: AppColors.textBody,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
          buttonText:  AppStrings.btnDone,
          onButtonPressed: () {
            context.read<WalletTransactionCubit>().reset();
            context.go(AppRoutes.dashboard);
          },
        );
      },
    );
  }
}
