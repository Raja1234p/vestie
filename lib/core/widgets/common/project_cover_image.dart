import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:vestie/core/widgets/common/app_network_image.dart';
import 'package:vestie/user/features/home/domain/entities/project.dart';
import 'package:vestie/user/features/home/domain/entities/project_category_extensions.dart';

/// Project cover from API, falling back to the category card illustration.
///
/// Network covers use [BoxFit.cover] to fill the slot; category fallbacks keep
/// [BoxFit.contain] to match the original card illustrations.
class ProjectCoverImage extends StatelessWidget {
  final String? coverImageUrl;
  final ProjectCategory category;
  final double? width;
  final double? height;
  final VoidCallback? onTap;

  const ProjectCoverImage({
    super.key,
    required this.coverImageUrl,
    required this.category,
    this.width,
    this.height,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final child = _buildImage(context);
    if (onTap == null) return child;
    return GestureDetector(onTap: onTap, child: child);
  }

  Widget _buildImage(BuildContext context) {
    if (!AppNetworkImage.isValidNetworkUrl(coverImageUrl)) {
      return _categoryAsset(context);
    }

    return SizedBox(
      width: width,
      height: height,
      child: AppNetworkImage(
        imageUrl: coverImageUrl,
        width: width,
        height: height,
        fit: BoxFit.cover,
        borderRadius: BorderRadius.circular(10.r),
        errorWidget: _categoryAsset(context),
      ),
    );
  }

  Widget _categoryAsset(BuildContext context) {
    final devicePixelRatio = MediaQuery.devicePixelRatioOf(context);
    return Image.asset(
      category.cardImageAsset,
      width: width,
      height: height,
      fit: BoxFit.contain,
      cacheWidth: width != null ? (width! * devicePixelRatio).round() : null,
      cacheHeight: height != null ? (height! * devicePixelRatio).round() : null,
    );
  }
}
