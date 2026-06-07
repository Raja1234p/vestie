import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart' show DateFormat;

import 'package:vestie/app/router/app_routes.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/utils/storyboard/storyboard_desktop_loader.dart';
import 'package:vestie/core/widgets/common/post_auth_gradient_background.dart';
import 'package:vestie/core/widgets/member_project_flow/member_project_form_widgets.dart';
import 'package:vestie/core/widgets/member_project_flow/member_project_header.dart';

import '../models/create_project_fund_draft.dart';

/// Shared fields for Vacation & Emergency **setup** (image-aligned storyboard screens).
class CreateProjectFundMemberSetupScreen extends StatefulWidget {
  final CreateProjectFundKind kind;

  const CreateProjectFundMemberSetupScreen({super.key, required this.kind});

  @override
  State<CreateProjectFundMemberSetupScreen> createState() =>
      _CreateProjectFundMemberSetupScreenState();
}

class _CreateProjectFundMemberSetupScreenState
    extends State<CreateProjectFundMemberSetupScreen> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _goalCtrl;
  late final TextEditingController _descCtrl;

  late DateTime _start;
  late DateTime _end;

  String? _nameError;
  String? _goalError;
  String? _endError;

  String get _fundHeaderTitle => switch (widget.kind) {
    CreateProjectFundKind.vacation => AppStrings.createProjectVacationFundTitle,
    CreateProjectFundKind.emergency =>
      AppStrings.createProjectEmergencyFundTitle,
  };

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
    _goalCtrl = TextEditingController(
      text: switch (widget.kind) {
        CreateProjectFundKind.vacation => '10750',
        CreateProjectFundKind.emergency => '1450',
      },
    );
    _descCtrl = TextEditingController();
    _start = DateTime.now();
    _end = DateTime.now().add(const Duration(days: 180));
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _goalCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isStart}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _start : _end,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      builder: (c, child) => Theme(
        data: Theme.of(
          c,
        ).copyWith(colorScheme: ColorScheme.light(primary: AppColors.primary)),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _start = picked;
        } else {
          _end = picked;
        }
      });
    }
  }

  bool _validate() {
    final nameOk = _nameCtrl.text.trim().isNotEmpty;
    final parsedGoal = double.tryParse(
      _goalCtrl.text.replaceAll(',', '').trim(),
    );
    final goalOk = parsedGoal != null && parsedGoal > 0;
    final datesOk = !_end.isBefore(_start.add(const Duration(days: 1)));

    setState(() {
      _nameError = nameOk ? null : AppStrings.validationProjectNameRequired;
      _goalError = goalOk ? null : AppStrings.validationGoalUsdInvalid;
      _endError = datesOk ? null : AppStrings.validationEndAfterStartRequired;
    });
    return nameOk && goalOk && datesOk;
  }

  void _submit() {
    if (!_validate()) return;
    final draft = CreateProjectFundDraft(
      kind: widget.kind,
      projectName: _nameCtrl.text.trim(),
      goalAmountUsd: double.parse(_goalCtrl.text.replaceAll(',', '').trim()),
      startDate: _start,
      endDate: _end,
      description: _descCtrl.text.trim(),
    );
    context.push(AppRoutes.createProjectFundSummary, extra: draft);
  }

  @override
  Widget build(BuildContext context) {
    final hero = loadStoryboardDesktopImage(widget.kind.suggestedHeroFilename);
    final startLabel = _usdDate(_start);
    final endLabel = _usdDate(_end);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: PostAuthGradientBackground(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MemberFundFlowHeader(title: _fundHeaderTitle),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 24.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (hero != null) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16.r),
                        child: AspectRatio(aspectRatio: 16 / 9, child: hero),
                      ),
                      SizedBox(height: 14.h),
                    ],
                    MemberFundFieldLabel(AppStrings.labelProjectName),
                    MemberFundTextField(
                      controller: _nameCtrl,
                      hint: AppStrings.hintVacationEmergencyProjectName,
                      textInputAction: TextInputAction.next,
                      errorText: _nameError,
                      onChanged: (_) {},
                    ),
                    SizedBox(height: 16.h),
                    MemberFundFieldLabel(AppStrings.labelGoalAmountUsd),
                    MemberFundTextField(
                      controller: _goalCtrl,
                      hint: AppStrings.hintGoalAmountUsd,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      textInputAction: TextInputAction.next,
                      errorText: _goalError,
                      onChanged: (_) {},
                      suffixIcon: Padding(
                        padding: EdgeInsets.only(right: 10.w),
                        child: Align(
                          widthFactor: 1,
                          child: Text(
                            'USD',
                            style: GoogleFonts.lato(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textBody,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    MemberFundFieldLabel(AppStrings.labelStartDate),
                    _DateTile(
                      label: startLabel,
                      errorText: null,
                      onTap: () => _pickDate(isStart: true),
                    ),
                    SizedBox(height: 14.h),
                    MemberFundFieldLabel(AppStrings.labelEndDate),
                    _DateTile(
                      label: endLabel,
                      errorText: _endError,
                      onTap: () => _pickDate(isStart: false),
                    ),
                    SizedBox(height: 16.h),
                    MemberFundFieldLabel(AppStrings.labelProjectDesc),
                    MemberFundTextField(
                      controller: _descCtrl,
                      hint: AppStrings.hintProjectDesc,
                      maxLines: 4,
                      textInputAction: TextInputAction.done,
                      errorText: null,
                      onChanged: (_) {},
                    ),
                  ],
                ),
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 14.h),
                child: MemberFundPrimaryButton(
                  label: AppStrings.btnContinue,
                  onPressed: _submit,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _usdDate(DateTime d) =>
      DateFormat('d MMMM y', 'en_US').format(d);
}

class _DateTile extends StatelessWidget {
  final String label;
  final String? errorText;
  final VoidCallback onTap;

  const _DateTile({
    required this.label,
    required this.errorText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null && errorText!.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12.r),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
              decoration: BoxDecoration(
                color: AppColors.searchBarBg,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: hasError ? AppColors.error : AppColors.cardBorder,
                ),
              ),
              child: Text(
                label,
                style: GoogleFonts.lato(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
        ),
        if (hasError)
          Padding(
            padding: EdgeInsets.only(top: 4.h, left: 4.w),
            child: Text(
              errorText!,
              style: GoogleFonts.lato(fontSize: 11.sp, color: AppColors.error),
            ),
          ),
      ],
    );
  }
}
