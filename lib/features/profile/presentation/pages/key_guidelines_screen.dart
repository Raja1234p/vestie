import 'package:flutter/material.dart';
import 'package:vestie/core/constants/app_dimens.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/widgets/common/flow_screen_footer.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/common/app_purple_dashed_line.dart';
import 'package:vestie/core/widgets/common/post_auth_gradient_background.dart';
import 'package:vestie/features/profile/domain/entities/user_guideline.dart';
import 'package:vestie/features/profile/presentation/widgets/profile_sub_header.dart';
import 'package:vestie/features/profile/presentation/widgets/user_guideline_section.dart';

/// Profile → Vestie User Guidelines (Figma).
class KeyGuidelinesScreen extends StatelessWidget {
  const KeyGuidelinesScreen({super.key});

  static const List<UserGuideline> _items = [
    UserGuideline(
      title: AppStrings.guidelineYourRiskTitle,
      description: AppStrings.guidelineYourRiskBody,
    ),
    UserGuideline(
      title: AppStrings.guidelineNoGuaranteesTitle,
      description: AppStrings.guidelineNoGuaranteesBody,
    ),
    UserGuideline(
      title: AppStrings.guidelineKnowYourGroupTitle,
      description: AppStrings.guidelineKnowYourGroupBody,
    ),
    UserGuideline(
      title: AppStrings.guidelineBorrowingTermsTitle,
      description: AppStrings.guidelineBorrowingTermsBody,
    ),
    UserGuideline(
      title: AppStrings.guidelineDisputesTitle,
      description: AppStrings.guidelineDisputesBody,
    ),
    UserGuideline(
      title: AppStrings.guidelineFinalContributionsTitle,
      description: AppStrings.guidelineFinalContributionsBody,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: false,
      body: PostAuthGradientBackground(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ProfileSubHeader(title: AppStrings.menuKeyGuidelines),
            Expanded(
              child: ListView.separated(
                padding: FlowScreenFooterInsets.listPadding(
                  context,
                  top: AppDimens.v4,
                ),
                itemCount: _items.length,
                separatorBuilder: (context, index) => const AppPurpleDashedLine(
                  color: AppColors.purple300,
                  height: 1,
                ),
                itemBuilder: (context, index) =>
                    UserGuidelineSection(item: _items[index]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
