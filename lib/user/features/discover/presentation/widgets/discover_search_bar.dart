import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:vestie/core/constants/app_assets.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/common/app_svg_icon.dart';

class DiscoverSearchBar extends StatefulWidget {
  final String query;
  final ValueChanged<String> onChanged;

  const DiscoverSearchBar({
    super.key,
    required this.query,
    required this.onChanged,
  });

  @override
  State<DiscoverSearchBar> createState() => _DiscoverSearchBarState();
}

class _DiscoverSearchBarState extends State<DiscoverSearchBar> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.query);
  }

  @override
  void didUpdateWidget(covariant DiscoverSearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.query != _controller.text) {
      _controller.value = TextEditingValue(
        text: widget.query,
        selection: TextSelection.collapsed(offset: widget.query.length),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = 56.h;
    final radius = height / 2;

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: AppColors.searchBarBg,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: AppColors.inputFieldBorder),
      ),
      alignment: Alignment.center,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              onChanged: widget.onChanged,
              onTapOutside: (_) {
                FocusManager.instance.primaryFocus?.unfocus();
              },
              textAlignVertical: TextAlignVertical.center,
              style: GoogleFonts.lato(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.inputFieldText,
                height: 1.2,
              ),
              decoration: InputDecoration(
                hintText: AppStrings.discoverSearchHint,
                hintStyle: GoogleFonts.lato(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: AppColors.grey800,
                  height: 1.2,
                ),
                isCollapsed: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 16.w),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(right: 16.w),
            child: AppSvgIcon(
              assetPath: AppAssets.navDiscover,
              size: 20.w,
              color: AppColors.purple1000,
            ),
          ),
        ],
      ),
    );
  }
}
