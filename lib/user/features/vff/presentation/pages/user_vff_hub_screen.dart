import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/user_vff_hub_cubit.dart';
import '../models/user_vff_hub_ui_model.dart';
import '../widgets/hub/user_vff_hub_shell.dart';

/// **Flow: Home → VFF heart → hub** — “My VFFs” + “Requests” tabbed overview.
final class UserVffHubScreen extends StatelessWidget {
  /// Flip to `false` to preview the real empty hub from the route/API.
  static const bool previewDemoCards = true;

  final UserVffHubUiModel hub;

  const UserVffHubScreen({super.key, required this.hub});

  UserVffHubUiModel get _effectiveHub =>
      previewDemoCards ? UserVffHubUiModel.demoFilled() : hub;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => UserVffHubCubit(_effectiveHub),
      child: const UserVffHubShell(),
    );
  }
}
