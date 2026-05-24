import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:vestie/app/router/route_args/user_vff_flow_args.dart';
import 'package:vestie/core/constants/app_dimens.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/di/service_locator.dart';
import 'package:vestie/core/utils/app_snackbar.dart';
import 'package:vestie/core/widgets/common/app_back_button.dart';
import 'package:vestie/core/widgets/text/app_text.dart';
import '../cubit/user_vff_profile_cubit.dart';
import '../cubit/user_vff_profile_state.dart';
import '../widgets/user_vff_profile_background.dart';
import '../widgets/user_vff_shimmers.dart';
import '../widgets/profile/user_vff_profile_sheet_stack.dart';

/// **Flow: Hub row / invite → Peer profile.** Following → remove confirmation.
final class UserVffProfileScreen extends StatelessWidget {
  final UserVffProfileRouteArgs args;

  const UserVffProfileScreen({super.key, required this.args});

  @override
  Widget build(BuildContext context) {
    final sl = ServiceLocator.instance;
    return BlocProvider(
      create: (_) {
        final cubit = UserVffProfileCubit(
          getConnectedVffProfileUseCase: sl.getConnectedVffProfileUseCase,
          getPublicVffProfileUseCase: sl.getPublicVffProfileUseCase,
          sendVffRequestUseCase: sl.sendVffRequestUseCase,
          removeVffConnectionUseCase: sl.removeVffConnectionUseCase,
          joinFromVffProfileUseCase: sl.joinFromVffProfileUseCase,
        );
        final preview = args.previewProfile;
        if (preview != null) {
          cubit.seedPreview(preview);
        } else {
          cubit.load(
            userId: args.userId,
            loadAsConnected: args.isConnectedProfile,
            projectId: args.projectId,
          );
        }
        return cubit;
      },
      child: BlocConsumer<UserVffProfileCubit, UserVffProfileState>(
        listenWhen: (prev, curr) =>
            prev.errorMessage != curr.errorMessage && curr.errorMessage != null,
        listener: (context, state) {
          final message = state.errorMessage;
          if (message == null || message.isEmpty) return;
          AppSnackBar.showError(context, message);
        },
        builder: (context, state) {
          final cubit = context.read<UserVffProfileCubit>();

          return PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, _) {
              if (didPop) return;
              context.pop(cubit.profilePopResult);
            },
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: UserVffProfileBackground(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Positioned.fill(child: _buildBody(context, state)),
                    SafeArea(
                      bottom: false,
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(
                            AppDimens.p16,
                            AppDimens.v8,
                            AppDimens.p16,
                            0,
                          ),
                          child: AppBackButton(
                            onPressed: () =>
                                context.pop(cubit.profilePopResult),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, UserVffProfileState state) {
    switch (state.loadStatus) {
      case UserVffProfileLoadStatus.initial:
      case UserVffProfileLoadStatus.loading:
        return UserVffProfileShimmer(connectedLayout: args.isConnectedProfile);
      case UserVffProfileLoadStatus.error:
        return Center(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              AppDimens.p18,
              AppDimens.v48,
              AppDimens.p18,
              AppDimens.p18,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppText(
                  state.errorMessage ?? AppStrings.errorGeneric,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16.h),
                TextButton(
                  onPressed: () => context.read<UserVffProfileCubit>().load(
                        userId: args.userId,
                        loadAsConnected: args.isConnectedProfile,
                        projectId: args.projectId,
                      ),
                  child: AppText(AppStrings.btnRetry),
                ),
              ],
            ),
          ),
        );
      case UserVffProfileLoadStatus.loaded:
        final profile = state.profile;
        if (profile == null) {
          return Center(child: AppText(AppStrings.errorGeneric));
        }
        return UserVffProfileSheetStack(profile: profile);
    }
  }
}
