import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:vestie/app/router/route_args/project_detail_flow_args.dart';
import 'package:vestie/core/constants/app_dimens.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/di/service_locator.dart';
import 'package:vestie/core/error/failure_mapper.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/common/app_button.dart';
import 'package:vestie/core/widgets/common/app_error_view.dart';
import 'package:vestie/core/widgets/common/app_loader.dart';
import 'package:vestie/core/widgets/common/app_toast.dart';
import 'package:vestie/core/widgets/common/flow_screen_footer.dart';
import 'package:vestie/core/widgets/common/post_auth_flow_sub_header.dart';
import 'package:vestie/core/widgets/common/post_auth_gradient_background.dart';
import 'package:vestie/core/widgets/text/app_text.dart';
import 'package:vestie/features/project_detail/presentation/cubit/investment_distribution_cubit.dart';
import 'package:vestie/features/project_detail/presentation/cubit/investment_distribution_state.dart';
import 'package:vestie/features/project_detail/presentation/models/investment_distribution_ui_data.dart';
import 'package:vestie/features/project_detail/presentation/navigation/project_detail_navigation.dart';
import 'package:vestie/features/project_detail/presentation/widgets/investment_distribution/investment_distribution_breakdown_table.dart';

/// Leader distribution breakdown — summary, table, confirm (Figma).
class InvestmentDistributionScreen extends StatelessWidget {
  final InvestmentDistributionRouteArgs args;

  const InvestmentDistributionScreen({super.key, required this.args});

  bool get _usesApiLoad => !args.isPreview && args.projectId.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    if (!_usesApiLoad) {
      final data = args.data;
      if (data == null) {
        return const Scaffold(body: Center(child: AppLoader()));
      }
      return _InvestmentDistributionShell(
        data: data,
        isSubmitting: false,
        onConfirm: () => ProjectDetailNavigation.openFundsDistributedSuccess(
          context,
          distributionData: data,
        ),
      );
    }

    return BlocProvider(
      create: (_) =>
          ServiceLocator.instance.createInvestmentDistributionCubit(args)
            ..load(),
      child: _InvestmentDistributionProductionBody(args: args),
    );
  }
}

class _InvestmentDistributionProductionBody extends StatelessWidget {
  final InvestmentDistributionRouteArgs args;

  const _InvestmentDistributionProductionBody({required this.args});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<InvestmentDistributionCubit, InvestmentDistributionState>(
      listenWhen: (prev, curr) => prev.submitFailure != curr.submitFailure,
      listener: (context, state) {
        final failure = state.submitFailure;
        if (failure != null) {
          AppToast.showError(context, FailureMapper.userMessage(failure));
        }
      },
      builder: (context, state) {
        if (state.isLoading) {
          return const Scaffold(body: Center(child: AppLoader()));
        }

        if (state.loadFailed) {
          return Scaffold(
            body: AppErrorView(
              message: state.loadErrorMessage ?? AppStrings.errorGeneric,
              onRetry: () => context.read<InvestmentDistributionCubit>().load(),
            ),
          );
        }

        final data = state.data;
        if (data == null) {
          return Scaffold(
            body: AppErrorView(
              message: AppStrings.errorGeneric,
              onRetry: () => context.read<InvestmentDistributionCubit>().load(),
            ),
          );
        }

        return _InvestmentDistributionShell(
          data: data,
          isSubmitting: state.isSubmitting,
          onConfirm: () async {
            final result = await context
                .read<InvestmentDistributionCubit>()
                .confirmDistribute();
            if (!context.mounted || result == null) return;
            ProjectDetailNavigation.openFundsDistributedSuccess(
              context,
              distributionData: data,
            );
          },
        );
      },
    );
  }
}

class _InvestmentDistributionShell extends StatelessWidget {
  final InvestmentDistributionUiData data;
  final bool isSubmitting;
  final VoidCallback onConfirm;

  const _InvestmentDistributionShell({
    required this.data,
    required this.isSubmitting,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      resizeToAvoidBottomInset: false,
      body: PostAuthGradientBackground(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PostAuthFlowSubHeader(
              title: AppStrings.investmentDistributionScreenTitle,
              onBack: () => context.pop(),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: AppDimens.postAuthFlowScrollPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      AppStrings.investmentDistributingLabel,
                      color: AppColors.neutral1200,
                      style: GoogleFonts.lato(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    AppText(
                      '\$${data.formattedDistributeAmount}',
                      color: AppColors.neutral1200,
                      style: GoogleFonts.lato(
                        fontSize: 36.sp,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    AppText(
                      AppStrings.investmentDistributingToMembers(
                        data.memberCount,
                      ),
                      style: GoogleFonts.lato(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.grey800,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        horizontal: 14.w,
                        vertical: 10.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.blue100,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: AppText(
                        AppStrings.investmentRemainingToDistribute(
                          '\$${data.formattedRemaining}',
                        ),
                        style: GoogleFonts.lato(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.blue900,
                        ),
                      ),
                    ),
                    SizedBox(height: 20.h),
                    AppText(
                      AppStrings.labelBreakdown,
                      style: GoogleFonts.lato(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.grey1100,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    InvestmentDistributionBreakdownTable(members: data.members),
                    SizedBox(height: 16.h),
                  ],
                ),
              ),
            ),
            FlowScreenFooter(
              child: AppButton(
                text: AppStrings.btnConfirmAndDistribute,
                isLoading: isSubmitting,
                onPressed: isSubmitting ? null : onConfirm,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
