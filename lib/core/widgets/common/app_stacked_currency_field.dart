import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/app_colors.dart';

/// Large [displayDollar] text with a transparent [TextField] on top for digit
/// entry (system keyboard) — replaces in-app numpad on all platforms.
class AppStackedCurrencyField extends StatelessWidget {
  const AppStackedCurrencyField({
    super.key,
    required this.displayDollar,
    required this.controller,
    required this.focusNode,
    required this.onDigitsChanged,
  });

  final String displayDollar;
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onDigitsChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 64.h,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(
            displayDollar,
            style: GoogleFonts.lato(
              fontSize: 50.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.grey1100,
            ),
          ),
          TextField(
            focusNode: focusNode,
            controller: controller,
            onChanged: onDigitsChanged,
            showCursor: false,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(8),
            ],
            style: GoogleFonts.lato(
              color: Colors.transparent,
              fontSize: 50.sp,
              fontWeight: FontWeight.w700,
              height: 1,
            ),
            decoration: const InputDecoration(
              isDense: true,
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
            cursorColor: Colors.transparent,
          ),
        ],
      ),
    );
  }
}
