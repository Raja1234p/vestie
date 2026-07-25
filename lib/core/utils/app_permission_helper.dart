import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../constants/app_strings.dart';
import '../theme/app_colors.dart';
import '../widgets/common/app_action_dialog.dart';

/// Camera **and** gallery access — on user action only (profile / project images).
///
/// Best-practice flow (official [permission_handler]):
/// 1. **Request** first — `permission.request()` (no-op if already granted;
///    shows system dialog when status is default/`isDenied`)
/// 2. **Check** the returned status
/// 3. Granted / limited → proceed to [ImagePicker]
/// 4. Soft denied → request again (no toast); next user tap also re-requests
/// 5. Permanently denied / restricted → Open Settings
///
/// Android gallery uses the system photo picker (no runtime Photos permission).
abstract final class AppPermissionHelper {
  AppPermissionHelper._();

  /// Call before [ImagePicker.pickImage] / [ImagePicker.pickMultiImage].
  static Future<bool> ensureImageSource(
    BuildContext context,
    ImageSource source,
  ) async {
    if (kIsWeb) return true;

    // Android gallery: system photo picker — no Permission.photos.
    if (source == ImageSource.gallery &&
        defaultTargetPlatform == TargetPlatform.android) {
      return true;
    }

    final permission = source == ImageSource.camera
        ? Permission.camera
        : Permission.photos;

    return _requestThenCheck(
      context,
      permission: permission,
      source: source,
    );
  }

  /// Official image_picker: `false` for PHPicker after Photos allow/limited.
  static bool galleryPickRequestsFullMetadata(ImageSource source) {
    return false;
  }

  static void runAfterModalClosed(BuildContext context, VoidCallback action) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) action();
    });
  }

  /// 1) Request → 2) Check → 3) Proceed or deny UI.
  static Future<bool> _requestThenCheck(
    BuildContext context, {
    required Permission permission,
    required ImageSource source,
  }) async {
    // Step 1 — request first (covers fresh install default denied).
    // If already granted, request() does nothing and returns granted.
    var status = await permission
        .onDeniedCallback(() {})
        .onGrantedCallback(() {})
        .onPermanentlyDeniedCallback(() {})
        .onRestrictedCallback(() {})
        .onLimitedCallback(() {})
        .onProvisionalCallback(() {})
        .request();

    // Soft deny → ask again (no toast). OS may show the system dialog again.
    if (status.isDenied) {
      status = await permission
          .onDeniedCallback(() {})
          .onGrantedCallback(() {})
          .onPermanentlyDeniedCallback(() {})
          .onRestrictedCallback(() {})
          .onLimitedCallback(() {})
          .onProvisionalCallback(() {})
          .request();
    }

    // Step 2 — check result, then proceed.
    if (status.isGranted || status.isLimited || status.isProvisional) {
      return true;
    }

    if (!context.mounted) return false;

    // Permanently blocked — Open Settings (official guidance).
    if (status.isPermanentlyDenied || status.isRestricted) {
      await _showOpenSettingsDialog(context, source: source);
      return false;
    }

    // Still soft-denied after re-ask — stay silent; next tap will request again.
    return false;
  }

  static Future<void> _showOpenSettingsDialog(
    BuildContext context, {
    required ImageSource source,
  }) async {
    if (!context.mounted) return;

    await Future<void>.delayed(Duration.zero);
    if (!context.mounted) return;

    final isCamera = source == ImageSource.camera;

    await AppActionDialog.show(
      context,
      useRootNavigator: true,
      title: isCamera
          ? AppStrings.permissionCameraTitle
          : AppStrings.permissionPhotosTitle,
      description: isCamera
          ? AppStrings.permissionCameraSettingsBody
          : AppStrings.permissionPhotosSettingsBody,
      primaryLabel: AppStrings.btnOpenSettings,
      secondaryLabel: AppStrings.btnCancel,
      showSecondary: true,
      primaryColor: AppColors.primary,
      onPrimary: () {
        Navigator.of(context, rootNavigator: true).pop();
        openAppSettings();
      },
    );
  }
}
