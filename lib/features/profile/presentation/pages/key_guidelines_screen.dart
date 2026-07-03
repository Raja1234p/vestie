import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vestie/core/constants/app_dimens.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/widgets/common/app_error_view.dart';
import 'package:vestie/core/widgets/common/flow_screen_footer.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/common/app_purple_dashed_line.dart';
import 'package:vestie/core/widgets/common/post_auth_gradient_background.dart';
import 'package:vestie/features/profile/presentation/cubit/user_guidelines_cubit.dart';
import 'package:vestie/features/profile/presentation/widgets/profile_sub_header.dart';
import 'package:vestie/features/profile/presentation/widgets/user_guideline_section.dart';
import 'package:vestie/features/profile/presentation/widgets/user_guidelines_shimmer.dart';

/// Profile → Vestie User Guidelines (`GET /content/user-guidelines`).
class KeyGuidelinesScreen extends StatelessWidget {
  const KeyGuidelinesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => UserGuidelinesCubit(),
      child: const _KeyGuidelinesBody(),
    );
  }
}

class _KeyGuidelinesBody extends StatelessWidget {
  const _KeyGuidelinesBody();

  String _headerTitle(UserGuidelinesState state) {
    final title = state.page?.pageTitle.trim();
    if (title != null && title.isNotEmpty) return title;
    return AppStrings.menuKeyGuidelines;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserGuidelinesCubit, UserGuidelinesState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          resizeToAvoidBottomInset: false,
          body: PostAuthGradientBackground(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ProfileSubHeader(title: _headerTitle(state)),
                Expanded(child: _buildBody(context, state)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, UserGuidelinesState state) {
    if (state.loading) {
      return const UserGuidelinesListShimmer();
    }

    if (state.loadFailed) {
      return AppErrorView(
        message: state.errorMessage,
        onRetry: () => context.read<UserGuidelinesCubit>().load(),
      );
    }

    final guidelines = state.page?.guidelines ?? const [];
    if (guidelines.isEmpty) {
      return AppErrorView(
        message: AppStrings.errorGeneric,
        onRetry: () => context.read<UserGuidelinesCubit>().load(),
      );
    }

    return ListView.separated(
      padding: FlowScreenFooterInsets.listPadding(
        context,
        top: AppDimens.v4,
      ),
      itemCount: guidelines.length,
      separatorBuilder: (context, index) => const AppPurpleDashedLine(
        color: AppColors.purple300,
        height: 1,
      ),
      itemBuilder: (context, index) =>
          UserGuidelineSection(item: guidelines[index]),
    );
  }
}
