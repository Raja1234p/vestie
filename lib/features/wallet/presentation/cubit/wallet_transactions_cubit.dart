import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:vestie/core/error/failure_mapper.dart';
import 'package:vestie/core/models/pagination_dto.dart';
import 'package:vestie/features/profile/domain/entities/transaction.dart';
import 'package:vestie/features/wallet/domain/entities/wallet_entity.dart';
import 'package:vestie/features/wallet/domain/usecases/get_wallet_transactions_use_case.dart';

class WalletTransactionsState extends Equatable {
  final List<Transaction> items;
  final bool loading;
  final bool loadingMore;
  final int currentPage;
  final int totalCount;
  final String? errorMessage;

  const WalletTransactionsState({
    this.items = const [],
    this.loading = false,
    this.loadingMore = false,
    this.currentPage = 0,
    this.totalCount = 0,
    this.errorMessage,
  });

  bool get hasLoadError => errorMessage != null && items.isEmpty && !loading;

  bool get hasMore => items.length < totalCount;

  WalletTransactionsState copyWith({
    List<Transaction>? items,
    bool? loading,
    bool? loadingMore,
    int? currentPage,
    int? totalCount,
    String? errorMessage,
    bool clearError = false,
  }) {
    return WalletTransactionsState(
      items: items ?? this.items,
      loading: loading ?? this.loading,
      loadingMore: loadingMore ?? this.loadingMore,
      currentPage: currentPage ?? this.currentPage,
      totalCount: totalCount ?? this.totalCount,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
    items,
    loading,
    loadingMore,
    currentPage,
    totalCount,
    errorMessage,
  ];
}

class WalletTransactionsCubit extends Cubit<WalletTransactionsState> {
  static const int _pageSize = PaginationQuery.defaultPageSize;

  final GetWalletTransactionsUseCase _getWalletTransactionsUseCase;

  WalletTransactionsCubit({
    required GetWalletTransactionsUseCase getWalletTransactionsUseCase,
  }) : _getWalletTransactionsUseCase = getWalletTransactionsUseCase,
       super(const WalletTransactionsState(loading: true));

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
        WalletTransactionsState(
          loading: false,
          errorMessage: FailureMapper.userMessage(failure),
        ),
      ),
      (page) => emit(
        WalletTransactionsState(
          items: _mapTransactions(page.items),
          loading: false,
          currentPage: page.page,
          totalCount: page.totalCount,
        ),
      ),
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
      (page) => emit(
        state.copyWith(
          items: [...state.items, ..._mapTransactions(page.items)],
          currentPage: page.page,
          totalCount: page.totalCount,
          loadingMore: false,
          clearError: true,
        ),
      ),
    );
  }

  List<Transaction> _mapTransactions(List<WalletRecentTransactionEntity> raw) {
    if (raw.isEmpty) return const [];
    final dateFmt = DateFormat('MMM d');
    return raw
        .map((t) {
          final signed = t.isDebit ? -t.amount.abs() : t.amount.abs();
          return Transaction(
            id: t.id,
            title: t.title,
            date: t.dateUtc != null ? dateFmt.format(t.dateUtc!.toLocal()) : '',
            amount: signed,
            type: _mapType(t.type),
          );
        })
        .toList(growable: false);
  }

  TransactionType _mapType(String apiType) {
    switch (apiType.toLowerCase()) {
      case 'withdrawal':
        return TransactionType.withdrawal;
      case 'contribution':
        return TransactionType.contribution;
      case 'deposit':
        return TransactionType.deposit;
      case 'repayment':
        return TransactionType.repayment;
      case 'fee':
        return TransactionType.fee;
      case 'borrow':
        return TransactionType.borrow;
      default:
        return TransactionType.deposit;
    }
  }
}
