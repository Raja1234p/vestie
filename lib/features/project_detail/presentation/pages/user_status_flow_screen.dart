import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/common/app_back_button.dart';
import '../../../../core/widgets/common/app_outline_neutral_button.dart';
import '../../../../core/widgets/common/centered_hero_status_block.dart';
import '../../../../core/widgets/common/post_auth_gradient_background.dart';
import '../../../../core/widgets/common/post_auth_header.dart';
import '../../domain/entities/project_detail_route_args.dart';
import '../models/user_status_flow_copy.dart';

/// Member: join result or mark-vote submission feedback.
class UserStatusFlowScreen extends StatelessWidget {
  final String projectName;
  final UserStatusFlowKind kind;

  const UserStatusFlowScreen({
    super.key,
    required this.projectName,
    required this.kind,
  });

  @override
  Widget build(BuildContext context) {
    final data = UserStatusFlowCopy.forKind(kind);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: PostAuthGradientBackground(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PostAuthHeader(
              title: projectName,
              leading: AppBackButton(
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go(AppRoutes.dashboard);
                  }
                },
              ),
            ),
            Expanded(
              child: CenteredHeroStatusBlock(
                imageAsset: data.imageAsset,
                headline: data.headline,
                body: data.body,
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
                child: AppOutlineNeutralButton(
                  label: AppStrings.btnBackToHome,
                  onPressed: () => context.go(AppRoutes.dashboard),
                  borderRadius: AppRadius.r8,
                  borderColor: AppColors.backToHomeButtonBorder,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
