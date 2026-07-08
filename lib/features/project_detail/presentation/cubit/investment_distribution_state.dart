import 'package:equatable/equatable.dart';

import 'package:vestie/core/error/failures.dart';
import 'package:vestie/features/project_detail/presentation/models/investment_distribution_ui_data.dart';

enum InvestmentDistributionLoadStatus { initial, loading, loaded, loadFailed }

class InvestmentDistributionState extends Equatable {
  final InvestmentDistributionLoadStatus loadStatus;
  final InvestmentDistributionUiData? data;
  final bool isSubmitting;
  final String? loadErrorMessage;
  final Failure? submitFailure;

  const InvestmentDistributionState({
    this.loadStatus = InvestmentDistributionLoadStatus.initial,
    this.data,
    this.isSubmitting = false,
    this.loadErrorMessage,
    this.submitFailure,
  });

  bool get isLoading =>
      loadStatus == InvestmentDistributionLoadStatus.initial ||
      loadStatus == InvestmentDistributionLoadStatus.loading;

  bool get loadFailed =>
      loadStatus == InvestmentDistributionLoadStatus.loadFailed;

  InvestmentDistributionState copyWith({
    InvestmentDistributionLoadStatus? loadStatus,
    InvestmentDistributionUiData? data,
    bool? isSubmitting,
    String? loadErrorMessage,
    bool clearLoadError = false,
    Failure? submitFailure,
    bool clearSubmitFailure = false,
  }) {
    return InvestmentDistributionState(
      loadStatus: loadStatus ?? this.loadStatus,
      data: data ?? this.data,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      loadErrorMessage: clearLoadError
          ? null
          : (loadErrorMessage ?? this.loadErrorMessage),
      submitFailure: clearSubmitFailure
          ? null
          : (submitFailure ?? this.submitFailure),
    );
  }

  @override
  List<Object?> get props => [
    loadStatus,
    data,
    isSubmitting,
    loadErrorMessage,
    submitFailure,
  ];
}
