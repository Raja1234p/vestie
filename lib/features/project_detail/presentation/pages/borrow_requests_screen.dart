import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/utils/app_snackbar.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/common/app_back_button.dart';
import '../../../../core/widgets/common/post_auth_gradient_background.dart';
import '../../../../core/widgets/common/post_auth_header.dart';
import '../../domain/entities/borrow_request_entity.dart';
import '../widgets/borrow_request_card.dart';
import '../widgets/borrow_request_decision_dialogs.dart';

/// Full-screen borrow requests list.
/// Receives a [List] of [BorrowRequestEntity] via GoRouter extra.
class BorrowRequestsScreen extends StatelessWidget {
  final List<BorrowRequestEntity> requests;
  final bool isLeaderMode;
  final String projectId;

  const BorrowRequestsScreen({
    super.key,
    required this.requests,
    required this.projectId,
    this.isLeaderMode = false,
  });

  Future<bool> _approve(BuildContext context, BorrowRequestEntity request) async {
    final result = await ServiceLocator.instance.approveBorrowRequestUseCase(
      projectId: projectId,
      borrowRequestId: request.id,
    );
    return result.fold(
      (failure) {
        AppSnackBar.showError(context, failure.message);
        return false;
      },
      (_) => true,
    );
  }

  Future<bool> _reject(BuildContext context, BorrowRequestEntity request) async {
    final result = await ServiceLocator.instance.rejectBorrowRequestUseCase(
      projectId: projectId,
      borrowRequestId: request.id,
    );
    return result.fold(
      (failure) {
        AppSnackBar.showError(context, failure.message);
        return false;
      },
      (_) => true,
    );
  }

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
                leading: AppBackButton(
                  onPressed: () => context.pop(),
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
                          onAccept: isLeaderMode
                              ? () => showApproveBorrowRequestFlow(
                                    context,
                                    requests[i],
                                    () => _approve(context, requests[i]),
                                  )
                              : null,
                          onReject: isLeaderMode
                              ? () => showRejectBorrowRequestFlow(
                                    context,
                                    requests[i],
                                    () => _reject(context, requests[i]),
                                  )
                              : null,
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
