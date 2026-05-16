import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../theme/app_colors.dart';

class AppInviteMembersDashedDivider extends StatelessWidget {
  const AppInviteMembersDashedDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 1.h,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final dashCount = (constraints.maxWidth / 12).floor().clamp(1, 200);
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(
              dashCount,
              (_) => Container(
                width: 6.w,
                height: 1.h,
                color: AppColors.purple300,
              ),
            ),
          );
        },
      ),
    );
  }
}
