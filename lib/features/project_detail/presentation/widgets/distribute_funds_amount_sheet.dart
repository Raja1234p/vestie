import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vestie/core/constants/app_dimens.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/presentation/cubit/amount_entry_cubit.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/common/app_amount_entry_sheet_content.dart';

/// Opens distribute-amount modal (same UI as create-project amount sheet).
Future<double?> showDistributeFundsAmountSheet(BuildContext context) {
  final parent = context;
  final amountCubit = AmountEntryCubit();

  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    barrierColor: AppColors.modalBarrier,
    backgroundColor: AppColors.surface,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppRadius.r24),
      ),
    ),
    builder: (sheetContext) {
      return BlocProvider.value(
        value: amountCubit,
        child: BlocBuilder<AmountEntryCubit, AmountEntryState>(
          builder: (context, state) {
            return ClipRRect(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(AppRadius.r24),
              ),
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.viewInsetsOf(sheetContext).bottom,
                ),
                child: AppAmountEntrySheetContent(
                  title: AppStrings.distributeAmountPrompt,
                  amountDisplay: state.amountDigits.isEmpty
                      ? AppStrings.projectAmountEmptyDisplay
                      : state.formattedAmount,
                  canContinue: state.amountDigits.isNotEmpty,
                  onClose: () => Navigator.of(sheetContext).pop(false),
                  onContinue: () => Navigator.of(sheetContext).pop(true),
                  onDigit: amountCubit.appendAmountDigit,
                  onBackspace: amountCubit.removeAmountDigit,
                ),
              ),
            );
          },
        ),
      );
    },
  ).then((committed) {
    final amountUsd = amountCubit.state.amountUsd;
    amountCubit.close();
    if (!parent.mounted || committed != true) return null;
    return amountUsd;
  });
}
