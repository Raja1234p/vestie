import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:vestie/core/constants/app_assets.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/navigation/success_dialog_navigation.dart';
import 'package:vestie/core/widgets/common/app_action_dialog.dart';
import 'package:vestie/features/project_detail/domain/entities/borrow_request_entity.dart';

String _fmtAmount(double value) => value.toStringAsFixed(2);

Widget _borrowDescription(
  BuildContext context, {
  required bool isApprove,
  required BorrowRequestEntity request,
}) {
  final base = Theme.of(context).textTheme.bodyLarge?.copyWith(
    fontSize: 16.sp,
    color: AppColors.grey900,
    height: 1.5,
  );
  final highlighted = base?.copyWith(fontWeight: FontWeight.w700);
  final prefix = isApprove
      ? AppStrings.borrowApprovePrefix()
      : AppStrings.borrowRejectPrefix();
  final highlightedText =
      '${request.memberName} of \$${_fmtAmount(request.requestedAmount)}';
  return RichText(
    textAlign: TextAlign.center,
    text: TextSpan(
      style: base,
      children: [
        TextSpan(text: prefix),
        TextSpan(text: highlightedText, style: highlighted),
      ],
    ),
  );
}

Widget _borrowVoteDescription(
  BuildContext context, {
  required bool isUpvote,
  required BorrowRequestEntity request,
}) {
  final base = Theme.of(context).textTheme.bodyLarge?.copyWith(
    fontSize: 16.sp,
    color: AppColors.grey900,
    height: 1.5,
  );
  final highlighted = base?.copyWith(fontWeight: FontWeight.w700);
  final prefix = isUpvote
      ? AppStrings.borrowUpvotePrefix()
      : AppStrings.borrowDownvotePrefix();
  final highlightedText =
      '${request.memberName} of \$${_fmtAmount(request.requestedAmount)}';
  return RichText(
    textAlign: TextAlign.center,
    text: TextSpan(
      style: base,
      children: [
        TextSpan(text: prefix),
        TextSpan(text: highlightedText, style: highlighted),
      ],
    ),
  );
}

/// Returns true after the user dismisses the success dialog.
Future<bool> showApproveBorrowRequestFlow(
  BuildContext context,
  BorrowRequestEntity request, [
  Future<bool> Function()? onConfirmed,
]) async {
  final ok = await AppActionDialog.showAsync(
    context,
    title: AppStrings.approveBorrowRequestTitle,
    description: '',
    descriptionWidget: _borrowDescription(
      context,
      isApprove: true,
      request: request,
    ),
    primaryLabel: AppStrings.approveLabel,
    primaryColor: AppColors.green800,
    onPrimary: () async {
      if (onConfirmed == null) return true;
      return onConfirmed();
    },
  );
  if (!ok) return false;
  if (!context.mounted) return false;
  await AppActionDialog.showSuccessOk(
    context,
    title: AppStrings.borrowApprovedTitle,
    descriptionWidget: _borrowDescription(
      context,
      isApprove: true,
      request: request,
    ),
    onPrimary: popDialogAction(context),
  );
  return true;
}

/// Returns true after the user dismisses the success dialog.
Future<bool> showRejectBorrowRequestFlow(
  BuildContext context,
  BorrowRequestEntity request, [
  Future<bool> Function()? onConfirmed,
]) async {
  final ok = await AppActionDialog.showAsync(
    context,
    title: AppStrings.rejectBorrowRequestTitle,
    description: '',
    descriptionWidget: _borrowDescription(
      context,
      isApprove: false,
      request: request,
    ),
    primaryLabel: AppStrings.rejectShortLabel,
    primaryColor: AppColors.red800,
    onPrimary: () async {
      if (onConfirmed == null) return true;
      return onConfirmed();
    },
  );
  if (!ok) return false;
  if (!context.mounted) return false;
  await AppActionDialog.show(
    context,
    title: AppStrings.borrowRejectedTitle,
    description: '',
    descriptionWidget: _borrowDescription(
      context,
      isApprove: false,
      request: request,
    ),
    primaryLabel: AppStrings.btnBackToProject,
    showSecondary: false,
    primaryColor: AppColors.neutral1200,
    primaryTextColor: AppColors.surface,
    primaryBorderColor: AppColors.neutral1200,
    iconAsset: AppAssets.statusFailure,
    onPrimary: popDialogAction(context),
  );
  return true;
}

/// Member vote — same confirm dialog pattern as approve/reject; card shows voted banner after.
Future<bool> showUpvoteBorrowRequestFlow(
  BuildContext context,
  BorrowRequestEntity request, {
  required Future<bool> Function() onConfirmed,
}) async {
  return AppActionDialog.showAsync(
    context,
    title: AppStrings.upvoteBorrowRequestTitle,
    description: '',
    descriptionWidget: _borrowVoteDescription(
      context,
      isUpvote: true,
      request: request,
    ),
    primaryLabel: AppStrings.upvoteLabel,
    primaryColor: AppColors.green800,
    onPrimary: onConfirmed,
  );
}

/// Member vote — same confirm dialog pattern as approve/reject; card shows voted banner after.
Future<bool> showDownvoteBorrowRequestFlow(
  BuildContext context,
  BorrowRequestEntity request, {
  required Future<bool> Function() onConfirmed,
}) async {
  return AppActionDialog.showAsync(
    context,
    title: AppStrings.downvoteBorrowRequestTitle,
    description: '',
    descriptionWidget: _borrowVoteDescription(
      context,
      isUpvote: false,
      request: request,
    ),
    primaryLabel: AppStrings.downvoteLabel,
    primaryColor: AppColors.red800,
    onPrimary: onConfirmed,
  );
}
