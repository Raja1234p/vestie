import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
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
          SizedBox(height: 8.h),
          GestureDetector(
            onTap: onViewAll,
            child: Center(
              child: Text(
                AppStrings.viewAllRequests,
                style: GoogleFonts.lato(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                  decoration: TextDecoration.underline,
                  decorationColor: AppColors.primary,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
