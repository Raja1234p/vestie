import 'package:flutter/material.dart';

import 'package:vestie/core/constants/app_assets.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/common/flow_hero_image_card.dart';

class StopContributionsHeroCard extends StatelessWidget {
  const StopContributionsHeroCard({super.key});

  @override
  Widget build(BuildContext context) {
    return FlowHeroImageCard(
      imageAsset: AppAssets.successProjectCreated,
      backgroundColor: AppColors.purple100,
      caption: AppStrings.menuStopContributions,
      captionColor: AppColors.grey900,
      imageHeight: 200,
    );
  }
}
