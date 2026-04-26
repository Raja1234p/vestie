import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/common/app_tick_switch.dart';
import '../../../../core/widgets/common/post_auth_gradient_background.dart';
import '../../domain/create_project_form.dart';
import '../cubit/create_project_cubit.dart';
import '../widgets/create_project_header.dart';
import 'form_helpers.dart';

/// Step 2/3 – ROI and borrowing settings.
///
/// Uses [StatefulWidget] solely to manage [TextEditingController] lifecycle.
/// All reactive state (form data, validation errors) lives in [CreateProjectCubit].
/// Zero [setState] calls.
class ProjectBorrowingScreen extends StatefulWidget {
  /// True when navigated from the Review screen's "Edit" button.
  final bool isEditMode;
  const ProjectBorrowingScreen({super.key, this.isEditMode = false});

  @override
  State<ProjectBorrowingScreen> createState() => _ProjectBorrowingScreenState();
}

class _ProjectBorrowingScreenState extends State<ProjectBorrowingScreen> {
  late final TextEditingController _roiCtrl;
  late final TextEditingController _limitCtrl;
  late final TextEditingController _windowCtrl;
  late final TextEditingController _penaltyCtrl;

  @override
  void initState() {
    super.initState();
    final f = context.read<CreateProjectCubit>().state;
    _roiCtrl     = TextEditingController(text: f.roi);
    _limitCtrl   = TextEditingController(text: f.borrowLimit);
    _windowCtrl  = TextEditingController(text: f.repaymentWindow);
    _penaltyCtrl = TextEditingController(text: f.penalty);
  }

  @override
  void dispose() {
    _roiCtrl.dispose();
    _limitCtrl.dispose();
    _windowCtrl.dispose();
    _penaltyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CreateProjectCubit, CreateProjectForm>(
      builder: (context, form) {
        final cubit = context.read<CreateProjectCubit>();
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: PostAuthGradientBackground(
            child: Column(
              children: [
              CreateProjectHeader(
                title: AppStrings.createBorrowingTitle,
                stepBadge: widget.isEditMode ? null : '2/3',
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 16.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CPFieldLabel(AppStrings.labelRoi),
                      CPTextField(
                        controller: _roiCtrl,
                        hint: AppStrings.roiHint,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.done,
                        onChanged: cubit.setRoi,
                        suffixIcon: Padding(
                          padding: EdgeInsets.only(right: 12.w),
                          child: Icon(Icons.info_outline_rounded,
                              size: 20.w, color: AppColors.primary),
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Text(AppStrings.roiSubtitle,
                          style: GoogleFonts.lato(
                              fontSize: 12.sp,
                              color: AppColors.textBody,
                              height: 1.5)),
                      SizedBox(height: 20.h),
                      const CPDashedDivider(),
                      SizedBox(height: 20.h),

                      // Enable borrowing toggle
                      Row(
                        children: [
                          Expanded(
                            child: Text(AppStrings.labelEnableBorrowing,
                                style: GoogleFonts.lato(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textPrimary)),
                          ),
                          AppTickSwitch(
                            value: form.borrowingEnabled,
                            onChanged: cubit.toggleBorrowing,
                          ),
                        ],
                      ),

                      if (form.borrowingEnabled) ...[
                        SizedBox(height: 16.h),
                        CPFieldLabel(AppStrings.labelBorrowLimit),
                        CPTextField(
                          controller: _limitCtrl,
                          hint: AppStrings.hintBorrowLimit,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.next,
                          errorText: form.borrowLimitError,
                          onChanged: cubit.setBorrowLimit,
                        ),
                        SizedBox(height: 16.h),
                        CPFieldLabel(AppStrings.labelRepaymentWindow),
                        CPTextField(
                          controller: _windowCtrl,
                          hint: AppStrings.hintRepaymentWindow,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.next,
                          errorText: form.repaymentWindowError,
                          onChanged: cubit.setRepaymentWindow,
                        ),
                        SizedBox(height: 16.h),
                        CPFieldLabel(AppStrings.labelPenalty),
                        CPTextField(
                          controller: _penaltyCtrl,
                          hint: AppStrings.hintPenalty,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.done,
                          errorText: form.penaltyError,
                          onChanged: cubit.setPenalty,
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
                      if (!cubit.validateBorrowing()) return;
                      if (widget.isEditMode) {
                        context.pop(); // close Borrowing (edit)
                        context.pop(); // close Details (edit) -> reveal Review
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
