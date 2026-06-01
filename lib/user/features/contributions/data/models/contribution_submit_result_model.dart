import 'package:vestie/core/utils/safe_parser.dart';

class ContributionSubmitResultModel {
  final double walletAvailableBalance;
  final double projectPot;
  final List<String> vffMemberUserIds;

  const ContributionSubmitResultModel({
    required this.walletAvailableBalance,
    required this.projectPot,
    this.vffMemberUserIds = const [],
  });

  factory ContributionSubmitResultModel.fromJson(Map<String, dynamic> json) {
    final vff = (json['vffMemberUserIds'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList(growable: false) ??
        const <String>[];

    return ContributionSubmitResultModel(
      walletAvailableBalance: json.safeDouble('walletAvailableBalance'),
      projectPot: json.safeDouble('projectPot'),
      vffMemberUserIds: vff,
    );
  }
}
