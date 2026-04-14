import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/models/onboarding_page_model.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_strings.dart';

/// State: current page index (0-based)
class OnboardingCubit extends Cubit<int> {
  OnboardingCubit() : super(0);

  static const List<OnboardingPageModel> pages = [
    OnboardingPageModel(
      title: AppStrings.onboarding1Title,
      subtitle: AppStrings.onboarding1Subtitle,
      imagePath: AppAssets.onboarding1,
    ),
    OnboardingPageModel(
      title: AppStrings.onboarding2Title,
      subtitle: AppStrings.onboarding2Subtitle,
      imagePath: AppAssets.onboarding2,
    ),
    OnboardingPageModel(
      title: AppStrings.onboarding3Title,
      subtitle: AppStrings.onboarding3Subtitle,
      imagePath: AppAssets.onboarding3,
    ),
  ];

  bool get isLastPage => state == pages.length - 1;
  int get pageCount => pages.length;
  OnboardingPageModel get currentPage => pages[state];

  void goToPage(int index) {
    if (index >= 0 && index < pages.length) emit(index);
  }

  void nextPage() {
    if (!isLastPage) emit(state + 1);
  }

  void skip() => emit(pages.length - 1);
}
