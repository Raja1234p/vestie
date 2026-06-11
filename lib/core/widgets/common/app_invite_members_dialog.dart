import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/di/service_locator.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/user/features/vff/presentation/cubit/invite_members_sheet_cubit.dart';
import 'app_invite_members_bottom_sheet.dart';

/// Invite members — modal bottom sheet (VFF grid + share row).
class AppInviteMembersDialog {
  AppInviteMembersDialog._();

  static Future<void> show(
    BuildContext context, {
    required String projectId,
    required String projectName,
    Set<String> excludeUserIds = const {},
    String inviteLink = AppStrings.inviteLinkSample,
  }) {
    final sl = ServiceLocator.instance;

    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: false,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final viewPadding = MediaQuery.viewPaddingOf(sheetContext);
        return BlocProvider(
          create: (_) => InviteMembersSheetCubit(
            listMyVffsUseCase: sl.listMyVffsUseCase,
            inviteVffsToProjectUseCase: sl.inviteVffsToProjectUseCase,
          )..load(excludeUserIds: excludeUserIds),
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              12.w,
              0,
              12.w,
              viewPadding.bottom,
            ),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 24,
                    offset: const Offset(0, -6),
                    color: Colors.black.withValues(alpha: 0.08),
                  ),
                ],
              ),
              child: AppInviteMembersBottomSheet(
                projectId: projectId,
                projectName: projectName,
                inviteLink: inviteLink,
              ),
            ),
          ),
        );
      },
    );
  }
}
