import 'package:flutter/material.dart';

import 'package:vestie/core/error/failure_mapper.dart';
import 'package:vestie/core/widgets/common/app_toast.dart';
import 'package:vestie/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:vestie/features/profile/presentation/widgets/delete_account_confirm_dialog.dart';

const Duration _deleteAccountIneligibleToastDuration = Duration(seconds: 10);
/// Profile ⋯ → Delete Account: existing confirm dialog first; APIs on confirm tap.
Future<void> openDeleteAccountFlow(
  BuildContext context,
  ProfileCubit cubit,
) {
  return showDeleteAccountConfirmDialog(
    context,
    onConfirm: () => _onDeleteAccountConfirmed(context, cubit),
  );
}

Future<bool> _onDeleteAccountConfirmed(
  BuildContext context,
  ProfileCubit cubit,
) async {
  final eligibilityResult = await cubit.checkDeletionEligibility();

  final eligible = await eligibilityResult.fold(
    (failure) async {
      if (context.mounted) {
        AppToast.showError(context, FailureMapper.userMessage(failure));
      }
      return false;
    },
    (eligibility) async {
      if (eligibility.isEligible) return true;

      if (context.mounted) {
        final message = eligibility.displayIneligibilityMessage;
        if (message.isNotEmpty) {
          AppToast.showError(
            context,
            message,
            duration: _deleteAccountIneligibleToastDuration,
          );
        }
      }      return false;
    },
  );

  if (!eligible) return false;

  final deleteResult = await cubit.deleteAccountConfirmed();
  if (!deleteResult.success) {
    if (context.mounted && deleteResult.errorMessage != null) {
      AppToast.showError(context, deleteResult.errorMessage!);
    }
    return false;
  }

  return true;
}
