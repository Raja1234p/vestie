import 'package:intl/intl.dart';

import 'package:vestie/app/router/route_args/project_detail_flow_args.dart';
import 'package:vestie/features/project_detail/presentation/navigation/open_project_from_card.dart';
import 'package:vestie/core/constants/app_dimens.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/common/app_destructive_notice_bar.dart';
import 'package:vestie/core/widgets/common/app_outline_neutral_button.dart';
import 'package:vestie/core/widgets/common/failure_icon.dart';
import 'package:vestie/core/widgets/common/flow_screen_footer.dart';
import 'package:vestie/core/widgets/text/app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProjectCancelledScreen extends StatelessWidget {
  final ProjectCancelledRouteArgs args;

  const ProjectCancelledScreen({super.key, required this.args});

  String get _formattedTotalRefunded {
    final formatter = NumberFormat('#,##0.00', 'en_US');
    return formatter.format(args.totalRefunded);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SafeArea(
              bottom: false,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const FailureIcon(),
                          SizedBox(height: 24.h),
                          AppText(
                            AppStrings.projectCancelledTitle,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontSize: 24.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.grey1100,
                            ),
                          ),
                          SizedBox(height: 12.h),
                          ..._buildDescription(theme),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          FlowScreenFooter(
            child: AppOutlineNeutralButton(
              label: AppStrings.btnBackToHome,
              onPressed: () =>
                  popProjectDetailNavigation(context, refreshHomeOnPop: true),
              borderRadius: AppRadius.r8,
              borderColor: AppColors.backToHomeButtonBorder,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildDescription(ThemeData theme) {
    final bodyStyle = theme.textTheme.bodyLarge?.copyWith(
      fontSize: 16.sp,
      height: 1.5,
      color: AppColors.grey800,
      fontWeight: FontWeight.w400,
    );

    if (!args.hasRefundSummary) {
      return [
        AppText(
          AppStrings.projectCancelledDescription(args.projectName),
          textAlign: TextAlign.center,
          style: bodyStyle,
        ),
        SizedBox(height: 20.h),
        const AppDestructiveNoticeBar(
          text: AppStrings.defaultedNoRefundShort,
        ),
      ];
    }

    final children = <Widget>[
      AppText(
        AppStrings.projectCancelledIntro(args.projectName),
        textAlign: TextAlign.center,
        style: bodyStyle,
      ),
    ];

    if (args.refundedMemberCount > 0 || args.totalRefunded > 0) {
      children
        ..add(SizedBox(height: 12.h))
        ..add(
          AppText(
            AppStrings.projectCancelledMembersRefundedLine(
              args.refundedMemberCount,
              _formattedTotalRefunded,
            ),
            textAlign: TextAlign.center,
            style: bodyStyle,
          ),
        );
    }

    if (args.defaultedMemberCount > 0) {
      children
        ..add(SizedBox(height: 20.h))
        ..add(
          AppDestructiveNoticeBar(
            text: AppStrings.projectCancelledDefaultedMembersLine(
              args.defaultedMemberCount,
            ),
          ),
        );
    }

    return children;
  }
}
