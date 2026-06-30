import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:vestie/app/router/app_routes.dart';
import 'package:vestie/app/router/route_args/project_detail_flow_args.dart';
import 'package:vestie/core/constants/app_dimens.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/common/app_toast.dart';
import 'package:vestie/core/widgets/common/app_button.dart';
import 'package:vestie/core/widgets/common/app_info_tooltip_icon.dart';
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
    if (cubit.state.loading) return;

    FocusManager.instance.primaryFocus?.unfocus();

    final ok = await cubit.submit();
    if (!mounted || !ok) return;

    try {
      await ProjectDetailNavigation.reloadProjectDetailAndWait(
        context,
        projectId: widget.projectId,
      );
    } on TimeoutException {
      // Vote already started — still show success; detail refreshes on next open.
    }
    if (!mounted) return;

    _openVotingStartedSuccess(context);
  }

  void _openVotingStartedSuccess(BuildContext context) {
    context.pushReplacement(
      AppRoutes.leaderVoteStarted,
      extra: VotingStartedSuccessRouteArgs(projectId: widget.projectId),
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
            prev.apiErrorMessage != curr.apiErrorMessage &&
            curr.apiErrorMessage != null &&
            curr.apiErrorMessage!.isNotEmpty,
        listener: (context, state) {
          AppToast.showError(context, state.apiErrorMessage!);
        },
        child: BlocBuilder<VotingWindowCubit, VotingWindowState>(
          builder: (context, state) {
            final cubit = context.read<VotingWindowCubit>();
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
                      onBack: state.loading ? () {} : () => context.pop(),
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
                          readOnly: state.loading,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.done,
                          maxLength: VotingWindowCubit.maxDigits,
                          errorText: state.errorText,
                          labelStyle: labelStyle,
                          fillColor: AppColors.searchBarBg,
                          labelTrailing: IgnorePointer(
                            ignoring: state.loading,
                            child: AppInfoTooltipIcon(
                              title: AppStrings.votingWindowTitle,
                              message: AppStrings.votingWindowTooltipBody,
                              semanticsLabel:
                                  AppStrings.votingWindowTooltipSemantics,
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
                          onSubmitted: (_) =>
                              FocusManager.instance.primaryFocus?.unfocus(),
                        ),
                      ),
                    ),
                    FlowScreenFooter(
                      child: AppButton(
                        text: AppStrings.btnStartVoting,
                        isLoading: state.loading,
                        useGradient: false,
                        hasShadow: false,
                        color: AppColors.green800,
                        borderRadius: AppRadius.r100,
                        onPressed: state.canSubmit
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
