import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/common/app_back_button.dart';
import '../../../../core/widgets/common/post_auth_gradient_background.dart';
import '../../../../core/widgets/common/post_auth_header.dart';
import '../widgets/join_request_card.dart';
import '../widgets/join_request_result_dialogs.dart';

class JoinRequestsScreen extends StatelessWidget {
  const JoinRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const members = [
      ('OR', 'Olivia R.', '@olivia-r'),
      ('OR', 'Olivia R.', '@olivia-r'),
      ('OR', 'Olivia R.', '@olivia-r'),
      ('OR', 'Olivia R.', '@olivia-r'),
    ];

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: PostAuthGradientBackground(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: PostAuthHeader(
                title: AppStrings.menuJoinRequests,
                leading: AppBackButton(
                  onPressed: () => context.pop(),
                ),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(16.w, 6.h, 16.w, 22.h),
              sliver: SliverList.separated(
                itemBuilder: (_, i) => JoinRequestCard(
                  initials: members[i].$1,
                  name: members[i].$2,
                  username: members[i].$3,
                  onAccept: () => showJoinRequestApprovedDialog(
                    context,
                    memberName: members[i].$2,
                  ),
                  onDecline: () => showJoinRequestDeclinedDialog(
                    context,
                    memberName: members[i].$2,
                  ),
                ),
                separatorBuilder: (_, _) => SizedBox(height: 2.h),
                itemCount: members.length,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
