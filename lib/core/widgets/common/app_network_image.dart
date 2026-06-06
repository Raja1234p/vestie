import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import 'app_shimmer.dart';

/// Cached remote image — use for any network URL across the app.
class AppNetworkImage extends StatelessWidget {
  final String? imageUrl;
  final File? localFile;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;

  const AppNetworkImage({
    super.key,
    this.imageUrl,
    this.localFile,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.zero;
    Widget child;

    if (localFile != null) {
      child = Image.file(localFile!, width: width, height: height, fit: fit);
    } else if (isValidNetworkUrl(imageUrl)) {
      child = CachedNetworkImage(
        imageUrl: imageUrl!.trim(),
        width: width,
        height: height,
        fit: fit,
        placeholder: (context, url) => placeholder ?? _defaultPlaceholder(),
        errorWidget: (context, url, error) => errorWidget ?? _defaultError(),
      );
    } else {
      child = errorWidget ?? _defaultError();
    }

    return ClipRRect(borderRadius: radius, child: child);
  }

  static bool isValidNetworkUrl(String? url) {
    final t = url?.trim() ?? '';
    return t.isNotEmpty &&
        (t.startsWith('http://') || t.startsWith('https://'));
  }

  Widget _defaultPlaceholder() {
    return AppShimmer.imagePlaceholder(
      width: width,
      height: height,
      borderRadius: borderRadius,
    );
  }

  Widget _defaultError() {
    return Container(
      width: width,
      height: height,
      color: AppColors.grey100,
      alignment: Alignment.center,
      child: Icon(Icons.image_not_supported_outlined, color: AppColors.grey700),
    );
  }
}
