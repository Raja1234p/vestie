import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:vestie/core/constants/app_assets.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/theme/app_colors.dart';
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
  final highlighted = base?.copyWith(
    fontWeight: FontWeight.w700,
    decoration: TextDecoration.underline,
  );
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

Future<void> showApproveBorrowRequestFlow(
  BuildContext context,
  BorrowRequestEntity request, [
  Future<bool> Function()? onConfirmed,
]) async {
  await AppActionDialog.show(
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
      if (onConfirmed == null) {
        Navigator.of(context).pop();
        return;
      }
      final ok = await onConfirmed();
      if (!context.mounted || !ok) return;
      Navigator.of(context).pop();
    },
  );
  if (!context.mounted) return;
  await AppActionDialog.showSuccessOk(
    context,
    title: AppStrings.borrowApprovedTitle,
    descriptionWidget: _borrowDescription(
      context,
      isApprove: true,
      request: request,
    ),
    onPrimary: () => Navigator.of(context).pop(),
  );
}

Future<void> showRejectBorrowRequestFlow(
  BuildContext context,
  BorrowRequestEntity request, [
  Future<bool> Function()? onConfirmed,
]) async {
  await AppActionDialog.show(
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
      if (onConfirmed == null) {
        Navigator.of(context).pop();
        return;
      }
      final ok = await onConfirmed();
      if (!context.mounted || !ok) return;
      Navigator.of(context).pop();
    },
  );
  if (!context.mounted) return;
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
    onPrimary: () => Navigator.of(context).pop(),
  );
}
