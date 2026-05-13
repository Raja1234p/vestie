import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import 'package:vestie/app/router/app_routes.dart';
import 'package:vestie/core/constants/app_assets.dart';
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

/// Investment category — optional ROI only (no borrowing). Matches Figma Project Settings 2/3.
class CreateProjectInvestmentSettingsScreen extends StatefulWidget {
  final CreateProjectEntryMode entryMode;

  const CreateProjectInvestmentSettingsScreen({
    super.key,
    this.entryMode = CreateProjectEntryMode.wizard,
  });

  @override
  State<CreateProjectInvestmentSettingsScreen> createState() =>
      _CreateProjectInvestmentSettingsScreenState();
}

class _CreateProjectInvestmentSettingsScreenState
    extends State<CreateProjectInvestmentSettingsScreen> {
  late final TextEditingController _roiCtrl;

  @override
  void initState() {
    super.initState();
    final f = context.read<CreateProjectCubit>().state;
    _roiCtrl = TextEditingController(text: f.roi);
  }

  @override
  void dispose() {
    _roiCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CreateProjectCubit, CreateProjectForm>(
      builder: (context, form) {
        final cubit = context.read<CreateProjectCubit>();
        if (!form.flowType.usesInvestmentRoiOnlySettings) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!context.mounted) return;
            context.pop();
          });
          return const Scaffold(body: SizedBox.shrink());
        }

        final roiLabelStyle =
            Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.authLabel, // #443F63 — same as Project Details labels
                );
        final roiHelperStyle =
            Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.grey800, // #5E5783
                );
        final roiHintStyle =
            Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF141414).withValues(alpha: 0.5),
                );

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: PostAuthGradientBackground(
            child: Column(
              children: [
                CreateProjectHeader(
                  title: AppStrings.createSavingSettingsTitle,
                  stepBadge: createProjectInvestmentSettingsStepBadge(
                    form,
                    editMode: widget.entryMode.isEditFlow,
                  ),
                  badgeColor: Colors.white,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 16.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppTextField(
                          label: AppStrings.labelRoiOptional,
                          hint: AppStrings.hintAnnualInterest,
                          controller: _roiCtrl,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.done,
                          maxLength: 3,
                          errorText: form.roiError,
                          onChanged: cubit.setRoi,
                          labelStyle: roiLabelStyle,
                          fillColor: AppColors.purple100, // #F5F0FE
                          hintStyle: roiHintStyle,
                          suffixIconConstraints: BoxConstraints(
                            minWidth: 0,
                            minHeight: 0,
                            maxWidth: 8.w + 20.w + 8.w,
                            maxHeight: 28.h,
                          ),
                          suffixIcon: Padding(
                            padding: EdgeInsets.only(right: 8.w),
                            child: SizedBox(
                              width: 20.w,
                              height: 20.h,
                              child: SvgPicture.asset(
                                AppAssets.iconInformationCircle,
                                fit: BoxFit.contain,
                                colorFilter: ColorFilter.mode(
                                  AppColors.inputFieldIcon,
                                  BlendMode.srcIn,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          AppStrings.roiOptionalHelper,
                          style: roiHelperStyle,
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.viewInsetsOf(context).bottom,
                  ),
                  child: SafeArea(
                    top: false,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: AppButton(
                        text: AppStrings.btnNext,
                        useGradient: false,
                        hasShadow: false,
                        color: AppColors.neutral1200,
                        borderRadius: 10.r,
                        onPressed: () {
                          if (!cubit.validateInvestmentOptionalRoi()) return;
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
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
