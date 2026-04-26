import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/common/flow_hero_image_card.dart';

class MarkSuccessfulHeroCard extends StatelessWidget {
  const MarkSuccessfulHeroCard({super.key});

  @override
  Widget build(BuildContext context) {
    return FlowHeroImageCard(
      imageAsset: AppAssets.markSuccessfullProject,
      backgroundColor: AppColors.green100,
      caption: AppStrings.menuMarkSuccessful,
      captionColor: AppColors.green1000,
      imageHeight: 200,
    );
  }
}
