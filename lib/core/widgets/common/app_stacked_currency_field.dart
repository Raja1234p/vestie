import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/app_colors.dart';
import '../../utils/ios_numeric_keyboard_input.dart';

/// Large [displayDollar] text with a transparent [TextField] on top for digit
/// entry (system keyboard) — replaces in-app numpad on all platforms.
class AppStackedCurrencyField extends StatelessWidget {
  const AppStackedCurrencyField({
    super.key,
    required this.displayDollar,
    required this.controller,
    required this.focusNode,
    required this.onDigitsChanged,
    this.amountFontSize,
  });

  final String displayDollar;
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onDigitsChanged;
  final double? amountFontSize;

  static const _keyboardType = TextInputType.numberWithOptions(
    signed: false,
    decimal: false,
  );

  static final _inputFormatters = <TextInputFormatter>[
    FilteringTextInputFormatter.digitsOnly,
    LengthLimitingTextInputFormatter(8),
  ];

  @override
  Widget build(BuildContext context) {
    final fontSize = amountFontSize ?? 50.sp;
    const textInputAction = TextInputAction.done;
    final keyboardType = IosNumericKeyboardInput.effectiveKeyboardType(
      keyboardType: _keyboardType,
      isMultiline: false,
      textInputAction: textInputAction,
    );
    final inputFormatters = IosNumericKeyboardInput.effectiveFormatters(
      keyboardType: _keyboardType,
      isMultiline: false,
      textInputAction: textInputAction,
      inputFormatters: _inputFormatters,
    );
    final disableTextAssist = IosNumericKeyboardInput.shouldDisableTextAssist(
      keyboardType: _keyboardType,
      isMultiline: false,
      textInputAction: textInputAction,
    );

    return SizedBox(
      height: (fontSize * 1.35).h,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(
            displayDollar,
            style: GoogleFonts.lato(
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
              color: AppColors.grey1100,
            ),
          ),
          TextField(
            focusNode: focusNode,
            controller: controller,
            onChanged: onDigitsChanged,
            onSubmitted: (_) {
              FocusManager.instance.primaryFocus?.unfocus();
            },
            onTapOutside: (_) {
              FocusManager.instance.primaryFocus?.unfocus();
            },
            showCursor: false,
            textAlign: TextAlign.center,
            keyboardType: keyboardType,
            textInputAction: textInputAction,
            autocorrect: !disableTextAssist,
            enableSuggestions: !disableTextAssist,
            textCapitalization: TextCapitalization.none,
            inputFormatters: inputFormatters,
            style: GoogleFonts.lato(
              color: Colors.transparent,
              fontSize: fontSize,
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
