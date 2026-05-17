import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/utils/app_snackbar.dart';
import 'package:vestie/core/widgets/common/app_failure_dialog.dart';
import 'package:vestie/features/project_detail/presentation/navigation/open_project_from_card.dart';
import '../cubit/discover_cubit.dart';
import '../cubit/discover_join_effect.dart';

/// Join button spinner lives on the card; dialogs only for errors / snackbars.
class DiscoverJoinEffectsListener extends StatelessWidget {
  final Widget child;

  const DiscoverJoinEffectsListener({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocListener<DiscoverCubit, DiscoverState>(
      listenWhen: (prev, curr) =>
          curr.joinEffect != null && curr.joinEffect != prev.joinEffect,
      listener: (context, state) {
        final effect = state.joinEffect;
        if (effect == null) return;

        final cubit = context.read<DiscoverCubit>();
        cubit.clearJoinEffect();

        switch (effect) {
          case DiscoverJoinShowError(:final message, :final title):
            AppFailureDialog.show(
              context,
              title: title,
              message: message,
            );
          case DiscoverJoinShowRequestSubmitted():
            AppSnackBar.showSuccess(
              context,
              AppStrings.projectJoinRequestSubmitted,
            );
          case DiscoverJoinOpenDetail(
              :final projectId,
              :final projectName,
              :final isInvestment,
            ):
            openProjectDetailAfterJoinSuccess(
              context,
              projectId: projectId,
              projectName: projectName,
              isInvestment: isInvestment,
            );
        }
      },
      child: child,
    );
  }
}
