import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import 'package:vestie/core/constants/app_assets.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/utils/app_permission_helper.dart';
import 'package:vestie/core/widgets/text/app_text.dart';

/// Gallery / camera picker for create-project images.
abstract final class CreateProjectImagePicker {
  CreateProjectImagePicker._();

  static final ImagePicker _picker = ImagePicker();

  static Future<List<String>> pickFromGallery(
    BuildContext context, {
    required int remainingSlots,
  }) async {
    if (remainingSlots <= 0) return const [];

    final allowed = await AppPermissionHelper.ensureImageSource(
      context,
      ImageSource.gallery,
    );
    if (!allowed) return const [];

    final picked = await _picker.pickMultiImage(
      imageQuality: 85,
      maxWidth: 1600,
      limit: remainingSlots,
      requestFullMetadata: AppPermissionHelper.galleryPickRequestsFullMetadata(
        ImageSource.gallery,
      ),
    );
    if (picked.isEmpty) return const [];
    return picked.map((file) => file.path).toList(growable: false);
  }

  static Future<List<String>> pickFromCamera(BuildContext context) async {
    final allowed = await AppPermissionHelper.ensureImageSource(
      context,
      ImageSource.camera,
    );
    if (!allowed) return const [];

    final picked = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
      maxWidth: 1600,
    );
    if (picked == null) return const [];
    return [picked.path];
  }

  static Future<void> showSourceSheet(
    BuildContext context, {
    required int remainingSlots,
    required void Function(List<String> paths) onPicked,
  }) async {
    if (remainingSlots <= 0) return;

    await showModalBottomSheet<void>(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _SourceTile(
              iconAsset: AppAssets.profilePhotoLibrary,
              title: AppStrings.chooseFromGallery,
              onTap: () {
                sheetContext.pop();
                AppPermissionHelper.runAfterModalClosed(context, () async {
                  final paths = await pickFromGallery(
                    context,
                    remainingSlots: remainingSlots,
                  );
                  if (paths.isNotEmpty) onPicked(paths);
                });
              },
            ),
            _SourceTile(
              iconAsset: AppAssets.profileCamera,
              title: AppStrings.takePhoto,
              onTap: () {
                sheetContext.pop();
                AppPermissionHelper.runAfterModalClosed(context, () async {
                  final paths = await pickFromCamera(context);
                  if (paths.isNotEmpty) onPicked(paths);
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SourceTile extends StatelessWidget {
  final String iconAsset;
  final String title;
  final VoidCallback onTap;

  const _SourceTile({
    required this.iconAsset,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: SvgPicture.asset(iconAsset, width: 24.w, height: 24.w),
      title: AppText(title),
      onTap: onTap,
    );
  }
}
