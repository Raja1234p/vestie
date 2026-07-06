import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../constants/app_strings.dart';
import '../theme/app_colors.dart';
import '../widgets/common/app_action_dialog.dart';

/// Camera / gallery permission — on user action only (profile photo, project images).
///
/// Notifications: [FcmPushService.initialize] via flutter_local_notifications
/// (`requestAlertPermission: true` on iOS, `requestNotificationsPermission` on Android).
abstract final class AppPermissionHelper {
  AppPermissionHelper._();

  /// Call before [ImagePicker.pickImage] / [ImagePicker.pickMultiImage].
  static Future<bool> ensureImageSource(
    BuildContext context,
    ImageSource source,
  ) async {
    if (kIsWeb) return true;

    final permission = _permissionFor(source);

    var status = await permission.status;
    if (status.isGranted || status.isLimited) return true;

    if (status.isPermanentlyDenied || status.isRestricted) {
      if (context.mounted) {
        await _showOpenSettingsDialog(context, source: source);
      }
      return false;
    }

    status = await permission.request();
    if (status.isGranted || status.isLimited) return true;

    if (!context.mounted) return false;

    await _showOpenSettingsDialog(context, source: source);
    return false;
  }

  static Permission _permissionFor(ImageSource source) {
    return source == ImageSource.camera ? Permission.camera : Permission.photos;
  }

  static bool galleryPickRequestsFullMetadata(ImageSource source) {
    return source == ImageSource.gallery;
  }

  /// Runs [action] after the current frame (e.g. once a bottom sheet has closed).
  static void runAfterModalClosed(BuildContext context, VoidCallback action) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) action();
    });
  }

  static Future<void> _showOpenSettingsDialog(
    BuildContext context, {
    required ImageSource source,
  }) async {
    if (!context.mounted) return;

    // Wait for route transitions (bottom sheet pop) before presenting dialog.
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
