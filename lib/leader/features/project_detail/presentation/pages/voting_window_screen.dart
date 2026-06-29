import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:vestie/app/router/app_routes.dart';
import 'package:vestie/core/constants/app_assets.dart';
import 'package:vestie/core/constants/app_dimens.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/common/app_toast.dart';
import 'package:vestie/core/widgets/common/app_action_dialog.dart';
import 'package:vestie/core/widgets/common/app_button.dart';
import 'package:vestie/core/widgets/common/app_svg_icon.dart';
import 'package:vestie/core/widgets/common/app_text_field.dart';
import 'package:vestie/core/widgets/common/flow_screen_footer.dart';
import 'package:vestie/core/widgets/common/post_auth_gradient_background.dart';
import 'package:vestie/core/widgets/common/post_auth_flow_sub_header.dart';
import 'package:vestie/features/project_detail/domain/entities/leader_voting_flow_kind.dart';
import 'package:vestie/features/project_detail/presentation/navigation/project_detail_navigation.dart';
import 'package:vestie/user/features/home/domain/entities/project.dart';
import '../cubit/voting_window_cubit.dart';

/// Leader sets voting window (days) before starting a member vote.
class VotingWindowScreen extends StatefulWidget {
  final String projectId;
  final LeaderVotingFlowKind flowKind;
  final ProjectCategory projectCategory;

  const VotingWindowScreen({
    super.key,
    required this.projectId,
    this.flowKind = LeaderVotingFlowKind.markProjectSuccessful,
    required this.projectCategory,
  });

  @override
  State<VotingWindowScreen> createState() => _VotingWindowScreenState();
}

class _VotingWindowScreenState extends State<VotingWindowScreen> {
  late final TextEditingController _daysController;
  late final FocusNode _daysFocus;
  bool _isSubmitting = false;

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
    if (_isSubmitting || cubit.state.loading) return;

    _daysFocus.unfocus();
    setState(() => _isSubmitting = true);

    final ok = await cubit.submit();
    if (!mounted) return;
    if (!ok) {
      setState(() => _isSubmitting = false);
      return;
    }

    await ProjectDetailNavigation.reloadProjectDetailAndWait(
      context,
      projectId: widget.projectId,
    );
    if (!mounted) return;

    if (widget.flowKind == LeaderVotingFlowKind.stopContributions) {
      context.pop();
      if (!context.mounted) return;
      context.pop();
      if (!context.mounted) return;
      context.push(AppRoutes.leaderVoteStarted);
      return;
    }

    context.pop();
    if (!context.mounted) return;
    context.pop();
    if (context.mounted) {
      AppToast.showSuccess(context, AppStrings.successVoteStartedMessage);
    }
  }

  void _showVotingWindowInfo(BuildContext context) {
    final description =
        widget.flowKind == LeaderVotingFlowKind.stopContributions
        ? AppStrings.stopContributionsVotingWindowInfo
        : AppStrings.votingWindowDaysInfo;

    AppActionDialog.show(
      context,
      title: AppStrings.votingWindowTitle,
      description: description,
      primaryLabel: AppStrings.btnOk,
      showSecondary: false,
      primaryColor: AppColors.green800,
      onPrimary: () => Navigator.of(context).pop(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => VotingWindowCubit(
        projectId: widget.projectId,
        flowKind: widget.flowKind,
        projectCategory: widget.projectCategory,
      ),
      child: BlocListener<VotingWindowCubit, VotingWindowState>(
        listenWhen: (prev, curr) =>
            prev.apiErrorMessage != curr.apiErrorMessage,
        listener: (context, state) {
          final msg = state.apiErrorMessage;
          if (msg != null && msg.isNotEmpty) {
            AppToast.showError(context, msg);
          }
        },
        child: BlocBuilder<VotingWindowCubit, VotingWindowState>(
          builder: (context, state) {
            final cubit = context.read<VotingWindowCubit>();
            final isBusy = _isSubmitting || state.loading;
            final labelStyle = Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.authLabel,
            );

            return Scaffold(
              resizeToAvoidBottomInset: false,
              backgroundColor: Colors.transparent,
              body: PostAuthGradientBackground(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    PostAuthFlowSubHeader(
                      title: AppStrings.votingWindowTitle,
                      onBack: isBusy ? () {} : () => context.pop(),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        padding: AppDimens.postAuthFlowScrollPaddingWithKeyboard(
                          context,
                        ),
                        child: AppTextField(
                          label: AppStrings.labelEnterVotingWindowDays,
                          hint: AppStrings.hintVotingWindowDays,
                          controller: _daysController,
                          focusNode: _daysFocus,
                          readOnly: isBusy,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.done,
                          maxLength: VotingWindowCubit.maxDigits,
                          errorText: state.errorText,
                          labelStyle: labelStyle,
                          fillColor: AppColors.searchBarBg,
                          labelTrailing: GestureDetector(
                            onTap: isBusy
                                ? null
                                : () => _showVotingWindowInfo(context),
                            child: AppSvgIcon(
                              assetPath: AppAssets.iconInfoCircle,
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
                          onSubmitted: (_) => _daysFocus.unfocus(),
                        ),
                      ),
                    ),
                    FlowScreenFooter(
                      child: AppButton(
                        text: AppStrings.btnStartVoting,
                        isLoading: isBusy,
                        useGradient: false,
                        hasShadow: false,
                        color: AppColors.green800,
                        borderRadius: AppRadius.r100,
                        onPressed: state.digits.isNotEmpty
                            ? () => _onStartVoting(cubit)
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
