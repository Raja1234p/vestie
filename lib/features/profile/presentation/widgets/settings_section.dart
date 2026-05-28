import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/common/app_text.dart';

/// Row icon: tinted SVG or raster (design export).
enum SettingsIconKind {
  svg,
  png,
}

class SettingsItem {
  final String assetPath;
  final SettingsIconKind iconKind;
  final String label;
  final VoidCallback onTap;
  /// When [iconKind] is [SettingsIconKind.png], used if the PNG fails to load.
  final String? svgFallbackPath;

  const SettingsItem({
    required this.assetPath,
    this.iconKind = SettingsIconKind.svg,
    required this.label,
    required this.onTap,
    this.svgFallbackPath,
  });
}

class SettingsSection extends StatelessWidget {
  final List<SettingsItem> items;
  const SettingsSection({super.key, required this.items});

  static const Color _labelColor = Color(0xFF141414);

  Widget _leading(SettingsItem item) {
    final extent = 24.r;
    switch (item.iconKind) {
      case SettingsIconKind.png:
        return SizedBox(
          width: extent,
          height: extent,
          child: Image.asset(
            item.assetPath,
            width: extent,
            height: extent,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              final fallback = item.svgFallbackPath;
              if (fallback == null) {
                return const SizedBox.shrink();
              }
              return SvgPicture.asset(
                fallback,
                width: extent,
                height: extent,
                colorFilter: const ColorFilter.mode(
                  AppColors.purple1000,
                  BlendMode.srcIn,
                ),
              );
            },
          ),
        );
      case SettingsIconKind.svg:
        return SvgPicture.asset(
          item.assetPath,
          width: extent,
          height: extent,
          colorFilter: const ColorFilter.mode(
            AppColors.purple1000,
            BlendMode.srcIn,
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final radius = 12.r;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.settingsCardBg,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: AppColors.cardBorder, width: 1),
      ),
      child: Column(
        children: List.generate(items.length, (i) {
          final item = items[i];
          final isLast = i == items.length - 1;
          return Column(
            children: [
              InkWell(
                borderRadius: BorderRadius.only(
                  topLeft: i == 0 ? Radius.circular(radius) : Radius.zero,
                  topRight: i == 0 ? Radius.circular(radius) : Radius.zero,
                  bottomLeft: isLast ? Radius.circular(radius) : Radius.zero,
                  bottomRight: isLast ? Radius.circular(radius) : Radius.zero,
                ),
                onTap: item.onTap,
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
                  child: Row(
                    children: [
                      _leading(item),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: AppText(
                          item.label,
                          style: GoogleFonts.lato(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: _labelColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (!isLast)
                Divider(
                  height: 1,
                  thickness: 1,
                  color: AppColors.divider,
                ),
            ],
          );
        }),
      ),
    );
  }
}
