import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/widgets/common/app_amount_entry_sheet_content.dart';
import 'package:vestie/leader/features/create_project/domain/create_project_form.dart';
import 'package:vestie/leader/features/create_project/presentation/cubit/create_project_cubit.dart';

String _amountPromptFor(NewProjectCategory category) => switch (category) {
      NewProjectCategory.vacation => AppStrings.projectAmountPromptVacation,
      NewProjectCategory.investment =>
        AppStrings.projectAmountPromptInvestment,
      NewProjectCategory.emergency => AppStrings.projectAmountPromptEmergency,
    };

/// Figma “set amount” step — shared by [showCreateProjectAmountSheet] and route.
class CreateProjectAmountSheetContent extends StatelessWidget {
  const CreateProjectAmountSheetContent({
    super.key,
    required this.onFinished,
  });

  final ValueChanged<bool> onFinished;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CreateProjectCubit, CreateProjectForm>(
      builder: (context, form) {
        final cubit = context.read<CreateProjectCubit>();
        return AppAmountEntrySheetContent(
          title: _amountPromptFor(form.category),
          amountDisplay: form.amountDigits.isEmpty
              ? AppStrings.projectAmountEmptyDisplay
              : form.formattedAmount,
          canContinue: form.amountDigits.isNotEmpty,
          onClose: () => onFinished(false),
          onContinue: () => onFinished(true),
          onDigit: cubit.appendAmountDigit,
          onBackspace: cubit.removeAmountDigit,
        );
      },
    );
  }
}
