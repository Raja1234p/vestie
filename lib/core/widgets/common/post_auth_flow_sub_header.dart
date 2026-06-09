import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../theme/app_colors.dart';
import 'app_back_button.dart';
import 'post_auth_header.dart';

/// Standard gradient sub-header for post-auth flow screens (Edit Profile parity).
///
/// Uses default [PostAuthHeader] padding + [AppDimens.postAuthContentTopGap] —
/// do not override `padding` unless product explicitly requires it.
class PostAuthFlowSubHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onBack;
  final Widget? trailing;

  const PostAuthFlowSubHeader({
    super.key,
    required this.title,
    this.onBack,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return PostAuthHeader(
      title: title,
      leading: AppBackButton(
        onPressed: onBack ?? () => context.pop(),
        color: AppColors.textPrimary,
      ),
      trailing: trailing,
    );
  }
}
