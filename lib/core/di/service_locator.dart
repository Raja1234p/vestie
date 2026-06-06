import 'package:connectivity_plus/connectivity_plus.dart';

import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/accept_risk_disclaimer_use_case.dart';
import '../../features/auth/domain/usecases/delete_me_profile_picture_use_case.dart';
import '../../features/auth/domain/usecases/forgot_password_use_case.dart';
import '../../features/auth/domain/usecases/get_me_use_case.dart';
import '../../features/auth/domain/usecases/get_risk_disclaimer_use_case.dart';
import '../../features/auth/domain/usecases/google_login_use_case.dart';
import '../../features/auth/domain/usecases/login_use_case.dart';
import '../../features/auth/domain/usecases/logout_use_case.dart';
import '../../features/auth/domain/usecases/register_use_case.dart';
import '../../features/auth/domain/usecases/resend_code_use_case.dart';
import '../../features/auth/domain/usecases/reset_password_use_case.dart';
import '../../features/auth/domain/usecases/update_me_use_case.dart';
import '../../features/auth/domain/usecases/verify_email_use_case.dart';
import '../../features/bank_accounts/data/datasources/bank_accounts_remote_data_source.dart';
import '../../features/bank_accounts/domain/repositories/bank_accounts_repository.dart';
import '../../features/bank_accounts/domain/usecases/bank_accounts_usecases.dart';
import '../../features/kyc/data/datasources/kyc_remote_data_source.dart';
import '../../features/kyc/domain/repositories/kyc_repository.dart';
import '../../features/kyc/domain/usecases/kyc_usecases.dart';
import '../../features/notifications/data/datasources/notifications_remote_data_source.dart';
import '../../features/notifications/domain/repositories/notifications_repository.dart';
import '../../features/notifications/domain/usecases/notifications_usecases.dart';
import '../../features/payment_methods/data/datasources/payment_methods_remote_data_source.dart';
import '../../features/payment_methods/domain/repositories/payment_methods_repository.dart';
import '../../features/payment_methods/domain/usecases/payment_methods_usecases.dart';
import '../../features/project_announcements/data/datasources/project_announcements_remote_data_source.dart';
import '../../features/project_announcements/domain/repositories/project_announcements_repository.dart';
import '../../features/project_announcements/domain/usecases/project_announcements_usecases.dart';
import '../../features/project_detail/data/datasources/project_actions_remote_data_source.dart';
import '../../features/project_detail/data/datasources/project_detail_remote_data_source.dart';
import '../../features/project_detail/data/datasources/voting_remote_data_source.dart';
import '../../features/project_detail/domain/repositories/project_actions_repository.dart';
import '../../features/project_detail/domain/repositories/project_detail_repository.dart';
import '../../features/project_detail/domain/repositories/voting_repository.dart';
import '../../features/project_detail/domain/usecases/get_member_activity_usecase.dart';
import '../../features/project_detail/domain/usecases/list_pending_join_requests_usecase.dart';
import '../../features/project_detail/domain/usecases/moderate_member_usecase.dart';
import '../../features/project_detail/domain/usecases/project_actions_usecases.dart';
import '../../features/project_detail/domain/usecases/submit_vote_usecase.dart';
import '../../features/project_detail/presentation/bloc/moderation_bloc.dart';
import '../../features/project_detail/presentation/bloc/voting_bloc.dart';
import '../../features/project_pot/data/datasources/project_pot_remote_data_source.dart';
import '../../features/project_pot/domain/repositories/project_pot_repository.dart';
import '../../features/project_pot/domain/usecases/get_project_pot_use_case.dart';
import '../../features/projects/data/datasources/project_local_data_source.dart';
import '../../features/projects/data/datasources/project_remote_data_source.dart';
import '../../features/projects/data/datasources/projects_remote_data_source.dart';
import '../../features/projects/domain/repositories/project_repository.dart';
import '../../features/projects/domain/repositories/projects_repository.dart';
import '../../features/projects/domain/usecases/create_and_launch_project_use_case.dart';
import '../../features/projects/domain/usecases/create_project_use_case.dart';
import '../../features/projects/domain/usecases/get_project_detail_usecase.dart';
import '../../features/projects/domain/usecases/join_project_usecase.dart';
import '../../features/projects/domain/usecases/list_projects_use_case.dart';
import '../../features/projects/domain/usecases/preview_invite_usecase.dart';
import '../../features/projects/presentation/bloc/project_detail_bloc.dart';
import '../../features/stripe/data/datasources/stripe_remote_data_source.dart';
import '../../features/stripe/domain/repositories/stripe_repository.dart';
import '../../features/stripe/domain/usecases/get_stripe_config_use_case.dart';
import '../../wallet/data/datasources/wallet_deposit_remote_data_source.dart';
import '../../wallet/data/datasources/wallet_remote_data_source.dart';
import '../../wallet/data/datasources/wallet_withdrawal_remote_data_source.dart';
import '../../wallet/domain/repositories/wallet_deposit_repository.dart';
import '../../wallet/domain/repositories/wallet_repository.dart';
import '../../wallet/domain/repositories/wallet_withdrawal_repository.dart';
import '../../wallet/domain/usecases/get_wallet_use_case.dart';
import '../../wallet/domain/usecases/run_wallet_deposit_use_case.dart';
import '../../wallet/domain/usecases/wallet_withdrawal_usecases.dart';
import 'package:vestie/user/features/borrow/data/datasources/borrow_remote_data_source.dart';
import 'package:vestie/user/features/borrow/domain/repositories/borrow_repository.dart';
import 'package:vestie/user/features/borrow/domain/usecases/approve_borrow_request_use_case.dart';
import 'package:vestie/user/features/borrow/domain/usecases/create_borrow_request_use_case.dart';
import 'package:vestie/user/features/borrow/domain/usecases/reject_borrow_request_use_case.dart';
import 'package:vestie/user/features/contributions/data/datasources/contribution_remote_data_source.dart';
import 'package:vestie/user/features/contributions/domain/repositories/contribution_repository.dart';
import 'package:vestie/user/features/contributions/domain/usecases/confirm_contribution_usecase.dart';
import 'package:vestie/user/features/contributions/domain/usecases/fetch_contribution_config_usecase.dart';
import 'package:vestie/user/features/contributions/domain/usecases/preview_contribution_usecase.dart';
import 'package:vestie/user/features/contributions/presentation/bloc/contribute_bloc.dart';
import 'package:vestie/user/features/home/data/datasources/user_me_summary_remote_data_source.dart';
import 'package:vestie/user/features/home/domain/repositories/user_me_summary_repository.dart';
import 'package:vestie/user/features/home/domain/usecases/get_user_me_summary_use_case.dart';
import 'package:vestie/user/features/vff/data/datasources/vff_remote_data_source.dart';
import 'package:vestie/user/features/vff/domain/repositories/vff_repository.dart';
import 'package:vestie/user/features/vff/domain/usecases/vff_usecases.dart';
import '../network/base_api_client.dart';
import '../network/dio_client.dart';
import '../network/network_info.dart';
import '../storage/secure_storage_impl.dart';
import '../storage/shared_prefs_impl.dart';
import '../stripe/stripe_payment_service.dart';
import 'inject_auth.dart';
import 'inject_core.dart';
import 'inject_notifications.dart';
import 'inject_project.dart';
import 'inject_user.dart';
import 'inject_wallet.dart';

