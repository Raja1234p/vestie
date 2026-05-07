import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/utils/app_snackbar.dart';
import '../../../../core/widgets/common/app_back_button.dart';
import '../../../../core/widgets/common/post_auth_gradient_background.dart';
import '../../../../core/widgets/common/post_auth_header.dart';
import '../../domain/entities/member_entity.dart';
import '../widgets/member_detail_actions.dart';
import '../widgets/member_detail_sections.dart';

class MemberDetailScreen extends StatelessWidget {
  final MemberEntity member;
  final String projectId;
  final String projectName;
  final bool isLeaderView;

  const MemberDetailScreen({
    super.key,
    required this.member,
    required this.projectId,
    required this.projectName,
    this.isLeaderView = false,
  });

  int get _contributionsCount => member.contributedAmount >= 0 ? 3 : 2;
  bool get _hasOverdue => member.overdueAmount != null && member.overdueAmount! > 0;
  bool get _isCoLeader => member.role == MemberRole.coLeader;

  double get _contributedTotal =>
      member.contributedAmount >= 0 ? member.contributedAmount * 10 : 1200;

  double get _borrowedTotal {
    if (_hasOverdue) return member.overdueAmount!;
    return member.contributedAmount < 0 ? member.contributedAmount.abs() : 115;
  }

  String _formatAmount(double value) =>
      value.toStringAsFixed(0).replaceAllMapped(
            RegExp(r'\B(?=(\d{3})+(?!\d))'),
            (_) => ',',
          );

  String get _username => '@${member.name.toLowerCase().replaceAll(' ', '-')}';

  Future<bool> _assignCoLeader(BuildContext context) async {
    final result = await ServiceLocator.instance.assignCoLeaderUseCase(
      projectId: projectId,
      userId: member.id,
    );
    if (!context.mounted) return false;
    return result.fold(
      (failure) {
        AppSnackBar.showError(context, failure.message);
        return false;
      },
      (_) => true,
    );
  }

  Future<bool> _removeCoLeader(BuildContext context) async {
    final result = await ServiceLocator.instance.removeCoLeaderUseCase(
      projectId: projectId,
      userId: member.id,
    );
    if (!context.mounted) return false;
    return result.fold(
      (failure) {
        AppSnackBar.showError(context, failure.message);
        return false;
      },
      (_) => true,
    );
  }

  Future<void> _removeMember(BuildContext context) async {
    final result = await ServiceLocator.instance.removeMemberUseCase(
      projectId: projectId,
      userId: member.id,
    );
    if (!context.mounted) return;
    result.fold(
      (failure) => AppSnackBar.showError(context, failure.message),
      (_) => AppSnackBar.showSuccess(context, 'Member removed successfully'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: PostAuthGradientBackground(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: PostAuthHeader(
                title: '${member.name}${AppStrings.memberProfileSuffix}',
                leading: AppBackButton(
                  onPressed: () => context.pop(),
                ),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MemberIdentitySection(
                      member: member,
                      username: _username,
                      projectName: projectName,
                      isLeaderView: isLeaderView,
                      isCoLeader: _isCoLeader,
                      onAssignCoLeader: () => _assignCoLeader(context),
                      onRemoveCoLeader: () => _removeCoLeader(context),
                    ),
                    SizedBox(height: 16.h),
                    MemberMetricsSection(
                      contributed: '\$${_formatAmount(_contributedTotal)}',
                      contributions: '$_contributionsCount',
                      borrowed: '\$${_formatAmount(_borrowedTotal)}',
                    ),
                    SizedBox(height: 24.h),
                    MemberTransactionsSection(
                      projectName: projectName,
                      borrowedAmount: _formatAmount(_borrowedTotal),
                    ),
                    if (isLeaderView && _hasOverdue) ...[
                      SizedBox(height: 12.h),
                      MemberOverdueBanner(member: member, projectId: projectId),
                    ],
                    if (isLeaderView) ...[
                      SizedBox(height: 70.h),
                      LeaderActionOutlineButton(
                        label: AppStrings.btnRemoveMember,
                        onTap: () => showRemoveMemberConfirm(
                          context,
                          memberName: member.name,
                          onConfirmed: () => _removeMember(context),
                        ),
                      ),
                    ],
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
