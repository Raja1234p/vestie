import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:vestie/app/router/app_routes.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/widgets/common/app_button.dart';
import '../../domain/entities/project_detail_entity.dart';
import '../navigation/project_detail_navigation_helpers.dart';

/// Contribute (+ optional Borrow) CTAs below [ProjectInfoCard].
class ProjectDetailWalletActions extends StatelessWidget {
  final ProjectDetailEntity project;

  const ProjectDetailWalletActions({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    final walletArgs = ProjectDetailNavigationHelpers.walletArgs(project);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppButton(
          text: AppStrings.btnContribute,
          onPressed: () => context.push(
            AppRoutes.contributeFlow,
            extra: walletArgs,
          ),
        ),
        if (project.showsBorrowAction) ...[
          SizedBox(height: 13.h),
          AppButton(
            text: AppStrings.btnBorrow,
            onPressed: () => context.push(
              AppRoutes.borrowFlow,
              extra: walletArgs,
            ),
            isSecondary: true,
          ),
        ],
      ],
    );
  }
}
