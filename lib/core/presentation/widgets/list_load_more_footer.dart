import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../theme/app_colors.dart';

/// Bottom-of-list spinner shown while fetching the next paginated page.
class ListLoadMoreFooter extends StatelessWidget {
  const ListLoadMoreFooter({super.key, required this.loadingMore});

  final bool loadingMore;

  @override
  Widget build(BuildContext context) {
    if (!loadingMore) return const SizedBox.shrink();
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}
