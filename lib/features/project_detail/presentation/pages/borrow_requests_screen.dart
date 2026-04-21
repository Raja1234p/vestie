import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/common/post_auth_gradient_background.dart';
import '../../../../core/widgets/common/post_auth_header.dart';
import '../../domain/entities/borrow_request_entity.dart';
import '../widgets/borrow_request_card.dart';

/// Full-screen borrow requests list.
/// Receives a [List] of [BorrowRequestEntity] via GoRouter extra.
class BorrowRequestsScreen extends StatelessWidget {
  final List<BorrowRequestEntity> requests;
  final bool isLeaderMode;

  const BorrowRequestsScreen({
    super.key,
    required this.requests,
    this.isLeaderMode = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: PostAuthGradientBackground(
        child: CustomScrollView(
          slivers: [
            // ── Header ──────────────────────────────────────
            SliverToBoxAdapter(
              child: PostAuthHeader(
                title: AppStrings.borrowRequestsTitle,
                leading: GestureDetector(
                  onTap: () => context.pop(),
                  child: Icon(
                    Icons.arrow_back_rounded,
                    color: AppColors.grey1100,
                    size: 22.w,
                  ),
                ),
              ),
            ),

            // ── List ────────────────────────────────────────
            SliverPadding(
              padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 32.h),
              sliver: requests.isEmpty
                  ? SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.only(top: 24.h),
                        child: Center(
                          child: Text(
                            AppStrings.emptyData,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: AppColors.textBody,
                                ),
                          ),
                        ),
                      ),
                    )
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (_, i) => BorrowRequestCard(
                          request: requests[i],
                          actionMode: isLeaderMode
                              ? BorrowRequestActionMode.decision
                              : BorrowRequestActionMode.vote,
                        ),
                        childCount: requests.length,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
