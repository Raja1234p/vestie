import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:vestie/core/constants/app_assets.dart';
import 'package:vestie/leader/features/create_project/presentation/create_project_image_tile_style.dart';

/// Figma upload step illustration — 298×308 on transparent asset.
class CreateProjectUploadIllustration extends StatelessWidget {
  const CreateProjectUploadIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      AppAssets.createProjectUploadEmptyState,
      width: CreateProjectImageTileStyle.uploadIllustrationWidth.w,
      height: CreateProjectImageTileStyle.uploadIllustrationHeight.h,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
    );
  }
}
