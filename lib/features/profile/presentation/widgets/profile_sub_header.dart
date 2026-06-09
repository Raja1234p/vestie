import 'package:flutter/material.dart';

import '../../../../core/widgets/common/post_auth_flow_sub_header.dart';

/// Reusable gradient header for profile sub-screens (← Title).
class ProfileSubHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onBack;
  final Widget? trailing;

  const ProfileSubHeader({
    super.key,
    required this.title,
    this.onBack,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return PostAuthFlowSubHeader(
      title: title,
      onBack: onBack,
      trailing: trailing,
    );
  }
}
