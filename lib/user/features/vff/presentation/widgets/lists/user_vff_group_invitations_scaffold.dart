import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:vestie/core/constants/app_dimens.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/utils/app_snackbar.dart';
import 'package:vestie/core/widgets/common/app_back_button.dart';
import 'package:vestie/core/widgets/common/post_auth_gradient_background.dart';
import 'package:vestie/core/widgets/common/post_auth_header.dart';
import 'package:vestie/core/widgets/common/app_shimmer.dart';
import 'package:vestie/core/widgets/text/app_text.dart';
import '../../cubit/user_vff_group_invitation_list_cubit.dart';
import '../../models/user_vff_hub_ui_model.dart';
import '../user_vff_group_invitation_card.dart';
import '../user_vff_hub_empty_body.dart';

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
                  child: BlocConsumer<UserVffGroupInvitationListCubit,
                      UserVffGroupInvitationListState>(
                    listenWhen: (prev, curr) =>
                        prev.errorMessage != curr.errorMessage &&
                        curr.errorMessage != null,
                    listener: (context, state) {
                      final message = state.errorMessage;
                      if (message == null || message.isEmpty) return;
                      AppSnackBar.showError(context, message);
                    },
                    builder: (context, state) {
                      if (state.status ==
                          UserVffGroupInvitationListStatus.loading) {
                        return const JoinRequestsListShimmer();
                      }

                      if (state.status ==
                          UserVffGroupInvitationListStatus.error) {
                        return Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              AppText(
                                state.errorMessage ?? AppStrings.errorGeneric,
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 12.h),
                              TextButton(
                                onPressed: () => context
                                    .read<UserVffGroupInvitationListCubit>()
                                    .load(),
                                child: AppText(AppStrings.btnRetry),
                              ),
                            ],
                          ),
                        );
                      }

                      final items = state.items;
                      if (items.isEmpty) {
                        return const UserVffHubEmptyBody(
                          message: AppStrings.userVffEmptyRequests,
                        );
                      }

                      final cubit =
                          context.read<UserVffGroupInvitationListCubit>();
                      final acting = state.actingRow;
                      final inboxBusy = acting != null;

                      return ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        padding: EdgeInsets.only(bottom: AppDimens.v24),
                        itemCount: items.length,
                        itemBuilder: (_, i) {
                          final g = items[i];
                          return UserVffGroupInvitationCard(
                            item: g,
                            actingRow: acting,
                            onPrimary: inboxBusy
                                ? null
                                : () {
                                    if (g.kind ==
                                        UserVffGroupInviteKind
                                            .memberRequestJoin) {
                                      return;
                                    }
                                    cubit.accept(g);
                                  },
                            onDecline:
                                inboxBusy ? null : () => cubit.decline(g),
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
