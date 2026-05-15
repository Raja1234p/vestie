import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:vestie/app/router/app_routes.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/common/app_button.dart';
import 'package:vestie/core/widgets/common/app_text_field.dart';
import 'package:vestie/core/widgets/common/post_auth_gradient_background.dart';
import '../../domain/create_project_form.dart';
import '../create_project_entry_mode.dart';
import '../create_project_flow.dart';
import '../cubit/create_project_cubit.dart';
import '../widgets/create_project_header.dart';

/// Vacation / Emergency + Funds borrowing — repayment window (days) & penalty (%).
///
/// Stateful only for controller lifecycle; wizard state stays in [CreateProjectCubit].
class CreateProjectBorrowingSettingsScreen extends StatefulWidget {
  final CreateProjectEntryMode entryMode;

  const CreateProjectBorrowingSettingsScreen({
    super.key,
    this.entryMode = CreateProjectEntryMode.wizard,
  });

  @override
  State<CreateProjectBorrowingSettingsScreen> createState() =>
      _CreateProjectBorrowingSettingsScreenState();
}

class _CreateProjectBorrowingSettingsScreenState
    extends State<CreateProjectBorrowingSettingsScreen> {
  late final TextEditingController _daysCtrl;
  late final TextEditingController _penaltyCtrl;

  @override
  void initState() {
    super.initState();
    final f = context.read<CreateProjectCubit>().state;
    _daysCtrl = TextEditingController(text: f.repaymentWindow);
    _penaltyCtrl = TextEditingController(text: f.penalty);
  }

  @override
  void dispose() {
    _daysCtrl.dispose();
    _penaltyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CreateProjectCubit, CreateProjectForm>(
      builder: (context, form) {
        final cubit = context.read<CreateProjectCubit>();
        if (!form.flowType.usesBorrowingSettings) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!context.mounted) return;
            context.pop();
          });
          return const Scaffold(body: SizedBox.shrink());
        }

        final settingsLabelStyle =
            Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.authLabel,
                );

        return Scaffold(
          backgroundColor: Colors.transparent,
          resizeToAvoidBottomInset: false,
          body: PostAuthGradientBackground(
            child: Column(
              children: [
                CreateProjectHeader(
                  title: AppStrings.createFundsBorrowingTitle,
                  stepBadge: createProjectBorrowingSettingsStepBadge(
                    form,
                    editMode: widget.entryMode.isEditFlow,
                  ),
                  badgeColor: Colors.white,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: EdgeInsets.fromLTRB(
                      20.w,
                      20.h,
                      20.w,
                      16.h + MediaQuery.viewInsetsOf(context).bottom,
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (form.borrowingEnabled) ...[
                            AppTextField(
                              label: AppStrings.labelRepaymentWindowDays,
                              hint: AppStrings.hintRepaymentDays,
                              controller: _daysCtrl,
                              keyboardType: TextInputType.number,
                              textInputAction: TextInputAction.next,
                              maxLength: 3,
                              errorText: form.repaymentWindowError,
                              onChanged: cubit.setRepaymentDays,
                              labelStyle: settingsLabelStyle,
                              fillColor: AppColors.searchBarBg,
                            ),
                            SizedBox(height: 16.h),
                            AppTextField(
                              label: AppStrings.labelBorrowPenaltyPercent,
                              hint: AppStrings.hintBorrowPenalty,
                              controller: _penaltyCtrl,
                              keyboardType: TextInputType.number,
                              textInputAction: TextInputAction.done,
                              maxLength: 3,
                              errorText: form.penaltyError,
                              onChanged: cubit.setPenalty,
                              labelStyle: settingsLabelStyle,
                              fillColor: AppColors.searchBarBg,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 20.h),
                    child: AppButton(
                      text: AppStrings.btnNext,
                      useGradient: false,
                      hasShadow: false,
                      color: AppColors.neutral1200,
                      borderRadius: 10.r,
                      onPressed: () {
                        if (!cubit.validateFundsBorrowing()) return;
                        if (widget.entryMode.isEditFlow) {
                          context.pop();
                          context.pop();
                          return;
                        }
                        context.push(AppRoutes.createProjectReview);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
