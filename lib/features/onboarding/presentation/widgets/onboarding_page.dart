import 'package:flutter/material.dart';
import '../../domain/models/onboarding_page_model.dart';

/// Single onboarding page — contains ONLY the phone mockup image.
/// Title + subtitle have been lifted to OnboardingScreen for stable layout.
/// Image is contained with horizontal padding and a bottom gap so it
/// never touches the Continue button below.
class OnboardingPage extends StatelessWidget {
  final OnboardingPageModel model;

  const OnboardingPage({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Image.asset(
        model.imagePath,
        fit: BoxFit.contain,
        alignment: Alignment.center,
      ),
    );
  }
}
