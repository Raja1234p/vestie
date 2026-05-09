import 'package:flutter/widgets.dart';

import 'storyboard_desktop_loader_stub.dart'
    if (dart.library.io) 'storyboard_desktop_loader_io.dart';

/// Default Desktop images folder (user-supplied mocks for storyboards).
const kStoryboardDesktopImagesPath = r'C:\Users\hp\Desktop\images';

Widget? loadStoryboardDesktopImage(
  String filename, {
  String basePath = kStoryboardDesktopImagesPath,
  BoxFit fit = BoxFit.cover,
}) =>
    implLoadStoryboardDesktopImage(filename, basePath: basePath, fit: fit);
