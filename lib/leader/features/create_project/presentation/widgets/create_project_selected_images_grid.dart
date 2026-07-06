import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:vestie/leader/features/create_project/domain/create_project_image_limits.dart';
import 'package:vestie/leader/features/create_project/presentation/create_project_image_tile_style.dart';
import 'package:vestie/leader/features/create_project/presentation/widgets/create_project_image_tiles.dart';

/// Three-column grid of selected images + optional upload tile (max 5).
class CreateProjectSelectedImagesGrid extends StatelessWidget {
  const CreateProjectSelectedImagesGrid({
    super.key,
    required this.imagePaths,
    required this.onRemoveAt,
    required this.onUploadTap,
  });

  final List<String> imagePaths;
  final void Function(int index) onRemoveAt;
  final VoidCallback onUploadTap;

  @override
  Widget build(BuildContext context) {
    final canAddMore = imagePaths.length < CreateProjectImageLimits.maxImages;
    final itemCount = imagePaths.length + (canAddMore ? 1 : 0);
    final spacing = CreateProjectImageTileStyle.gridSpacing.w;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: CreateProjectImageTileStyle.gridColumnCount,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
        childAspectRatio: 1,
      ),
      itemBuilder: (context, index) {
        if (index < imagePaths.length) {
          return CreateProjectImageTile(
            imagePath: imagePaths[index],
            onRemove: () => onRemoveAt(index),
          );
        }
        return CreateProjectUploadImageTile(onTap: onUploadTap);
      },
    );
  }
}
