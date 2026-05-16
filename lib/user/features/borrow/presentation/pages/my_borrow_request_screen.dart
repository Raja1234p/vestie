import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:vestie/app/router/app_routes.dart';
import 'package:vestie/app/router/route_args/project_detail_flow_args.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/common/app_back_button.dart';
import 'package:vestie/core/widgets/common/app_button.dart';
import 'package:vestie/core/widgets/common/post_auth_gradient_background.dart';
import 'package:vestie/core/widgets/common/post_auth_header.dart';

import '../widgets/cancel_borrow_request_dialog.dart';
import '../widgets/my_borrow_request_active_body.dart';
import '../widgets/my_borrow_request_empty_body.dart';

/// Member “My Borrow Request” — Figma empty + active states.
class MyBorrowRequestScreen extends StatelessWidget {
  final MyBorrowRequestRouteArgs args;

  const MyBorrowRequestScreen({super.key, required this.args});

  bool get _hasActiveRequest => args.activeRequest != null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: false,
      body: PostAuthGradientBackground(
        child: Column(
          children: [
            PostAuthHeader(
              title: AppStrings.myBorrowRequestTitle,
              leading: AppBackButton(onPressed: () => context.pop()),
            ),
            Expanded(
              child: _hasActiveRequest
                  ? SingleChildScrollView(
                      child: MyBorrowRequestActiveBody(
                        activeRequest: args.activeRequest!,
                        history: args.history,
                      ),
                    )
                  : const Center(
                      child: MyBorrowRequestEmptyBody(),
                    ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 15.h),
                child: AppButton(
                  text: _hasActiveRequest
                      ? AppStrings.btnCancelBorrowRequest
                      : AppStrings.btnMakeBorrowRequest,
                  onPressed: () => _onPrimaryAction(context),
                  useGradient: false,
                  hasShadow: false,
                  color: _hasActiveRequest
                      ? AppColors.red900
                      : AppColors.grey1200,
                  borderRadius: 12.r,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onPrimaryAction(BuildContext context) {
    if (_hasActiveRequest) {
      showCancelBorrowRequestDialog(
        context,
        onConfirm: () {
          if (context.mounted) context.pop();
        },
      );
      return;
    }
    context.push(AppRoutes.borrowFlow, extra: args.walletFlowArgs);
  }
}
