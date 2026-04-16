import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';

/// Figma-accurate numeric keypad (1-9, 0, backspace).
class NumericKeypad extends StatelessWidget {
  final ValueChanged<String> onDigit;
  final VoidCallback onBackspace;

  const NumericKeypad({
    super.key,
    required this.onDigit,
    required this.onBackspace,
  });

  static const _keys = ['1','2','3','4','5','6','7','8','9','','0','⌫'];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.searchBarBg,
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 2.2,
          crossAxisSpacing: 8.w,
          mainAxisSpacing: 8.h,
        ),
        itemCount: _keys.length,
        itemBuilder: (_, i) {
          final key = _keys[i];
          if (key.isEmpty) return const SizedBox.shrink();
          return _KeyButton(
            label: key,
            onTap: () {
              if (key == '⌫') {
                onBackspace();
              } else {
                onDigit(key);
              }
            },
          );
        },
      ),
    );
  }
}

class _KeyButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _KeyButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isBackspace = label == '⌫';
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.textBody.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: isBackspace
              ? Icon(Icons.backspace_outlined,
                  size: 20.w, color: AppColors.textPrimary)
              : Text(label,
                  style: GoogleFonts.lato(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary)),
        ),
      ),
    );
  }
}
