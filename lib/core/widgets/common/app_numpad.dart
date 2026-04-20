import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../text/app_text.dart';

/// A reusable numeric keypad with a backspace button.
/// Extracts the custom numpad from the Create Project flow for global usage.
class AppNumpad extends StatelessWidget {
  final ValueChanged<String> onDigit;
  final VoidCallback onBackspace;
  
  const AppNumpad({
    super.key,
    required this.onDigit,
    required this.onBackspace,
  });

  static const _keys = ['1','2','3','4','5','6','7','8','9','','0','⌫'];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.searchBarBg,
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 32.h),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 2.4,
          crossAxisSpacing: 8.w,
          mainAxisSpacing: 8.h,
        ),
        itemCount: _keys.length,
        itemBuilder: (_, i) {
          final k = _keys[i];
          if (k.isEmpty) return const SizedBox.shrink();
          return GestureDetector(
            onTap: () => k == '⌫' ? onBackspace() : onDigit(k),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.r),
                boxShadow: [
                  BoxShadow(
                      color: AppColors.textBody.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2)),
                ],
              ),
              child: Center(
                child: k == '⌫'
                    ? Icon(Icons.backspace_outlined,
                        size: 20.w, color: AppColors.textPrimary)
                    : AppText(k,
                        style: GoogleFonts.lato(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary)),
              ),
            ),
          );
        },
      ),
    );
  }
}
