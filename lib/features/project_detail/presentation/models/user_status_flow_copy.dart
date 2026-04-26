import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_strings.dart';
import '../../domain/entities/project_detail_route_args.dart';

/// Maps [UserStatusFlowKind] to static copy + art — keeps screens free of
/// per-kind conditionals and avoids depending on a particular cubit.
class UserStatusFlowUiData {
  final String imageAsset;
  final String headline;
  final String body;

  const UserStatusFlowUiData({
    required this.imageAsset,
    required this.headline,
    required this.body,
  });
}

class UserStatusFlowCopy {
  static UserStatusFlowUiData forKind(UserStatusFlowKind kind) {
    switch (kind) {
      case UserStatusFlowKind.joinApproved:
        return const UserStatusFlowUiData(
          imageAsset: AppAssets.markSuccessfullProject,
          headline: AppStrings.userJoinRequestApprovedStatusTitle,
          body: AppStrings.userJoinRequestApprovedStatusBody,
        );
      case UserStatusFlowKind.joinRejected:
        return const UserStatusFlowUiData(
          imageAsset: AppAssets.failureIcon,
          headline: AppStrings.userJoinRequestRejectedStatusTitle,
          body: AppStrings.userJoinRequestRejectedStatusBody,
        );
      case UserStatusFlowKind.markVotedSuccess:
        return const UserStatusFlowUiData(
          imageAsset: AppAssets.markSuccessfullProject,
          headline: AppStrings.markUserVotedSuccessTitle,
          body: AppStrings.markUserVotedSuccessBody,
        );
      case UserStatusFlowKind.markVotedIncomplete:
        return const UserStatusFlowUiData(
          imageAsset: AppAssets.failureIcon,
          headline: AppStrings.markUserVotedIncompleteTitle,
          body: AppStrings.markUserVotedIncompleteBody,
        );
    }
  }
}
