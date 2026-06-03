import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vestie/core/error/failure_mapper.dart';
import 'package:vestie/features/bank_accounts/domain/entities/bank_account_entity.dart';
import 'package:vestie/features/bank_accounts/domain/usecases/bank_accounts_usecases.dart';

class BankAccountsState extends Equatable {
  final List<BankAccountEntity> accounts;
  final bool loading;
  final bool linking;
  final String? settingDefaultAccountId;
  final String? removingAccountId;
  final String? errorMessage;

  const BankAccountsState({
    this.accounts = const [],
    this.loading = false,
    this.linking = false,
    this.settingDefaultAccountId,
    this.removingAccountId,
    this.errorMessage,
  });

  BankAccountsState copyWith({
    List<BankAccountEntity>? accounts,
    bool? loading,
    bool? linking,
    String? settingDefaultAccountId,
    bool clearSettingDefault = false,
    String? removingAccountId,
    bool clearRemovingAccount = false,
    String? errorMessage,
    bool clearError = false,
  }) =>
      BankAccountsState(
        accounts: accounts ?? this.accounts,
        loading: loading ?? this.loading,
        linking: linking ?? this.linking,
        settingDefaultAccountId: clearSettingDefault
            ? null
            : (settingDefaultAccountId ?? this.settingDefaultAccountId),
        removingAccountId: clearRemovingAccount
            ? null
            : (removingAccountId ?? this.removingAccountId),
        errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      );

  @override
  List<Object?> get props => [
        accounts,
        loading,
        linking,
        settingDefaultAccountId,
        removingAccountId,
        errorMessage,
      ];
}

class BankAccountsCubit extends Cubit<BankAccountsState> {
  final ListBankAccountsUseCase listBankAccountsUseCase;
  final SetDefaultBankAccountUseCase setDefaultBankAccountUseCase;
  final RemoveBankAccountUseCase removeBankAccountUseCase;

  BankAccountsCubit({
    required this.listBankAccountsUseCase,
    required this.setDefaultBankAccountUseCase,
    required this.removeBankAccountUseCase,
  }) : super(const BankAccountsState(loading: true)) {
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
      (accounts) =>
          emit(BankAccountsState(accounts: accounts, loading: false)),
    );
  }

  void setLinking(bool linking) =>
      emit(state.copyWith(linking: linking, clearError: true));

  Future<String?> setDefault(String id, {required bool isDefault}) async {
    emit(state.copyWith(settingDefaultAccountId: id, clearError: true));
    final result = await setDefaultBankAccountUseCase(
      id,
      isDefault: isDefault,
    );
    return result.fold(
      (failure) {
        emit(state.copyWith(clearSettingDefault: true));
        return FailureMapper.userMessage(failure);
      },
      (_) {
        emit(
          state.copyWith(
            accounts: [
              for (final account in state.accounts)
                BankAccountEntity(
                  id: account.id,
                  bankName: account.bankName,
                  last4: account.last4,
                  currency: account.currency,
                  displayName: account.displayName,
                  isDefault: isDefault
                      ? account.id == id
                      : (account.id == id ? false : account.isDefault),
                ),
            ],
            clearSettingDefault: true,
            clearError: true,
          ),
        );
        return null;
      },
    );
  }

  Future<String?> remove(String id) async {
    emit(state.copyWith(removingAccountId: id, clearError: true));
    final result = await removeBankAccountUseCase(id);
    return result.fold(
      (failure) {
        emit(state.copyWith(clearRemovingAccount: true));
        return FailureMapper.userMessage(failure);
      },
      (_) {
        emit(
          state.copyWith(
            accounts: state.accounts.where((a) => a.id != id).toList(),
            clearRemovingAccount: true,
            clearError: true,
          ),
        );
        return null;
      },
    );
  }
}
