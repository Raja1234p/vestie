import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:vestie/app/router/app_routes.dart';
import 'package:vestie/app/router/route_args/user_vff_flow_args.dart';
import 'package:vestie/core/constants/app_dimens.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/common/app_back_button.dart';
import 'package:vestie/core/widgets/common/post_auth_gradient_background.dart';
import 'package:vestie/core/widgets/common/post_auth_header.dart';
import 'package:vestie/core/widgets/text/app_text.dart';
import '../../cubit/user_vff_group_invitation_list_cubit.dart';
import '../../models/user_vff_hub_ui_model.dart';
import '../../models/user_vff_profile_ui_model.dart';
import '../user_vff_group_invitation_card.dart';
/// Full group invitation list scaffold.
final class UserVffGroupInvitationsScaffold extends StatelessWidget {
  const UserVffGroupInvitationsScaffold({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: PostAuthGradientBackground(
        child: Column(
          children: [
            PostAuthHeader(
              title: AppStrings.userVffGroupInvitationsTitle,
              leading: AppBackButton(onPressed: () => context.pop()),
              titleStyle: GoogleFonts.lato(
                fontSize: 20.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.grey1100,
              ),
            ),
            Expanded(
              child: ColoredBox(
                color: AppColors.surface,
                child: Padding(
                  padding: AppDimens.sheetInsetList,
                  child: BlocBuilder<UserVffGroupInvitationListCubit,
                    List<UserVffGroupInviteUi>>(
                  builder: (context, items) {
                    if (items.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: EdgeInsets.all(AppDimens.p24),
                          child: AppText(
                            AppStrings.emptyData,
                            style: GoogleFonts.lato(
                              fontSize: 15.sp,
                              color: AppColors.textBody,
                            ),
                          ),
                        ),
                      );
                    }

                    final cubit =
                        context.read<UserVffGroupInvitationListCubit>();

                    return ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.only(bottom: AppDimens.v24),
                      itemCount: items.length,
                      itemBuilder: (_, i) {
                        final g = items[i];
                        return UserVffGroupInvitationCard(
                          item: g,
                          onPrimary: () {
                            if (g.kind ==
                                UserVffGroupInviteKind.memberRequestJoin) {
                              cubit.remove(g);
                              context.push(
                                AppRoutes.userVffProfile,
                                extra: UserVffProfileRouteArgs(
                                  profile: UserVffProfileUiModel
                                      .demoOliviaFollowing(),
                                ),
                              );
                              return;
                            }
                            cubit.remove(g);
                            context.push(
                              AppRoutes.userVffInvitesSent,
                              extra: UserVffInvitesSentRouteArgs(
                                inviteCount: 1,
                                projectName: g.titleLine,
                              ),
                            );
                          },
                          onDecline: () => cubit.remove(g),
                        );
                      },
                    );
                  },
                ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
