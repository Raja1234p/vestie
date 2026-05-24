import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vestie/core/di/service_locator.dart';

import '../cubit/user_vff_hub_cubit.dart';
import '../models/user_vff_hub_ui_model.dart';
import '../widgets/hub/user_vff_hub_shell.dart';

/// **Flow: Home → VFF heart → hub** — “My VFFs” + “Requests” tabbed overview.
final class UserVffHubScreen extends StatelessWidget {
  /// Flip to `true` to preview demo cards without API calls.
  static const bool previewDemoCards = false;

  final UserVffHubUiModel? previewHub;

  const UserVffHubScreen({super.key, this.previewHub});

  @override
  Widget build(BuildContext context) {
    final sl = ServiceLocator.instance;
    return BlocProvider(
      create: (_) {
        final cubit = UserVffHubCubit(
          listMyVffsUseCase: sl.listMyVffsUseCase,
          getVffReceivedInboxUseCase: sl.getVffReceivedInboxUseCase,
          acceptVffRequestUseCase: sl.acceptVffRequestUseCase,
          declineVffRequestUseCase: sl.declineVffRequestUseCase,
          acceptVffProjectInviteUseCase: sl.acceptVffProjectInviteUseCase,
          declineVffProjectInviteUseCase: sl.declineVffProjectInviteUseCase,
        );
        if (previewDemoCards) {
          cubit.seedFromDemo(
            previewHub ?? UserVffHubUiModel.demoFilled(),
          );
        } else {
          cubit.load();
        }
        return cubit;
      },
      child: const UserVffHubShell(),
    );
  }
}
