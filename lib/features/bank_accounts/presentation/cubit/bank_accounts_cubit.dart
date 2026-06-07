import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vestie/core/error/failure_mapper.dart';
import 'package:vestie/features/bank_accounts/domain/entities/bank_account_entity.dart';
import 'package:vestie/features/bank_accounts/domain/usecases/bank_accounts_usecases.dart';

class BankAccountsState extends Equatable {
  final List<BankAccountEntity> accounts;
  final bool loading;
  final bool linking;
  final String? errorMessage;

  const BankAccountsState({
    this.accounts = const [],
    this.loading = false,
    this.linking = false,
    this.errorMessage,
  });

  BankAccountsState copyWith({
    List<BankAccountEntity>? accounts,
    bool? loading,
    bool? linking,
    String? errorMessage,
    bool clearError = false,
  }) => BankAccountsState(
    accounts: accounts ?? this.accounts,
    loading: loading ?? this.loading,
    linking: linking ?? this.linking,
    errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
  );

  @override
  List<Object?> get props => [accounts, loading, linking, errorMessage];
}

class BankAccountsCubit extends Cubit<BankAccountsState> {
  final ListBankAccountsUseCase listBankAccountsUseCase;

  BankAccountsCubit({required this.listBankAccountsUseCase})
    : super(const BankAccountsState(loading: true)) {
    load();
  }

  Future<void> load({bool forceRefresh = false}) async {
    emit(state.copyWith(loading: true, clearError: true));
    final result = await listBankAccountsUseCase(forceRefresh: forceRefresh);
    result.fold(
      (failure) => emit(
        BankAccountsState(
          loading: false,
          errorMessage: FailureMapper.userMessage(failure),
        ),
      ),
      (accounts) => emit(BankAccountsState(accounts: accounts, loading: false)),
    );
  }

  void setLinking(bool linking) =>
      emit(state.copyWith(linking: linking, clearError: true));
}
