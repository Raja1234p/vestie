import '../../../home/domain/entities/project.dart';
import '../../../home/domain/entities/project_category_extensions.dart';
import '../../../../core/constants/app_strings.dart';

/// Resolves [title] / [body] for the “no more activity” callout on completed
/// projects. Keeps copy out of layout widgets to avoid tight coupling to screens.
class CompletedProjectNoticeCopy {
  final String title;
  final String body;

  const CompletedProjectNoticeCopy({
    required this.title,
    required this.body,
  });

  /// Investment vs pooled funds use different copy (see [AppStrings]).
  static CompletedProjectNoticeCopy forCategory(ProjectCategory category) {
    if (category.isInvestment) {
      return const CompletedProjectNoticeCopy(
        title: AppStrings.noMoreContributionTitle,
        body: AppStrings.noMoreContributionBody,
      );
    }
    return const CompletedProjectNoticeCopy(
      title: AppStrings.projectCompletedUserTitle,
      body: AppStrings.projectCompletedUserBody,
    );
  }
}
