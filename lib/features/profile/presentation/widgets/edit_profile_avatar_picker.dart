import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/common/app_network_avatar.dart';
import '../../../../core/widgets/common/app_svg_icon.dart';
import '../../../../core/utils/app_permission_helper.dart';
import '../../../../core/widgets/text/app_text.dart';

/// Avatar row for edit profile — pick camera/gallery, preview local or network.
class EditProfileAvatarPicker extends StatelessWidget {
  final String? photoUrl;
  final String? pickedAvatarPath;
  final String initials;
  final ValueChanged<String> onPicked;

  const EditProfileAvatarPicker({
    super.key,
    this.photoUrl,
    this.pickedAvatarPath,
    this.initials = '?',
    required this.onPicked,
  });

  static final _picker = ImagePicker();

  Future<void> _pick(BuildContext context, ImageSource source) async {
    final allowed = await AppPermissionHelper.ensureImageSource(
      context,
      source,
    );
    if (!allowed) return;

    final picked = await _picker.pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 800,
      requestFullMetadata: AppPermissionHelper.galleryPickRequestsFullMetadata(
        source,
      ),
    );
    if (picked == null) return;
    onPicked(picked.path);
  }

  void _showSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: AppSvgIcon(
                assetPath: AppAssets.profileCamera,
                size: 24.w,
                color: AppColors.textPrimary,
              ),
              title: const AppText(AppStrings.takePhoto),
              onTap: () {
                sheetContext.pop();
                _pick(context, ImageSource.camera);
              },
            ),
            ListTile(
              leading: AppSvgIcon(
                assetPath: AppAssets.profilePhotoLibrary,
                size: 24.w,
                color: AppColors.textPrimary,
              ),
              title: const AppText(AppStrings.chooseFromGallery),
              onTap: () {
                sheetContext.pop();
                _pick(context, ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localFile = pickedAvatarPath != null && pickedAvatarPath!.isNotEmpty
        ? File(pickedAvatarPath!)
        : null;

    return Center(
      child: GestureDetector(
        onTap: () => _showSheet(context),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            AppNetworkAvatar(
              imageUrl: photoUrl,
              localFile: localFile,
              initials: initials,
              size: 100.r,
              backgroundColor: AppColors.cardBorder,
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: SvgPicture.asset(
                AppAssets.profileAvatarEditBadge,
                width: 28.r,
                height: 28.r,
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
