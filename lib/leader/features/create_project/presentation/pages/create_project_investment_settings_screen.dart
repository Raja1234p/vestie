import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:vestie/app/router/app_routes.dart';
import 'package:vestie/core/constants/app_assets.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/common/app_svg_icon.dart';
import 'package:vestie/core/widgets/common/post_auth_gradient_background.dart';
import '../../domain/create_project_form.dart';
import '../create_project_flow.dart';
import '../cubit/create_project_cubit.dart';
import '../widgets/create_project_header.dart';
import 'create_project_form_widgets.dart';

/// Investment category — optional ROI only (no borrowing). Matches Figma Project Settings 2/3.
class CreateProjectInvestmentSettingsScreen extends StatefulWidget {
  final bool isEditMode;

  const CreateProjectInvestmentSettingsScreen({
    super.key,
    this.isEditMode = false,
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

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: PostAuthGradientBackground(
            child: Column(
              children: [
                CreateProjectHeader(
                  title: AppStrings.createSavingSettingsTitle,
                  stepBadge: createProjectInvestmentSettingsStepBadge(
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
                        CPFieldLabel(AppStrings.labelRoiOptional),
                        CPTextField(
                          controller: _roiCtrl,
                          hint: AppStrings.hintAnnualInterest,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.done,
                          errorText: form.roiError,
                          onChanged: cubit.setRoi,
                          suffixIcon: Padding(
                            padding: EdgeInsets.only(right: 8.w),
                            child: AppSvgIcon(
                              assetPath: AppAssets.iconInfo,
                              size: 18.w,
                              color: AppColors.textBody,
                            ),
                          ),
                        ),
                        SizedBox(height: 10.h),
                        Text(
                          AppStrings.roiOptionalHelper,
                          style: GoogleFonts.lato(
                            fontSize: 13.sp,
                            height: 1.45,
                            color: Colors.black.withValues(alpha: 0.55),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 20.h),
                    child: CPNextButton(
                      label: widget.isEditMode
                          ? AppStrings.btnSaveChanges
                          : AppStrings.btnNext,
                      onPressed: () {
                        if (!cubit.validateInvestmentOptionalRoi()) return;
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
