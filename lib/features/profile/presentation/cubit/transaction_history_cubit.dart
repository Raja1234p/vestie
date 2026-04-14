import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_strings.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/mock_profile_data.dart';

class TransactionHistoryState extends Equatable {
  final List<Transaction> all;
  final List<Transaction> filtered;
  final String activeFilter;
  final bool loading;

  const TransactionHistoryState({
    this.all = const [],
    this.filtered = const [],
    this.activeFilter = AppStrings.filterAllTx,
    this.loading = false,
  });

  TransactionHistoryState copyWith({
    List<Transaction>? all,
    List<Transaction>? filtered,
    String? activeFilter,
    bool? loading,
  }) {
    return TransactionHistoryState(
      all: all ?? this.all,
      filtered: filtered ?? this.filtered,
      activeFilter: activeFilter ?? this.activeFilter,
      loading: loading ?? this.loading,
    );
  }

  @override
  List<Object> get props => [all, filtered, activeFilter, loading];
}

class TransactionHistoryCubit extends Cubit<TransactionHistoryState> {
  TransactionHistoryCubit()
      : super(const TransactionHistoryState(loading: true)) {
    _load();
  }

  Future<void> _load() async {
    await Future.delayed(const Duration(milliseconds: 500));
    // TODO: Replace with TransactionRepository.getHistory()
    final list = MockProfileData.transactions;
    emit(TransactionHistoryState(all: list, filtered: list));
  }

  void selectFilter(String filter) {
    final list = state.all;
    List<Transaction> result;
    switch (filter) {
      case AppStrings.filterDeposits:
        result = list.where((t) => t.isDeposit).toList();
        break;
      case AppStrings.filterWithdrawals:
        result = list.where((t) => t.isWithdrawal).toList();
        break;
      case AppStrings.filterContributions:
        result = list.where((t) => t.isContribution).toList();
        break;
      default:
        result = list;
    }
    emit(state.copyWith(activeFilter: filter, filtered: result));
  }
}
