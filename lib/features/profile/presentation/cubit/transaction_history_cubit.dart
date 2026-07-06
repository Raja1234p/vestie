import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/error/failure_mapper.dart';
import 'package:vestie/core/models/pagination_dto.dart';
import 'package:vestie/features/profile/domain/entities/transaction.dart';
import 'package:vestie/features/profile/presentation/utils/transaction_history_filter.dart';
import 'package:vestie/features/wallet/domain/usecases/get_wallet_transactions_use_case.dart';
import 'package:vestie/features/wallet/presentation/mappers/wallet_transaction_ui_mapper.dart';

class TransactionHistoryState extends Equatable {
  final List<Transaction> all;
  final List<Transaction> filtered;
  final String activeFilter;
  final bool loading;
  final bool loadingMore;
  final int currentPage;
  final int totalCount;
  final String? errorMessage;

  const TransactionHistoryState({
    this.all = const [],
    this.filtered = const [],
    this.activeFilter = AppStrings.filterAllTx,
    this.loading = false,
    this.loadingMore = false,
    this.currentPage = 0,
    this.totalCount = 0,
    this.errorMessage,
  });

  bool get hasLoadError => errorMessage != null && all.isEmpty && !loading;

  bool get hasMore => all.length < totalCount;

  bool get isFilterEmpty => all.isNotEmpty && filtered.isEmpty;

  TransactionHistoryState copyWith({
    List<Transaction>? all,
    List<Transaction>? filtered,
    String? activeFilter,
    bool? loading,
    bool? loadingMore,
    int? currentPage,
    int? totalCount,
    String? errorMessage,
    bool clearError = false,
  }) {
    return TransactionHistoryState(
      all: all ?? this.all,
      filtered: filtered ?? this.filtered,
      activeFilter: activeFilter ?? this.activeFilter,
      loading: loading ?? this.loading,
      loadingMore: loadingMore ?? this.loadingMore,
      currentPage: currentPage ?? this.currentPage,
      totalCount: totalCount ?? this.totalCount,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
    all,
    filtered,
    activeFilter,
    loading,
    loadingMore,
    currentPage,
    totalCount,
    errorMessage,
  ];
}

class TransactionHistoryCubit extends Cubit<TransactionHistoryState> {
  static const int _pageSize = PaginationQuery.defaultPageSize;

  final GetWalletTransactionsUseCase _getWalletTransactionsUseCase;

  TransactionHistoryCubit({
    required GetWalletTransactionsUseCase getWalletTransactionsUseCase,
  }) : _getWalletTransactionsUseCase = getWalletTransactionsUseCase,
       super(const TransactionHistoryState(loading: true));

  Future<void> load() async {
    emit(
      state.copyWith(
        loading: true,
        loadingMore: false,
        clearError: true,
      ),
    );

    final result = await _getWalletTransactionsUseCase(
      page: 1,
      pageSize: _pageSize,
    );

    result.fold(
      (failure) => emit(
        TransactionHistoryState(
          loading: false,
          errorMessage: FailureMapper.userMessage(failure),
        ),
      ),
      (page) {
        final all = WalletTransactionUiMapper.toTransactions(page.items);
        emit(
          TransactionHistoryState(
            all: all,
            filtered: TransactionHistoryFilter.apply(all, state.activeFilter),
            activeFilter: state.activeFilter,
            loading: false,
            currentPage: page.page,
            totalCount: page.totalCount,
          ),
        );
      },
    );
  }

  Future<void> loadMore() async {
    if (state.loading || state.loadingMore || !state.hasMore) return;

    emit(state.copyWith(loadingMore: true, clearError: true));
    final nextPage = state.currentPage + 1;
    final result = await _getWalletTransactionsUseCase(
      page: nextPage,
      pageSize: _pageSize,
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          loadingMore: false,
          errorMessage: FailureMapper.userMessage(failure),
        ),
      ),
      (page) {
        final all = [
          ...state.all,
          ...WalletTransactionUiMapper.toTransactions(page.items),
        ];
        emit(
          state.copyWith(
            all: all,
            filtered: TransactionHistoryFilter.apply(all, state.activeFilter),
            currentPage: page.page,
            totalCount: page.totalCount,
            loadingMore: false,
            clearError: true,
          ),
        );
      },
    );
  }

  void selectFilter(String filter) {
    emit(
      state.copyWith(
        activeFilter: filter,
        filtered: TransactionHistoryFilter.apply(state.all, filter),
      ),
    );
  }
}
