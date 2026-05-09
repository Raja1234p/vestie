import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:vestie/app/router/app_routes.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/widgets/common/app_tick_switch.dart';
import 'package:vestie/core/widgets/common/post_auth_gradient_background.dart';
import '../../domain/create_project_form.dart';
import '../create_project_flow.dart';
import '../cubit/create_project_cubit.dart';
import '../widgets/create_project_header.dart';
import 'create_project_form_widgets.dart';

/// Funds-borrowing flow — toggle, annual %, repayment in months (`AppStrings` aligned to design).
///
/// Stateful only for controller lifecycle; wizard state stays in [CreateProjectCubit].
class CreateProjectBorrowingSettingsScreen extends StatefulWidget {
  final bool isEditMode;

  const CreateProjectBorrowingSettingsScreen({
    super.key,
    this.isEditMode = false,
  });

  @override
  State<CreateProjectBorrowingSettingsScreen> createState() =>
      _CreateProjectBorrowingSettingsScreenState();
}

class _CreateProjectBorrowingSettingsScreenState
    extends State<CreateProjectBorrowingSettingsScreen> {
  late final TextEditingController _roiCtrl;
  late final TextEditingController _monthsCtrl;

  @override
  void initState() {
    super.initState();
    final f = context.read<CreateProjectCubit>().state;
    _roiCtrl = TextEditingController(text: f.roi);
    _monthsCtrl = TextEditingController(text: f.repaymentWindow);
  }

  @override
  void dispose() {
    _roiCtrl.dispose();
    _monthsCtrl.dispose();
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

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: PostAuthGradientBackground(
            child: Column(
              children: [
                CreateProjectHeader(
                  title: AppStrings.createFundsBorrowingTitle,
                  stepBadge: createProjectBorrowingSettingsStepBadge(
                    form,
                    editMode: widget.isEditMode,
                  ),
                  badgeColor: Colors.white,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 16.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                AppStrings.labelEnableBorrowProject,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                            ),
                            AppTickSwitch(
                              value: form.borrowingEnabled,
                              onChanged: cubit.toggleBorrowing,
                            ),
                          ],
                        ),
                        if (form.borrowingEnabled) ...[
                          SizedBox(height: 20.h),
                          const CPDashedDivider(),
                          SizedBox(height: 20.h),
                          CPFieldLabel(AppStrings.labelAnnualInterest),
                          CPTextField(
                            controller: _roiCtrl,
                            hint: AppStrings.hintAnnualInterest,
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.next,
                            errorText: form.roiError,
                            onChanged: cubit.setRoi,
                          ),
                          SizedBox(height: 16.h),
                          CPFieldLabel(AppStrings.labelRepaymentMonths),
                          CPTextField(
                            controller: _monthsCtrl,
                            hint: AppStrings.hintRepaymentMonths,
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.done,
                            errorText: form.repaymentWindowError,
                            onChanged: cubit.setRepaymentMonths,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 14.h),
                    child: CPNextButton(
                      label: widget.isEditMode
                          ? AppStrings.btnSaveChanges
                          : AppStrings.btnNext,
                      onPressed: () {
                        if (!cubit.validateFundsBorrowing()) return;
                        if (widget.isEditMode) {
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
