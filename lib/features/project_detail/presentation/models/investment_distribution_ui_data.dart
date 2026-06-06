import 'package:vestie/features/project_detail/presentation/models/investment_returns_ui_data.dart';

/// One member row on the Distribution breakdown screen (Figma).
class DistributionMemberRowUi {
  final String name;
  final double contributedUsd;
  final double sharePercent;
  final double receivesUsd;

  const DistributionMemberRowUi({
    required this.name,
    required this.contributedUsd,
    required this.sharePercent,
    required this.receivesUsd,
  });

  String get shareLabel => '${sharePercent.toStringAsFixed(1)}%';
}

/// Leader distribution confirmation screen payload (dummy until API).
class InvestmentDistributionUiData {
  final String projectId;
  final String? projectName;
  final double distributeAmountUsd;
  final double remainingUsd;
  final List<DistributionMemberRowUi> members;

  const InvestmentDistributionUiData({
    required this.projectId,
    this.projectName,
    required this.distributeAmountUsd,
    required this.remainingUsd,
    required this.members,
  });

  int get memberCount => members.length;

  static const _previewNames = [
    'John D.',
    'Sarah K.',
    'Mike R.',
    'Emma L.',
    'Chris P.',
    'Anna M.',
    'David T.',
    'Lisa W.',
  ];

  static const _previewContributions = [
    800.0,
    650.0,
    500.0,
    450.0,
    400.0,
    350.0,
    300.0,
    250.0,
  ];

  /// Preview breakdown — proportional to contribution share of [distributeAmountUsd].
  factory InvestmentDistributionUiData.preview({
    required String projectId,
    String? projectName,
    required double distributeAmountUsd,
    double undistributedPoolUsd = 9500,
  }) {
    final totalContributed = _previewContributions.fold<double>(
      0,
      (a, b) => a + b,
    );
    final rows = <DistributionMemberRowUi>[];
    var allocated = 0.0;
    for (var i = 0; i < _previewNames.length; i++) {
      final contributed = _previewContributions[i];
      final share = contributed / totalContributed * 100;
      final receives = i == _previewNames.length - 1
          ? distributeAmountUsd - allocated
          : (distributeAmountUsd * contributed / totalContributed);
      allocated += receives;
      rows.add(
        DistributionMemberRowUi(
          name: _previewNames[i],
          contributedUsd: contributed,
          sharePercent: share,
          receivesUsd: receives,
        ),
      );
    }
    return InvestmentDistributionUiData(
      projectId: projectId,
      projectName: projectName,
      distributeAmountUsd: distributeAmountUsd,
      remainingUsd: undistributedPoolUsd - distributeAmountUsd,
      members: rows,
    );
  }

  String get formattedDistributeAmount =>
      InvestmentReturnsUiData.formatMoney(distributeAmountUsd);

  String get formattedRemaining =>
      InvestmentReturnsUiData.formatMoney(remainingUsd);
}
