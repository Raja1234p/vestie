import '../../features/profile/data/datasources/account_remote_data_source.dart';
import '../../features/profile/data/datasources/user_guidelines_remote_data_source.dart';
import '../../features/profile/data/repositories/account_repository_impl.dart';
import '../../features/profile/data/repositories/user_guidelines_repository_impl.dart';
import '../../features/profile/domain/usecases/check_account_deletion_eligibility_use_case.dart';
import '../../features/profile/domain/usecases/delete_account_use_case.dart';
import '../../features/profile/domain/usecases/get_user_guidelines_use_case.dart';
import 'service_locator.dart';

/// Profile content APIs (user guidelines, account deletion, etc.).
void registerProfileDependencies(ServiceLocator sl) {
  sl.userGuidelinesRemoteDataSource = UserGuidelinesRemoteDataSourceImpl(
    apiClient: sl.apiClient,
  );
  sl.userGuidelinesRepository = UserGuidelinesRepositoryImpl(
    remoteDataSource: sl.userGuidelinesRemoteDataSource,
  );
  sl.getUserGuidelinesUseCase = GetUserGuidelinesUseCase(
    sl.userGuidelinesRepository,
  );

  sl.accountRemoteDataSource = AccountRemoteDataSourceImpl(
    apiClient: sl.apiClient,
  );
  sl.accountRepository = AccountRepositoryImpl(
    remoteDataSource: sl.accountRemoteDataSource,
  );
  sl.checkAccountDeletionEligibilityUseCase =
      CheckAccountDeletionEligibilityUseCase(sl.accountRepository);
  sl.deleteAccountUseCase = DeleteAccountUseCase(sl.accountRepository);
}
