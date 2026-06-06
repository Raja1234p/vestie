import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:vestie/core/widgets/common/app_back_button.dart';
import 'package:vestie/core/widgets/common/app_shimmer.dart';
import 'package:vestie/core/widgets/common/post_auth_header.dart';
import 'package:vestie/core/widgets/common/post_auth_scroll_viewport.dart';

/// Initial project-detail load — real header when [title] is known; shimmer below.
///
/// Must sit under a parent [Scaffold] (do not wrap another [Scaffold] here).
class ProjectDetailLoadingBody extends StatelessWidget {
  final String? title;
  final VoidCallback onBack;

  const ProjectDetailLoadingBody({super.key, required this.onBack, this.title});

  bool get _hasTitle => title != null && title!.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    if (_hasTitle) {
      return _buildWithHeader();
    }
    return _buildWithoutTitle();
  }

  Widget _buildWithHeader() {
    return PostAuthScrollViewport(
      child: CustomScrollView(
        physics: const NeverScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: PostAuthHeader(
              applyTopSafeArea: false,
              title: title!.trim(),
              leading: AppBackButton(onPressed: onBack),
            ),
          ),
          const ProjectDetailContentShimmer(),
        ],
      ),
    );
  }

  Widget _buildWithoutTitle() {
    return Stack(
      fit: StackFit.expand,
      children: [
        const ProjectDetailShimmer(),
        SafeArea(
          bottom: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(8.w, 8.h, 16.w, 0),
            child: AppBackButton(onPressed: onBack),
          ),
        ),
      ],
    );
  }
}
