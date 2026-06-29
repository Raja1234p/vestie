import 'package:equatable/equatable.dart';

import 'package:vestie/features/project_detail/presentation/models/investment_returns_ui_data.dart';

enum InvestmentReturnsLoadStatus { initial, loading, loaded, loadFailed }

class InvestmentReturnsState extends Equatable {
  final InvestmentReturnsLoadStatus loadStatus;
  final InvestmentReturnsUiData? data;
  final String? loadErrorMessage;

  const InvestmentReturnsState({
    this.loadStatus = InvestmentReturnsLoadStatus.initial,
    this.data,
    this.loadErrorMessage,
  });

  bool get isLoading => loadStatus == InvestmentReturnsLoadStatus.loading;

  bool get loadFailed => loadStatus == InvestmentReturnsLoadStatus.loadFailed;

  InvestmentReturnsState copyWith({
    InvestmentReturnsLoadStatus? loadStatus,
    InvestmentReturnsUiData? data,
    String? loadErrorMessage,
    bool clearLoadError = false,
  }) {
    return InvestmentReturnsState(
      loadStatus: loadStatus ?? this.loadStatus,
      data: data ?? this.data,
      loadErrorMessage: clearLoadError
          ? null
          : (loadErrorMessage ?? this.loadErrorMessage),
    );
  }

  @override
  List<Object?> get props => [loadStatus, data, loadErrorMessage];
}
