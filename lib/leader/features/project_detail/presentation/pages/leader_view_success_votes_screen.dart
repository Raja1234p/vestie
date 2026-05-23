import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:vestie/app/router/route_args/project_detail_flow_args.dart';
import 'package:vestie/core/widgets/common/app_back_button.dart';
import 'package:vestie/core/widgets/common/post_auth_gradient_background.dart';
import 'package:vestie/core/widgets/common/post_auth_header.dart';
import 'package:vestie/leader/features/project_detail/presentation/widgets/leader_success_vote/leader_success_vote_majority_banner.dart';
import 'package:vestie/leader/features/project_detail/presentation/widgets/leader_success_vote/leader_success_vote_member_list.dart';
import 'package:vestie/leader/features/project_detail/presentation/widgets/leader_success_vote/leader_success_vote_top_section.dart';
import 'package:vestie/leader/features/project_detail/presentation/widgets/leader_success_vote/leader_success_vote_tally_cards.dart';

/// Group leader monitors an active success vote (Figma Post-Success — voting window).
class LeaderViewSuccessVotesScreen extends StatelessWidget {
  final LeaderViewSuccessVotesRouteArgs args;

  const LeaderViewSuccessVotesScreen({super.key, required this.args});

  @override
  Widget build(BuildContext context) {
    final data = args.data;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: PostAuthGradientBackground(
        child: Column(
          children: [
            PostAuthHeader(
              title: args.projectName,
              leading: AppBackButton(onPressed: () => context.pop()),
              bottomGap: 0,
              padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 12.h),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(bottom: 24.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    LeaderSuccessVoteCountdownSection(
                      initialRemaining: data.remaining,
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          LeaderSuccessVoteTallyCards(
                            agreedCount: data.agreedCount,
                            disagreedCount: data.disagreedCount,
                            notVotedCount: data.notVotedCount,
                          ),
                          SizedBox(height: 12.h),
                          LeaderSuccessVoteMajorityBanner(
                            majorityRequired: data.majorityRequired,
                            totalMembers: data.totalMembers,
                          ),
                          SizedBox(height: 20.h),
                          LeaderSuccessVoteMemberList(members: data.members),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
