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

    // Gallery uses the system picker — do not pre-check Photos permission.
    // (Android photo picker; iOS PHPicker). Pre-checking Permission.photos on a
    // fresh iOS install can misreport permanentlyDenied and show Settings
    // before the user ever sees the system prompt.
    if (source == ImageSource.gallery) {
      return true;
    }

    final permission = Permission.camera;

    var status = await permission.status;
    if (status.isGranted || status.isLimited) return true;

    // Always show the system permission prompt when not granted.
    // Do **not** open the Settings dialog based on status alone — on a fresh
    // install permission_handler can report permanentlyDenied/restricted
    // before the user has denied anything.
    status = await permission.request();
    if (status.isGranted || status.isLimited) return true;

    if (!context.mounted) return false;

    // Settings only after the system request, and only if still blocked.
    if (status.isPermanentlyDenied || status.isRestricted) {
      await _showOpenSettingsDialog(context, source: source);
    }
    return false;
  }

  /// Avoid full photo metadata on gallery picks (iOS full-library access).
  static bool galleryPickRequestsFullMetadata(ImageSource source) {
    return false;
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