/// Application-wide dependency registry. Registration is split by domain in
/// [inject_core.dart], [inject_auth.dart], [inject_project.dart],
/// [inject_wallet.dart], [inject_notifications.dart], [inject_user.dart].
class ServiceLocator {
  ServiceLocator._();
  static final ServiceLocator instance = ServiceLocator._();

  late final DioClient dioClient;
  late final SecureStorageImpl secureStorage;
  late final SharedPrefsImpl sharedPrefs;
  late final Connectivity connectivity;
  late final NetworkInfo networkInfo;
  late final ProjectLocalDataSource projectLocalDataSource;

  late final AuthRemoteDataSource authRemoteDataSource;
  late final AuthRepository authRepository;
  late final LoginUseCase loginUseCase;
  late final RegisterUseCase registerUseCase;
  late final VerifyEmailUseCase verifyEmailUseCase;
  late final ResendCodeUseCase resendCodeUseCase;
  late final ForgotPasswordUseCase forgotPasswordUseCase;
  late final ResetPasswordUseCase resetPasswordUseCase;
  late final LogoutUseCase logoutUseCase;
  late final GetMeUseCase getMeUseCase;
  late final GetRiskDisclaimerUseCase getRiskDisclaimerUseCase;
  late final AcceptRiskDisclaimerUseCase acceptRiskDisclaimerUseCase;
  late final GoogleLoginUseCase googleLoginUseCase;
  late final UpdateMeUseCase updateMeUseCase;
  late final DeleteMeProfilePictureUseCase deleteMeProfilePictureUseCase;

