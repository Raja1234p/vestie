import '../../features/bank_accounts/data/datasources/bank_accounts_remote_data_source.dart';
import '../../features/bank_accounts/data/repositories/bank_accounts_repository_impl.dart';
import '../../features/bank_accounts/domain/usecases/bank_accounts_usecases.dart';
import '../../features/kyc/data/datasources/kyc_remote_data_source.dart';
import '../../features/kyc/data/repositories/kyc_repository_impl.dart';
import '../../features/kyc/domain/usecases/kyc_usecases.dart';
import '../../features/payment_methods/data/datasources/payment_methods_remote_data_source.dart';
import '../../features/payment_methods/data/repositories/payment_methods_repository_impl.dart';
import '../../features/payment_methods/domain/usecases/payment_methods_usecases.dart';
import '../../features/stripe/data/datasources/stripe_remote_data_source.dart';
import '../../features/stripe/data/repositories/stripe_repository_impl.dart';
import '../../features/stripe/domain/usecases/get_stripe_config_use_case.dart';
import '../../features/wallet/data/datasources/wallet_deposit_remote_data_source.dart';
import '../../features/wallet/data/datasources/wallet_remote_data_source.dart';
import '../../features/wallet/data/datasources/wallet_withdrawal_remote_data_source.dart';
import '../../features/wallet/data/repositories/wallet_deposit_repository_impl.dart';
import '../../features/wallet/data/repositories/wallet_repository_impl.dart';
import '../../features/wallet/data/repositories/wallet_withdrawal_repository_impl.dart';
import '../../features/wallet/domain/usecases/get_wallet_transactions_use_case.dart';
import '../../features/wallet/domain/usecases/get_wallet_use_case.dart';
import '../../features/wallet/domain/usecases/run_wallet_deposit_use_case.dart';
import '../../features/wallet/domain/usecases/wallet_withdrawal_usecases.dart';
import '../stripe/stripe_payment_service.dart';
import 'service_locator.dart';

/// Registers wallet, Stripe, payment methods, KYC, and bank accounts.
void registerWalletDependencies(ServiceLocator sl) {
  sl.walletRemoteDataSource = WalletRemoteDataSourceImpl(
    apiClient: sl.apiClient,
  );
  sl.walletRepository = WalletRepositoryImpl(
    remoteDataSource: sl.walletRemoteDataSource,
  );
  sl.getWalletUseCase = GetWalletUseCase(sl.walletRepository);
  sl.getWalletTransactionsUseCase = GetWalletTransactionsUseCase(
    sl.walletRepository,
  );

  sl.stripeRemoteDataSource = StripeRemoteDataSourceImpl(
    apiClient: sl.apiClient,
  );
  sl.stripeRepository = StripeRepositoryImpl(
    remoteDataSource: sl.stripeRemoteDataSource,
  );
  sl.getStripeConfigUseCase = GetStripeConfigUseCase(sl.stripeRepository);
  sl.stripePaymentService = StripePaymentService();

  sl.paymentMethodsRemoteDataSource = PaymentMethodsRemoteDataSourceImpl(
    apiClient: sl.apiClient,
  );
  sl.paymentMethodsRepository = PaymentMethodsRepositoryImpl(
    remoteDataSource: sl.paymentMethodsRemoteDataSource,
    getStripeConfigUseCase: sl.getStripeConfigUseCase,
    stripePaymentService: sl.stripePaymentService,
  );
  sl.listPaymentMethodsUseCase = ListPaymentMethodsUseCase(
    sl.paymentMethodsRepository,
  );
  sl.savePaymentCardViaSetupUseCase = SavePaymentCardViaSetupUseCase(
    sl.paymentMethodsRepository,
  );
  sl.getPaymentMethodUseCase = GetPaymentMethodUseCase(
    sl.paymentMethodsRepository,
  );
  sl.setPrimaryPaymentMethodUseCase = SetPrimaryPaymentMethodUseCase(
    sl.paymentMethodsRepository,
  );
  sl.removePaymentMethodUseCase = RemovePaymentMethodUseCase(
    sl.paymentMethodsRepository,
  );

  sl.walletDepositRemoteDataSource = WalletDepositRemoteDataSourceImpl(
    apiClient: sl.apiClient,
  );
  sl.walletDepositRepository = WalletDepositRepositoryImpl(
    remoteDataSource: sl.walletDepositRemoteDataSource,
    walletRepository: sl.walletRepository,
    getStripeConfigUseCase: sl.getStripeConfigUseCase,
    stripePaymentService: sl.stripePaymentService,
  );
  sl.runWalletDepositUseCase = RunWalletDepositUseCase(
    sl.walletDepositRepository,
  );

  sl.kycRemoteDataSource = KycRemoteDataSourceImpl(apiClient: sl.apiClient);
  sl.kycRepository = KycRepositoryImpl(
    remoteDataSource: sl.kycRemoteDataSource,
  );
  sl.getKycStatusUseCase = GetKycStatusUseCase(sl.kycRepository);
  sl.startKycUseCase = StartKycUseCase(sl.kycRepository);

  sl.bankAccountsRemoteDataSource = BankAccountsRemoteDataSourceImpl(
    apiClient: sl.apiClient,
  );
  sl.bankAccountsRepository = BankAccountsRepositoryImpl(
    remoteDataSource: sl.bankAccountsRemoteDataSource,
  );
  sl.listBankAccountsUseCase = ListBankAccountsUseCase(
    sl.bankAccountsRepository,
  );
  sl.linkBankAccountUseCase = LinkBankAccountUseCase(sl.bankAccountsRepository);

  sl.walletWithdrawalRemoteDataSource = WalletWithdrawalRemoteDataSourceImpl(
    apiClient: sl.apiClient,
  );
  sl.walletWithdrawalRepository = WalletWithdrawalRepositoryImpl(
    remoteDataSource: sl.walletWithdrawalRemoteDataSource,
    walletRepository: sl.walletRepository,
  );
  sl.previewWithdrawalUseCase = PreviewWithdrawalUseCase(
    sl.walletWithdrawalRepository,
  );
  sl.runWalletWithdrawUseCase = RunWalletWithdrawUseCase(
    sl.walletWithdrawalRepository,
  );
}
