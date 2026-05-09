import 'package:flutter/material.dart';

import 'package:vestie/core/constants/app_assets.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/common/flow_hero_image_card.dart';

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
