import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/text/app_text.dart';
import '../../domain/entities/borrow_request_entity.dart';
import 'borrow_request_card.dart';

/// Inline borrow requests tab content: shows up to 2 cards + "View All" footer.
class BorrowRequestsTab extends StatelessWidget {
  final List<BorrowRequestEntity> requests;
  final VoidCallback onViewAll;

  const BorrowRequestsTab({
    super.key,
    required this.requests,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    final preview = requests.take(2).toList();
    return Column(
      children: [
        ...preview.map(
          (r) => BorrowRequestCard(request: r),
        ),
        if (requests.length > 2) ...[
          SizedBox(height: 10.h),
          GestureDetector(
            onTap: onViewAll,
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: double.infinity,
              color: AppColors.surface,
              padding: EdgeInsets.symmetric(vertical: 14.h),
              alignment: Alignment.center,
              child: AppText(
                AppStrings.viewAllRequests,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.neutral1200,
                    ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