  late final ProjectsRemoteDataSource projectsRemoteDataSource;
  late final ProjectRemoteDataSource projectRemoteDataSource;
  late final ProjectsRepository projectsRepository;
  late final ProjectRepository projectRepository;
  late final ListProjectsUseCase listProjectsUseCase;
  late final CreateProjectUseCase createProjectUseCase;
  late final CreateAndLaunchProjectUseCase createAndLaunchProjectUseCase;
  late final PreviewInviteUseCase previewInviteUseCase;
  late final JoinProjectUseCase joinProjectUseCase;

  late final ProjectDetailRemoteDataSource projectDetailRemoteDataSource;
  late final ProjectDetailRepository projectDetailRepository;
  late final GetProjectDetailUseCase getProjectDetailUseCase;
  late final ProjectActionsRemoteDataSource projectActionsRemoteDataSource;
  late final ProjectActionsRepository projectActionsRepository;
  late final OpenClosureVotingUseCase openClosureVotingUseCase;
  late final OpenStopContributionsVotingUseCase
  openStopContributionsVotingUseCase;
  late final CancelProjectUseCase cancelProjectUseCase;
  late final LeaveProjectUseCase leaveProjectUseCase;
  late final ListPendingJoinRequestsUseCase listPendingJoinRequestsUseCase;
  late final ApproveMembershipUseCase approveMembershipUseCase;
  late final RejectMembershipUseCase rejectMembershipUseCase;
  late final CreateInviteUseCase createInviteUseCase;
  late final AssignCoLeaderUseCase assignCoLeaderUseCase;
  late final RemoveCoLeaderUseCase removeCoLeaderUseCase;
  late final UpdateCoLeaderRoleUseCase updateCoLeaderRoleUseCase;
  late final RemoveMemberUseCase removeMemberUseCase;
  late final GetMemberActivityUseCase getMemberActivityUseCase;
  late final MarkDefaultedUseCase markDefaultedUseCase;
  late final RemoveForNonRepaymentUseCase removeForNonRepaymentUseCase;
  late final CastClosureVoteUseCase castClosureVoteUseCase;
  late final ExtendClosureVotingUseCase extendClosureVotingUseCase;
  late final FinalizeClosureVotingUseCase finalizeClosureVotingUseCase;
  late final ResolveGoalUseCase resolveGoalUseCase;
  late final ExtendDeadlineUseCase extendDeadlineUseCase;
  late final CompleteProjectUseCase completeProjectUseCase;

  late final WalletRemoteDataSource walletRemoteDataSource;
  late final WalletRepository walletRepository;
  late final GetWalletUseCase getWalletUseCase;
  late final ProjectPotRemoteDataSource projectPotRemoteDataSource;
  late final ProjectPotRepository projectPotRepository;
  late final GetProjectPotUseCase getProjectPotUseCase;

  late final StripeRemoteDataSource stripeRemoteDataSource;
  late final StripeRepository stripeRepository;
  late final GetStripeConfigUseCase getStripeConfigUseCase;
  late final StripePaymentService stripePaymentService;

  late final PaymentMethodsRemoteDataSource paymentMethodsRemoteDataSource;
  late final PaymentMethodsRepository paymentMethodsRepository;
  late final ListPaymentMethodsUseCase listPaymentMethodsUseCase;
  late final SavePaymentCardViaSetupUseCase savePaymentCardViaSetupUseCase;
  late final GetPaymentMethodUseCase getPaymentMethodUseCase;
  late final SetPrimaryPaymentMethodUseCase setPrimaryPaymentMethodUseCase;
  late final RemovePaymentMethodUseCase removePaymentMethodUseCase;

  late final WalletDepositRemoteDataSource walletDepositRemoteDataSource;
  late final WalletDepositRepository walletDepositRepository;
  late final RunWalletDepositUseCase runWalletDepositUseCase;

  late final KycRemoteDataSource kycRemoteDataSource;
  late final KycRepository kycRepository;
  late final GetKycStatusUseCase getKycStatusUseCase;
  late final StartKycUseCase startKycUseCase;

  late final BankAccountsRemoteDataSource bankAccountsRemoteDataSource;
  late final BankAccountsRepository bankAccountsRepository;
  late final ListBankAccountsUseCase listBankAccountsUseCase;
  late final LinkBankAccountUseCase linkBankAccountUseCase;
  late final RemoveBankAccountUseCase removeBankAccountUseCase;
  late final SetDefaultBankAccountUseCase setDefaultBankAccountUseCase;

