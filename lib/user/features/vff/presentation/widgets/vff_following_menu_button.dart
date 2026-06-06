import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:vestie/core/constants/app_assets.dart';
import 'package:vestie/core/constants/app_dimens.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/theme/app_shadows.dart';
import 'package:vestie/core/widgets/common/app_svg_icon.dart';
import 'package:vestie/core/widgets/text/app_text.dart';

/// Following pill with Remove overlay above (Figma VFF accepted).
class VffFollowingMenuButton extends StatefulWidget {
  final VoidCallback? onRemove;
  final bool isRemoveLoading;

  const VffFollowingMenuButton({
    super.key,
    required this.onRemove,
    this.isRemoveLoading = false,
  });

  @override
  State<VffFollowingMenuButton> createState() => _VffFollowingMenuButtonState();
}

class _VffFollowingMenuButtonState extends State<VffFollowingMenuButton> {
  bool _menuOpen = false;

  void _toggleMenu() => setState(() => _menuOpen = !_menuOpen);

  void _closeMenu() {
    if (!_menuOpen) return;
    setState(() => _menuOpen = false);
  }

  void _onRemoveTap() {
    if (widget.isRemoveLoading || widget.onRemove == null) return;
    _closeMenu();
    widget.onRemove!();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_menuOpen) ...[
          _RemoveOverlay(
            onTap: _onRemoveTap,
            isLoading: widget.isRemoveLoading,
          ),
          SizedBox(height: 8.h),
        ],
        GestureDetector(
          onTap: widget.isRemoveLoading ? null : _toggleMenu,
          behavior: HitTestBehavior.opaque,
          child: SizedBox(
            width: double.infinity,
            height: 54.h,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.purple100,
                borderRadius: BorderRadius.circular(AppRadius.r8),
                border: Border.all(color: AppColors.purple100),
              ),
              child: widget.isRemoveLoading
                  ? Center(
                      child: SizedBox(
                        width: 24.w,
                        height: 24.w,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.purple700,
                        ),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AppText(
                          AppStrings.userVffFooterMenuLabel,
                          style: GoogleFonts.lato(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w500,
                            color: AppColors.grey900,
                          ),
                        ),
                        SizedBox(width: AppDimens.p8),
                        Transform.rotate(
                          angle: _menuOpen ? 3.141592653589793 : 0,
                          child: AppSvgIcon(
                            assetPath: AppAssets.iconChevronDown,
                            color: AppColors.grey900,
                            size: 22.r,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ],
    );
  }
}

class _RemoveOverlay extends StatelessWidget {
  final VoidCallback? onTap;
  final bool isLoading;

  const _RemoveOverlay({required this.onTap, this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      elevation: 0,
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(AppRadius.r8),
        child: Ink(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.r8),
            border: Border.all(color: AppColors.red300, width: 1),
            boxShadow: AppShadows.vffRemoveMenuOverlay,
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            child: Align(
              alignment: Alignment.centerLeft,
              child: isLoading
                  ? SizedBox(
                      width: 22.w,
                      height: 22.w,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.red900,
                      ),
                    )
                  : AppText(
                      AppStrings.btnRemove,
                      style: GoogleFonts.lato(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.red900,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
