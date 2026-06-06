import 'package:vestie/user/features/borrow/data/datasources/borrow_remote_data_source_impl.dart';
import 'package:vestie/user/features/borrow/data/repositories/borrow_repository_impl.dart';
import 'package:vestie/user/features/borrow/domain/usecases/approve_borrow_request_use_case.dart';
import 'package:vestie/user/features/borrow/domain/usecases/create_borrow_request_use_case.dart';
import 'package:vestie/user/features/borrow/domain/usecases/reject_borrow_request_use_case.dart';
import 'package:vestie/user/features/contributions/data/datasources/contribution_remote_data_source.dart';
import 'package:vestie/user/features/contributions/data/repositories/contribution_repository_impl.dart';
import 'package:vestie/user/features/contributions/domain/usecases/confirm_contribution_usecase.dart';
import 'package:vestie/user/features/contributions/domain/usecases/fetch_contribution_config_usecase.dart';
import 'package:vestie/user/features/contributions/domain/usecases/preview_contribution_usecase.dart';
import 'package:vestie/user/features/home/data/datasources/user_me_summary_remote_data_source.dart';
import 'package:vestie/user/features/home/data/repositories/user_me_summary_repository_impl.dart';
import 'package:vestie/user/features/home/domain/usecases/get_user_me_summary_use_case.dart';
import 'package:vestie/user/features/vff/data/datasources/vff_remote_data_source.dart';
import 'package:vestie/user/features/vff/data/repositories/vff_repository_impl.dart';
import 'package:vestie/user/features/vff/domain/usecases/vff_usecases.dart';
import 'service_locator.dart';

/// Registers member flows: contributions, borrow, VFF, home summary.
void registerUserFeatureDependencies(ServiceLocator sl) {
  sl.contributionRemoteDataSource = ContributionRemoteDataSourceImpl(
    apiClient: sl.apiClient,
  );
  sl.contributionRepository = ContributionRepositoryImpl(
    remoteDataSource: sl.contributionRemoteDataSource,
    walletRepository: sl.walletRepository,
  );
  sl.fetchContributionConfigUseCase = FetchContributionConfigUseCase(
    sl.contributionRepository,
  );
  sl.previewContributionUseCase = PreviewContributionUseCase(
    sl.contributionRepository,
  );
  sl.confirmContributionUseCase = ConfirmContributionUseCase(
    sl.contributionRepository,
  );

  sl.borrowRemoteDataSource = BorrowRemoteDataSourceImpl(sl.dioClient);
  sl.borrowRepository = BorrowRepositoryImpl(sl.borrowRemoteDataSource);
  sl.createBorrowRequestUseCase = CreateBorrowRequestUseCase(
    sl.borrowRepository,
  );
  sl.approveBorrowRequestUseCase = ApproveBorrowRequestUseCase(
    sl.borrowRepository,
  );
  sl.rejectBorrowRequestUseCase = RejectBorrowRequestUseCase(
    sl.borrowRepository,
  );

  sl.vffRemoteDataSource = VffRemoteDataSourceImpl(apiClient: sl.apiClient);
  sl.vffRepository = VffRepositoryImpl(
    remoteDataSource: sl.vffRemoteDataSource,
  );
  sl.listMyVffsUseCase = ListMyVffsUseCase(sl.vffRepository);
  sl.getConnectedVffProfileUseCase = GetConnectedVffProfileUseCase(
    sl.vffRepository,
  );
  sl.getPublicVffProfileUseCase = GetPublicVffProfileUseCase(sl.vffRepository);
  sl.removeVffConnectionUseCase = RemoveVffConnectionUseCase(sl.vffRepository);
  sl.getVffReceivedInboxUseCase = GetVffReceivedInboxUseCase(sl.vffRepository);
  sl.getVffSentInboxUseCase = GetVffSentInboxUseCase(sl.vffRepository);
  sl.sendVffRequestUseCase = SendVffRequestUseCase(sl.vffRepository);
  sl.acceptVffRequestUseCase = AcceptVffRequestUseCase(sl.vffRepository);
  sl.declineVffRequestUseCase = DeclineVffRequestUseCase(sl.vffRepository);
  sl.inviteVffsToProjectUseCase = InviteVffsToProjectUseCase(sl.vffRepository);
  sl.acceptVffProjectInviteUseCase = AcceptVffProjectInviteUseCase(
    sl.vffRepository,
  );
  sl.declineVffProjectInviteUseCase = DeclineVffProjectInviteUseCase(
    sl.vffRepository,
  );
  sl.joinFromVffProfileUseCase = JoinFromVffProfileUseCase(sl.vffRepository);

  sl.userMeSummaryRemoteDataSource = UserMeSummaryRemoteDataSourceImpl(
    apiClient: sl.apiClient,
  );
  sl.userMeSummaryRepository = UserMeSummaryRepositoryImpl(
    remoteDataSource: sl.userMeSummaryRemoteDataSource,
  );
  sl.getUserMeSummaryUseCase = GetUserMeSummaryUseCase(
    sl.userMeSummaryRepository,
  );
}
