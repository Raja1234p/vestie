import 'package:equatable/equatable.dart';

import 'package:vestie/features/project_detail/presentation/models/investment_returns_ui_data.dart';

enum InvestmentReturnsLoadStatus { initial, loading, loaded, loadFailed }

class InvestmentReturnsState extends Equatable {
  final InvestmentReturnsLoadStatus loadStatus;
  final InvestmentReturnsUiData? data;
  final String? loadErrorMessage;
  final bool distributionsLoadingMore;
  final int distributionsCurrentPage;
  final int distributionsTotalCount;

  const InvestmentReturnsState({
    this.loadStatus = InvestmentReturnsLoadStatus.initial,
    this.data,
    this.loadErrorMessage,
    this.distributionsLoadingMore = false,
    this.distributionsCurrentPage = 0,
    this.distributionsTotalCount = 0,
  });

  bool get isLoading =>
      loadStatus == InvestmentReturnsLoadStatus.initial ||
      loadStatus == InvestmentReturnsLoadStatus.loading;

  bool get loadFailed => loadStatus == InvestmentReturnsLoadStatus.loadFailed;

  bool get distributionsHasMore =>
      (data?.distributions.length ?? 0) < distributionsTotalCount;

  InvestmentReturnsState copyWith({
    InvestmentReturnsLoadStatus? loadStatus,
    InvestmentReturnsUiData? data,
    String? loadErrorMessage,
    bool? distributionsLoadingMore,
    int? distributionsCurrentPage,
    int? distributionsTotalCount,
    bool clearLoadError = false,
  }) {
    return InvestmentReturnsState(
      loadStatus: loadStatus ?? this.loadStatus,
      data: data ?? this.data,
      loadErrorMessage: clearLoadError
          ? null
          : (loadErrorMessage ?? this.loadErrorMessage),
      distributionsLoadingMore:
          distributionsLoadingMore ?? this.distributionsLoadingMore,
      distributionsCurrentPage:
          distributionsCurrentPage ?? this.distributionsCurrentPage,
      distributionsTotalCount:
          distributionsTotalCount ?? this.distributionsTotalCount,
    );
  }

  @override
  List<Object?> get props => [
    loadStatus,
    data,
    loadErrorMessage,
    distributionsLoadingMore,
    distributionsCurrentPage,
    distributionsTotalCount,
  ];
}
