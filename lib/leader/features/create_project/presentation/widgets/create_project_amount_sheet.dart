import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:vestie/app/router/app_routes.dart';
import 'package:vestie/core/constants/app_dimens.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/leader/features/create_project/presentation/cubit/create_project_cubit.dart';
import 'package:vestie/leader/features/create_project/presentation/widgets/create_project_amount_sheet_content.dart';

/// Opens the Create Project amount step as a modal bottom sheet (home Add).
void showCreateProjectAmountSheet(BuildContext context) {
  final parent = context;
  parent.read<CreateProjectCubit>().reset();
  showModalBottomSheet<bool>(
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
      return ClipRRect(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.r24),
        ),
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(sheetContext).bottom,
          ),
          child: CreateProjectAmountSheetContent(
            onFinished: (committed) =>
                Navigator.of(sheetContext).pop(committed),
          ),
        ),
      );
    },
  ).then((committed) {
    if (!parent.mounted) return;
    if (committed == true) {
      parent.push(AppRoutes.createProjectDetails);
    } else {
      parent.read<CreateProjectCubit>().reset();
    }
  });
}
