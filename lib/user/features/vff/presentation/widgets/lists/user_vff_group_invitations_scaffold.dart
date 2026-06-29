import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:vestie/core/presentation/widgets/list_load_more_footer.dart';
import 'package:vestie/core/constants/app_dimens.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/common/app_toast.dart';
import 'package:vestie/core/widgets/common/app_back_button.dart';
import 'package:vestie/core/widgets/common/post_auth_gradient_background.dart';
import 'package:vestie/core/widgets/common/post_auth_header.dart';
import 'package:vestie/core/widgets/text/app_text.dart';
import '../../cubit/user_vff_group_invitation_list_cubit.dart';
import '../../models/user_vff_hub_ui_model.dart';
import '../user_vff_full_list_section_title.dart';
import '../user_vff_group_invitation_card.dart';
import '../user_vff_hub_empty_body.dart';
import '../user_vff_inbox_interaction_lock.dart';
import '../user_vff_shimmers.dart';

/// Full group invitation list scaffold.
final class UserVffGroupInvitationsScaffold extends StatefulWidget {
  const UserVffGroupInvitationsScaffold({super.key});

  @override
  State<UserVffGroupInvitationsScaffold> createState() =>
      _UserVffGroupInvitationsScaffoldState();
}

class _UserVffGroupInvitationsScaffoldState
    extends State<UserVffGroupInvitationsScaffold> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final max = _scrollController.position.maxScrollExtent;
    final offset = _scrollController.offset;
    if (max - offset <= 200) {
      context.read<UserVffGroupInvitationListCubit>().loadMore();
    }
  }

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
                fontSize: 28.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.grey1100,
              ),
            ),
            Expanded(
              child: ColoredBox(
                color: AppColors.surface,
                child:
                    BlocConsumer<
                      UserVffGroupInvitationListCubit,
                      UserVffGroupInvitationListState
                    >(
                      listenWhen: (prev, curr) =>
                          prev.errorMessage != curr.errorMessage &&
                          curr.errorMessage != null,
                      listener: (context, state) {
                        final message = state.errorMessage;
                        if (message == null || message.isEmpty) return;
                        AppToast.showError(context, message);
                      },
                      builder: (context, state) {
                        if (state.status ==
                            UserVffGroupInvitationListStatus.loading) {
                          return Padding(
                            padding: AppDimens.vffInboxFullListSheetInset,
                            child: const UserVffGroupInvitationListShimmer(),
                          );
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
                          return Padding(
                            padding: AppDimens.vffInboxFullListEmptyInset,
                            child: const UserVffHubEmptyBody(
                              message: AppStrings.userVffEmptyRequests,
                            ),
                          );
                        }

                        final cubit = context
                            .read<UserVffGroupInvitationListCubit>();
                        final acting = state.actingRow;
                        final inboxBusy = acting != null;

                        return Padding(
                          padding: AppDimens.vffInboxFullListSheetInset,
                          child: UserVffInboxInteractionLock(
                            locked: inboxBusy,
                            child: ListView.builder(
                              controller: _scrollController,
                              physics: inboxBusy
                                  ? const NeverScrollableScrollPhysics()
                                  : const BouncingScrollPhysics(),
                              padding: EdgeInsets.only(bottom: AppDimens.v24),
                              itemCount: items.length + 2,
                              itemBuilder: (_, i) {
                                if (i == 0) {
                                  return const UserVffFullListSectionTitle(
                                    title:
                                        AppStrings.userVffGroupInvitationsTitle,
                                  );
                                }
                                if (i == items.length + 1) {
                                  return ListLoadMoreFooter(
                                    loadingMore: state.loadingMore,
                                  );
                                }
                                final g = items[i - 1];
                                return UserVffGroupInvitationCard(
                                  item: g,
                                  actingRow: acting,
                                  onPrimary: () {
                                    if (g.kind ==
                                        UserVffGroupInviteKind
                                            .memberRequestJoin) {
                                      return;
                                    }
                                    cubit.accept(g);
                                  },
                                  onDecline: () => cubit.decline(g),
                                  bottomSpacing: AppDimens.v16,
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