  late final WalletWithdrawalRemoteDataSource walletWithdrawalRemoteDataSource;
  late final WalletWithdrawalRepository walletWithdrawalRepository;
  late final PreviewWithdrawalUseCase previewWithdrawalUseCase;
  late final RunWalletWithdrawUseCase runWalletWithdrawUseCase;

  late final ProjectAnnouncementsRemoteDataSource
  projectAnnouncementsRemoteDataSource;
  late final ProjectAnnouncementsRepository projectAnnouncementsRepository;
  late final CreateProjectAnnouncementUseCase createProjectAnnouncementUseCase;
  late final DeleteProjectAnnouncementUseCase deleteProjectAnnouncementUseCase;

  late final NotificationsRemoteDataSource notificationsRemoteDataSource;
  late final NotificationsRepository notificationsRepository;
  late final ListNotificationsUseCase listNotificationsUseCase;
  late final MarkNotificationsReadUseCase markNotificationsReadUseCase;
  late final RegisterDeviceTokenUseCase registerDeviceTokenUseCase;
  late final UnregisterDeviceTokenUseCase unregisterDeviceTokenUseCase;

  late final ContributionRemoteDataSource contributionRemoteDataSource;
  late final ContributionRepository contributionRepository;
  late final FetchContributionConfigUseCase fetchContributionConfigUseCase;
  late final PreviewContributionUseCase previewContributionUseCase;
  late final ConfirmContributionUseCase confirmContributionUseCase;

  late final BorrowRemoteDataSource borrowRemoteDataSource;
  late final BorrowRepository borrowRepository;
  late final CreateBorrowRequestUseCase createBorrowRequestUseCase;
  late final ApproveBorrowRequestUseCase approveBorrowRequestUseCase;
  late final RejectBorrowRequestUseCase rejectBorrowRequestUseCase;

  late final VffRemoteDataSource vffRemoteDataSource;
  late final VffRepository vffRepository;
  late final ListMyVffsUseCase listMyVffsUseCase;
  late final GetConnectedVffProfileUseCase getConnectedVffProfileUseCase;
  late final GetPublicVffProfileUseCase getPublicVffProfileUseCase;
  late final RemoveVffConnectionUseCase removeVffConnectionUseCase;
  late final GetVffReceivedInboxUseCase getVffReceivedInboxUseCase;
  late final GetVffSentInboxUseCase getVffSentInboxUseCase;
  late final SendVffRequestUseCase sendVffRequestUseCase;
  late final AcceptVffRequestUseCase acceptVffRequestUseCase;
  late final DeclineVffRequestUseCase declineVffRequestUseCase;
  late final InviteVffsToProjectUseCase inviteVffsToProjectUseCase;
  late final AcceptVffProjectInviteUseCase acceptVffProjectInviteUseCase;
  late final DeclineVffProjectInviteUseCase declineVffProjectInviteUseCase;
  late final JoinFromVffProfileUseCase joinFromVffProfileUseCase;

  late final UserMeSummaryRemoteDataSource userMeSummaryRemoteDataSource;
  late final UserMeSummaryRepository userMeSummaryRepository;
  late final GetUserMeSummaryUseCase getUserMeSummaryUseCase;

  late final BaseApiClient apiClient;
  late final VotingRemoteDataSource votingRemoteDataSource;
  late final VotingRepository votingRepository;
  late final SubmitVoteUseCase submitVoteUseCase;
  late final ModerateMemberUseCase moderateMemberUseCase;

  late final ModerationBloc moderationBloc;
  late final VotingBloc votingBloc;

  Future<void> init() async {
    await registerCoreDependencies(this);
    registerAuthDependencies(this);
    registerProjectDependencies(this);
    registerWalletDependencies(this);
    registerNotificationsDependencies(this);
    registerUserFeatureDependencies(this);
  }

  ContributeBloc createContributeBloc() => ContributeBloc(
    configUseCase: fetchContributionConfigUseCase,
    previewUseCase: previewContributionUseCase,
    confirmUseCase: confirmContributionUseCase,
    getWalletUseCase: getWalletUseCase,
    listPaymentMethodsUseCase: listPaymentMethodsUseCase,
  );

  ProjectDetailBloc createProjectDetailBloc() => ProjectDetailBloc(
    repository: projectDetailRepository,
    getProjectPotUseCase: getProjectPotUseCase,
    listPendingJoinRequests: listPendingJoinRequestsUseCase,
    sendVffRequestUseCase: sendVffRequestUseCase,
  );
}
