import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:vestie/core/constants/app_assets.dart';
import 'package:vestie/core/constants/app_dimens.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/utils/app_snackbar.dart';
import 'package:vestie/core/widgets/common/app_back_button.dart';
import 'package:vestie/core/widgets/common/app_button.dart';
import 'package:vestie/core/widgets/common/app_action_dialog.dart';
import 'package:vestie/core/widgets/common/app_text_field.dart';
import 'package:vestie/core/widgets/common/post_auth_gradient_background.dart';
import 'package:vestie/core/widgets/common/post_auth_header.dart';
import 'package:vestie/core/widgets/common/app_svg_icon.dart';
import '../cubit/voting_window_cubit.dart';

/// Leader sets closure voting window (days) before starting the success vote.
class VotingWindowScreen extends StatefulWidget {
  final String projectId;

  const VotingWindowScreen({super.key, required this.projectId});

  @override
  State<VotingWindowScreen> createState() => _VotingWindowScreenState();
}

class _VotingWindowScreenState extends State<VotingWindowScreen> {
  late final TextEditingController _daysController;
  late final FocusNode _daysFocus;

  @override
  void initState() {
    super.initState();
    _daysController = TextEditingController();
    _daysFocus = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _daysFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    _daysController.dispose();
    _daysFocus.dispose();
    super.dispose();
  }

  Future<void> _onStartVoting(VotingWindowCubit cubit) async {
    final ok = await cubit.submit();
    if (!mounted || !ok) return;
    context.pop();
    if (context.mounted) context.pop();
    if (context.mounted) {
      AppSnackBar.showSuccess(context, AppStrings.successVoteStartedMessage);
    }
  }

  void _showVotingWindowInfo(BuildContext context) {
    AppActionDialog.show(
      context,
      title: AppStrings.votingWindowTitle,
      description: AppStrings.votingWindowDaysInfo,
      primaryLabel: AppStrings.btnOk,
      showSecondary: false,
      primaryColor: AppColors.green800,
      onPrimary: () => Navigator.of(context).pop(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => VotingWindowCubit(projectId: widget.projectId),
      child: BlocBuilder<VotingWindowCubit, VotingWindowState>(
        builder: (context, state) {
          final cubit = context.read<VotingWindowCubit>();
          final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
          final labelStyle = Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.authLabel,
              );

          return Scaffold(
            resizeToAvoidBottomInset: true,
            backgroundColor: Colors.transparent,
            body: PostAuthGradientBackground(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  PostAuthHeader(
                    title: AppStrings.votingWindowTitle,
                    padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
                    leading: AppBackButton(
                      onPressed: state.loading ? () {} : () => context.pop(),
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 8.h),
                      child: AppTextField(
                        label: AppStrings.labelEnterVotingWindowDays,
                        hint: AppStrings.hintVotingWindowDays,
                        controller: _daysController,
                        focusNode: _daysFocus,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.done,
                        maxLength: VotingWindowCubit.maxDigits,
                        errorText: state.errorText,
                        labelStyle: labelStyle,
                        fillColor: AppColors.searchBarBg,
                        labelTrailing: GestureDetector(
                          onTap: () => _showVotingWindowInfo(context),
                          child: AppSvgIcon(
                            assetPath: AppAssets.iconInformationCircle,
                            size: 20.w,
                            color: AppColors.neutral700,
                          ),
                        ),
                        labelTrailingGap: 6.w,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(
                            VotingWindowCubit.maxDigits,
                          ),
                        ],
                        onChanged: cubit.setDigitsFromField,
                        onSubmitted: (_) {
                          if (state.canSubmit) _onStartVoting(cubit);
                        },
                      ),
                    ),
                  ),
                  SafeArea(
                    top: false,
                    minimum: EdgeInsets.fromLTRB(16.w, 0, 16.w, 24.h),
                    child: Padding(
                      padding: EdgeInsets.only(bottom: bottomInset),
                      child: AppButton(
                        text: AppStrings.btnStartVoting,
                        isLoading: state.loading,
                        useGradient: false,
                        hasShadow: false,
                        color: AppColors.green800,
                        borderRadius: AppRadius.r8,
                        onPressed: state.canSubmit
                            ? () => _onStartVoting(cubit)
                            : null,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
