import 'dart:io';

import 'package:flutter/material.dart';

/// Loads an image from a local Desktop folder when the file exists (Windows dev).
///
/// Optionally drop PNG/JPG files into `[User]/Desktop/images/` using names such as
/// `vacation_hero.png` / `emergency_hero.png` (see [CreateProjectFundKindUi.suggestedHeroFilename]).
Widget? implLoadStoryboardDesktopImage(
  String filename, {
  required String basePath,
  BoxFit fit = BoxFit.cover,
}) {
  try {
    final path = '$basePath${Platform.pathSeparator}$filename'.replaceAll(
      '/',
      Platform.pathSeparator,
    );
    final file = File(path);
    if (!file.existsSync()) return null;
    return Image.file(file, fit: fit);
  } catch (_) {
    return null;
  }
}
