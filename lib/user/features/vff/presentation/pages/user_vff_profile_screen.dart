import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/common/app_back_button.dart';
import 'package:vestie/core/widgets/common/post_auth_gradient_background.dart';
import 'package:vestie/core/widgets/common/post_auth_header.dart';
import '../cubit/user_vff_profile_footer_cubit.dart';
import '../models/user_vff_profile_ui_model.dart';
import '../widgets/profile/user_vff_profile_sheet_stack.dart';

/// **Flow: Hub row / invite → Peer profile.** Following → remove confirmation.
final class UserVffProfileScreen extends StatelessWidget {
  final UserVffProfileUiModel profile;

  const UserVffProfileScreen({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => UserVffProfileFooterCubit(profile),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: PostAuthGradientBackground(
          child: Column(
            children: [
              PostAuthHeader(
                title:
                    '${profile.displayName}'
                    '${AppStrings.userVffProfileTitleSuffix}',
                leading: AppBackButton(onPressed: () => context.pop()),
                titleStyle: GoogleFonts.lato(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w900,
                  color: AppColors.grey1100,
                ),
              ),
              Expanded(
                child: UserVffProfileSheetStack(profile: profile),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
