import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/common/app_text.dart';
import '../cubit/transaction_history_cubit.dart';

class TxFilterBar extends StatelessWidget {
  final String activeFilter;
  const TxFilterBar({super.key, required this.activeFilter});

  static const _filters = [
    AppStrings.filterAllTx,
    AppStrings.filterDeposits,
    AppStrings.filterWithdrawals,
    AppStrings.filterContributions,
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: EdgeInsets.fromLTRB(0, 10.h, 0, 10.h),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _filters.map((filter) {
            final active = filter == activeFilter;
            return GestureDetector(
              onTap: () => context.read<TransactionHistoryCubit>().selectFilter(filter),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: EdgeInsets.only(right: 8.w),
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
                decoration: BoxDecoration(
                  color: active ? AppColors.chipActiveBg : AppColors.chipInactiveBg,
                  borderRadius: BorderRadius.circular(24.r),
                  border: Border.all(
                    color: active ? AppColors.primary : AppColors.chipBorder,
                    width: 1,
                  ),
                  boxShadow: active
                      ? const [
                          BoxShadow(
                            color: AppColors.purple300,
                            offset: Offset(0, 4),
                            blurRadius: 7.6,
                            spreadRadius: 0,
                          ),
                          // Figma includes an inner shadow; this is the closest
                          // lightweight approximation using standard BoxShadow.
                          BoxShadow(
                            color: Color(0xFF8563D0),
                            offset: Offset(0, 4),
                            blurRadius: 4,
                            spreadRadius: -1,
                          ),
                        ]
                      : null,
                ),
                child: AppText(
                  filter,
                  style: GoogleFonts.lato(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: active ? AppColors.chipActiveText : AppColors.chipInactiveText,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
