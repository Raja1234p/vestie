import 'package:connectivity_plus/connectivity_plus.dart';
import '../network/network_info.dart';
import '../../features/projects/data/datasources/project_local_data_source.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../network/dio_client.dart';
import '../storage/secure_storage_impl.dart';
import '../storage/shared_prefs_impl.dart';
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/datasources/auth_remote_data_source_impl.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login_use_case.dart';
import '../../features/auth/domain/usecases/register_use_case.dart';
import '../../features/auth/domain/usecases/verify_email_use_case.dart';
import '../../features/auth/domain/usecases/resend_code_use_case.dart';
import '../../features/auth/domain/usecases/forgot_password_use_case.dart';
import '../../features/auth/domain/usecases/reset_password_use_case.dart';
import '../../features/auth/domain/usecases/logout_use_case.dart';
import '../../features/auth/domain/usecases/get_me_use_case.dart';
import '../../features/auth/domain/usecases/get_risk_disclaimer_use_case.dart';
import '../../features/auth/domain/usecases/accept_risk_disclaimer_use_case.dart';
import '../../features/auth/domain/usecases/google_login_use_case.dart';
import '../../features/auth/domain/usecases/delete_me_profile_picture_use_case.dart';
import '../../features/auth/domain/usecases/update_me_use_case.dart';
import '../../features/projects/data/datasources/project_remote_data_source.dart';
import '../../features/projects/data/datasources/projects_remote_data_source.dart';
import '../../features/projects/data/datasources/projects_remote_data_source_impl.dart';
import '../../features/projects/data/repositories/project_repository_impl.dart';
import '../../features/projects/data/repositories/projects_repository_impl.dart';
import '../../features/projects/domain/repositories/project_repository.dart';
import '../../features/projects/domain/repositories/projects_repository.dart';
import '../../features/projects/domain/usecases/list_projects_use_case.dart';
import '../../features/projects/domain/usecases/create_and_launch_project_use_case.dart';
import '../../features/projects/domain/usecases/create_project_use_case.dart';
import '../../features/projects/domain/usecases/preview_invite_usecase.dart';
import '../../features/projects/domain/usecases/join_project_usecase.dart';
import '../../features/project_detail/data/datasources/project_detail_remote_data_source.dart';
import '../../features/project_detail/data/datasources/project_detail_remote_data_source_impl.dart';
import '../../features/project_detail/data/datasources/project_actions_remote_data_source.dart';
import '../../features/project_detail/data/repositories/project_detail_repository_impl.dart';
import '../../features/project_detail/data/repositories/project_actions_repository_impl.dart';
import '../../features/project_detail/domain/repositories/project_detail_repository.dart';
import '../../features/project_detail/domain/repositories/project_actions_repository.dart';
import '../../features/projects/domain/usecases/get_project_detail_usecase.dart';
import '../../features/project_detail/domain/usecases/get_member_activity_usecase.dart';
import '../../features/project_detail/domain/usecases/list_pending_join_requests_usecase.dart';
import '../../features/project_detail/domain/usecases/project_actions_usecases.dart';
import 'package:vestie/user/features/contributions/data/datasources/contribution_remote_data_source.dart';
import 'package:vestie/user/features/contributions/data/repositories/contribution_repository_impl.dart';
import 'package:vestie/user/features/contributions/domain/repositories/contribution_repository.dart';
import 'package:vestie/user/features/contributions/domain/usecases/preview_contribution_usecase.dart';
import 'package:vestie/user/features/contributions/domain/usecases/confirm_contribution_usecase.dart';
import 'package:vestie/user/features/contributions/domain/usecases/fetch_contribution_config_usecase.dart';
import 'package:vestie/user/features/borrow/data/datasources/borrow_remote_data_source.dart';
import 'package:vestie/user/features/borrow/data/datasources/borrow_remote_data_source_impl.dart';
import 'package:vestie/user/features/borrow/data/repositories/borrow_repository_impl.dart';
import 'package:vestie/user/features/borrow/domain/repositories/borrow_repository.dart';
import 'package:vestie/user/features/borrow/domain/usecases/create_borrow_request_use_case.dart';
import 'package:vestie/user/features/borrow/domain/usecases/approve_borrow_request_use_case.dart';
import 'package:vestie/user/features/borrow/domain/usecases/reject_borrow_request_use_case.dart';
import 'package:vestie/user/features/vff/data/datasources/vff_remote_data_source.dart';
import 'package:vestie/user/features/vff/data/repositories/vff_repository_impl.dart';
import 'package:vestie/user/features/vff/domain/repositories/vff_repository.dart';
import 'package:vestie/user/features/vff/domain/usecases/vff_usecases.dart';
import 'package:vestie/user/features/home/data/datasources/user_me_summary_remote_data_source.dart';
import 'package:vestie/user/features/home/data/repositories/user_me_summary_repository_impl.dart';
import 'package:vestie/user/features/home/domain/repositories/user_me_summary_repository.dart';
import 'package:vestie/user/features/home/domain/usecases/get_user_me_summary_use_case.dart';
import '../network/base_api_client.dart';
import '../../features/projects/presentation/bloc/project_detail_bloc.dart';
import '../../features/project_detail/domain/usecases/moderate_member_usecase.dart';
import '../../features/project_detail/domain/usecases/submit_vote_usecase.dart';
import '../../features/project_detail/presentation/bloc/moderation_bloc.dart';
import '../../features/project_detail/presentation/bloc/voting_bloc.dart';
import '../../features/project_detail/domain/repositories/voting_repository.dart';
import '../../features/project_detail/data/repositories/voting_repository_impl.dart';
import '../../features/project_detail/data/datasources/voting_remote_data_source.dart';
import 'package:vestie/user/features/contributions/presentation/bloc/contribute_bloc.dart';
import 'package:vestie/features/wallet/data/datasources/wallet_remote_data_source.dart';
import 'package:vestie/features/wallet/data/repositories/wallet_repository_impl.dart';
import 'package:vestie/features/wallet/domain/repositories/wallet_repository.dart';
import 'package:vestie/features/wallet/domain/usecases/get_wallet_use_case.dart';
import 'package:vestie/features/project_pot/data/datasources/project_pot_remote_data_source.dart';
import 'package:vestie/features/project_pot/data/repositories/project_pot_repository_impl.dart';
import 'package:vestie/features/project_pot/domain/repositories/project_pot_repository.dart';
import 'package:vestie/features/project_pot/domain/usecases/get_project_pot_use_case.dart';
import 'package:vestie/features/stripe/data/datasources/stripe_remote_data_source.dart';
import 'package:vestie/features/stripe/data/repositories/stripe_repository_impl.dart';
import 'package:vestie/features/stripe/domain/repositories/stripe_repository.dart';
import 'package:vestie/core/stripe/stripe_payment_service.dart';
import 'package:vestie/features/stripe/domain/usecases/get_stripe_config_use_case.dart';
import 'package:vestie/features/payment_methods/data/datasources/payment_methods_remote_data_source.dart';
import 'package:vestie/features/payment_methods/data/repositories/payment_methods_repository_impl.dart';
import 'package:vestie/features/payment_methods/domain/repositories/payment_methods_repository.dart';
import 'package:vestie/features/payment_methods/domain/usecases/payment_methods_usecases.dart';
import 'package:vestie/features/wallet/data/datasources/wallet_deposit_remote_data_source.dart';
import 'package:vestie/features/wallet/data/repositories/wallet_deposit_repository_impl.dart';
import 'package:vestie/features/wallet/domain/repositories/wallet_deposit_repository.dart';
import 'package:vestie/features/wallet/domain/usecases/run_wallet_deposit_use_case.dart';
import 'package:vestie/features/kyc/data/datasources/kyc_remote_data_source.dart';
import 'package:vestie/features/kyc/data/repositories/kyc_repository_impl.dart';
import 'package:vestie/features/kyc/domain/repositories/kyc_repository.dart';
import 'package:vestie/features/kyc/domain/usecases/kyc_usecases.dart';
import 'package:vestie/features/bank_accounts/data/datasources/bank_accounts_remote_data_source.dart';
import 'package:vestie/features/bank_accounts/data/repositories/bank_accounts_repository_impl.dart';
import 'package:vestie/features/bank_accounts/domain/repositories/bank_accounts_repository.dart';
import 'package:vestie/features/bank_accounts/domain/usecases/bank_accounts_usecases.dart';
import 'package:vestie/features/wallet/data/datasources/wallet_withdrawal_remote_data_source.dart';
import 'package:vestie/features/wallet/data/repositories/wallet_withdrawal_repository_impl.dart';
import 'package:vestie/features/wallet/domain/repositories/wallet_withdrawal_repository.dart';
import 'package:vestie/features/wallet/domain/usecases/wallet_withdrawal_usecases.dart';
import 'package:vestie/features/project_announcements/data/datasources/project_announcements_remote_data_source.dart';
import 'package:vestie/features/project_announcements/data/repositories/project_announcements_repository_impl.dart';
import 'package:vestie/features/project_announcements/domain/repositories/project_announcements_repository.dart';
import 'package:vestie/features/project_announcements/domain/usecases/project_announcements_usecases.dart';
import 'package:vestie/features/notifications/data/datasources/notifications_remote_data_source.dart';
import 'package:vestie/features/notifications/data/repositories/notifications_repository_impl.dart';
import 'package:vestie/features/notifications/domain/repositories/notifications_repository.dart';
import 'package:vestie/features/notifications/domain/usecases/notifications_usecases.dart';

class ServiceLocator {
  ServiceLocator._();
  static final ServiceLocator instance = ServiceLocator._();

  late final DioClient dioClient;
  late final SecureStorageImpl secureStorage;
  late final SharedPrefsImpl sharedPrefs;
  late final Connectivity connectivity;
  late final NetworkInfo networkInfo;
  late final ProjectLocalDataSource projectLocalDataSource;

  // ── Auth Feature ─────────────────────────────────────────────────────────
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

  // ── Projects Feature ─────────────────────────────────────────────────────
  late final ProjectsRemoteDataSource projectsRemoteDataSource;
  late final ProjectRemoteDataSource projectRemoteDataSource;
  late final ProjectsRepository projectsRepository;
  late final ProjectRepository projectRepository;
  late final ListProjectsUseCase listProjectsUseCase;
  late final CreateProjectUseCase createProjectUseCase;
  late final CreateAndLaunchProjectUseCase createAndLaunchProjectUseCase;
  late final PreviewInviteUseCase previewInviteUseCase;
  late final JoinProjectUseCase joinProjectUseCase;

  // ── Project Detail Feature ───────────────────────────────────────────────
  late final ProjectDetailRemoteDataSource projectDetailRemoteDataSource;
  late final ProjectDetailRepository projectDetailRepository;
  late final GetProjectDetailUseCase getProjectDetailUseCase;
  late final ProjectActionsRemoteDataSource projectActionsRemoteDataSource;
  late final ProjectActionsRepository projectActionsRepository;
  late final OpenClosureVotingUseCase openClosureVotingUseCase;
  late final OpenStopContributionsVotingUseCase openStopContributionsVotingUseCase;
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

  // ── Wallet & project pot (Week 4+) ───────────────────────────────────────
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
  late final SavePaymentCardUseCase savePaymentCardUseCase;
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
  late final RemoveBankAccountUseCase removeBankAccountUseCase;

  late final WalletWithdrawalRemoteDataSource walletWithdrawalRemoteDataSource;
  late final WalletWithdrawalRepository walletWithdrawalRepository;
  late final PreviewWithdrawalUseCase previewWithdrawalUseCase;
  late final RunWalletWithdrawUseCase runWalletWithdrawUseCase;

  late final ProjectAnnouncementsRemoteDataSource projectAnnouncementsRemoteDataSource;
  late final ProjectAnnouncementsRepository projectAnnouncementsRepository;
  late final CreateProjectAnnouncementUseCase createProjectAnnouncementUseCase;
  late final DeleteProjectAnnouncementUseCase deleteProjectAnnouncementUseCase;

  late final NotificationsRemoteDataSource notificationsRemoteDataSource;
  late final NotificationsRepository notificationsRepository;
  late final ListNotificationsUseCase listNotificationsUseCase;
  late final MarkNotificationsReadUseCase markNotificationsReadUseCase;
  late final RegisterDeviceTokenUseCase registerDeviceTokenUseCase;
  late final UnregisterDeviceTokenUseCase unregisterDeviceTokenUseCase;

  // ── Contributions Feature ────────────────────────────────────────────────
  late final ContributionRemoteDataSource contributionRemoteDataSource;
  late final ContributionRepository contributionRepository;
  late final FetchContributionConfigUseCase fetchContributionConfigUseCase;
  late final PreviewContributionUseCase previewContributionUseCase;
  late final ConfirmContributionUseCase confirmContributionUseCase;

  // ── Borrow Feature ───────────────────────────────────────────────────────
  late final BorrowRemoteDataSource borrowRemoteDataSource;
  late final BorrowRepository borrowRepository;
  late final CreateBorrowRequestUseCase createBorrowRequestUseCase;
  late final ApproveBorrowRequestUseCase approveBorrowRequestUseCase;
  late final RejectBorrowRequestUseCase rejectBorrowRequestUseCase;

  // ── VFF Feature ──────────────────────────────────────────────────────────
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

  // ── Home (user summary) ──────────────────────────────────────────────────
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
    // ── Core ───────────────────────────────────────────────────────────────
    final sharedPreferences = await SharedPreferences.getInstance();
    sharedPrefs = SharedPrefsImpl(sharedPreferences);
    secureStorage = SecureStorageImpl();
    dioClient = DioClient(secureStorage: secureStorage);
    apiClient = BaseApiClient(dio: dioClient.dio);
    connectivity = Connectivity();
    networkInfo = NetworkInfoImpl(connectivity);
    projectLocalDataSource = ProjectLocalDataSourceImpl(localStorage: sharedPrefs);

    // ── Auth Feature ───────────────────────────────────────────────────────
    authRemoteDataSource = AuthRemoteDataSourceImpl(dioClient);
    authRepository = AuthRepositoryImpl(authRemoteDataSource, sharedPrefs);

    loginUseCase = LoginUseCase(authRepository);
    registerUseCase = RegisterUseCase(authRepository);
    verifyEmailUseCase = VerifyEmailUseCase(authRepository);
    resendCodeUseCase = ResendCodeUseCase(authRepository);
    forgotPasswordUseCase = ForgotPasswordUseCase(authRepository);
    resetPasswordUseCase = ResetPasswordUseCase(authRepository);
    logoutUseCase = LogoutUseCase(authRepository);
    getMeUseCase = GetMeUseCase(authRepository);
    getRiskDisclaimerUseCase = GetRiskDisclaimerUseCase(authRepository);
    acceptRiskDisclaimerUseCase = AcceptRiskDisclaimerUseCase(authRepository);
    googleLoginUseCase = GoogleLoginUseCase(authRepository);
    updateMeUseCase = UpdateMeUseCase(authRepository);
    deleteMeProfilePictureUseCase = DeleteMeProfilePictureUseCase(authRepository);

    // ── Projects Feature ───────────────────────────────────────────────────
    projectsRemoteDataSource = ProjectsRemoteDataSourceImpl(dioClient);
    projectsRepository = ProjectsRepositoryImpl(projectsRemoteDataSource);
    projectRemoteDataSource = ProjectRemoteDataSourceImpl(apiClient: apiClient);
    projectRepository = ProjectRepositoryImpl(
      remoteDataSource: projectRemoteDataSource,
      localDataSource: projectLocalDataSource,
      networkInfo: networkInfo,
    );
    listProjectsUseCase = ListProjectsUseCase(projectsRepository);
    createProjectUseCase = CreateProjectUseCase(projectsRepository);
    createAndLaunchProjectUseCase =
        CreateAndLaunchProjectUseCase(projectsRepository);
    previewInviteUseCase = PreviewInviteUseCase(projectRepository);
    joinProjectUseCase = JoinProjectUseCase(projectRepository);

    // ── Project Detail Feature ─────────────────────────────────────────────
    projectDetailRemoteDataSource = ProjectDetailRemoteDataSourceImpl(dioClient);
    projectDetailRepository = ProjectDetailRepositoryImpl(projectDetailRemoteDataSource);
    getProjectDetailUseCase = GetProjectDetailUseCase(projectRepository);
    projectActionsRemoteDataSource = ProjectActionsRemoteDataSourceImpl(apiClient: apiClient);
    projectActionsRepository = ProjectActionsRepositoryImpl(remoteDataSource: projectActionsRemoteDataSource);
    openClosureVotingUseCase = OpenClosureVotingUseCase(projectActionsRepository);
    openStopContributionsVotingUseCase =
        OpenStopContributionsVotingUseCase(projectActionsRepository);
    cancelProjectUseCase = CancelProjectUseCase(projectActionsRepository);
    leaveProjectUseCase = LeaveProjectUseCase(projectActionsRepository);
    listPendingJoinRequestsUseCase =
        ListPendingJoinRequestsUseCase(projectActionsRepository);
    approveMembershipUseCase = ApproveMembershipUseCase(projectActionsRepository);
    rejectMembershipUseCase = RejectMembershipUseCase(projectActionsRepository);
    createInviteUseCase = CreateInviteUseCase(projectActionsRepository);
    assignCoLeaderUseCase = AssignCoLeaderUseCase(projectActionsRepository);
    removeCoLeaderUseCase = RemoveCoLeaderUseCase(projectActionsRepository);
    updateCoLeaderRoleUseCase = UpdateCoLeaderRoleUseCase(projectActionsRepository);
    removeMemberUseCase = RemoveMemberUseCase(projectActionsRepository);
    getMemberActivityUseCase = GetMemberActivityUseCase(projectActionsRepository);
    markDefaultedUseCase = MarkDefaultedUseCase(projectActionsRepository);
    removeForNonRepaymentUseCase = RemoveForNonRepaymentUseCase(projectActionsRepository);
    castClosureVoteUseCase = CastClosureVoteUseCase(projectActionsRepository);
    extendClosureVotingUseCase = ExtendClosureVotingUseCase(projectActionsRepository);
    finalizeClosureVotingUseCase = FinalizeClosureVotingUseCase(projectActionsRepository);
    resolveGoalUseCase = ResolveGoalUseCase(projectActionsRepository);
    extendDeadlineUseCase = ExtendDeadlineUseCase(projectActionsRepository);
    completeProjectUseCase = CompleteProjectUseCase(projectActionsRepository);

    // ── Wallet & project pot ─────────────────────────────────────────────────
    walletRemoteDataSource = WalletRemoteDataSourceImpl(apiClient: apiClient);
    walletRepository = WalletRepositoryImpl(remoteDataSource: walletRemoteDataSource);
    getWalletUseCase = GetWalletUseCase(walletRepository);
    projectPotRemoteDataSource = ProjectPotRemoteDataSourceImpl(apiClient: apiClient);
    projectPotRepository = ProjectPotRepositoryImpl(remoteDataSource: projectPotRemoteDataSource);
    getProjectPotUseCase = GetProjectPotUseCase(projectPotRepository);

    stripeRemoteDataSource = StripeRemoteDataSourceImpl(apiClient: apiClient);
    stripeRepository = StripeRepositoryImpl(remoteDataSource: stripeRemoteDataSource);
    getStripeConfigUseCase = GetStripeConfigUseCase(stripeRepository);
    stripePaymentService = StripePaymentService();

    paymentMethodsRemoteDataSource =
        PaymentMethodsRemoteDataSourceImpl(apiClient: apiClient);
    paymentMethodsRepository = PaymentMethodsRepositoryImpl(
      remoteDataSource: paymentMethodsRemoteDataSource,
    );
    listPaymentMethodsUseCase =
        ListPaymentMethodsUseCase(paymentMethodsRepository);
    savePaymentCardUseCase = SavePaymentCardUseCase(paymentMethodsRepository);
    setPrimaryPaymentMethodUseCase =
        SetPrimaryPaymentMethodUseCase(paymentMethodsRepository);
    removePaymentMethodUseCase =
        RemovePaymentMethodUseCase(paymentMethodsRepository);

    walletDepositRemoteDataSource =
        WalletDepositRemoteDataSourceImpl(apiClient: apiClient);
    walletDepositRepository = WalletDepositRepositoryImpl(
      remoteDataSource: walletDepositRemoteDataSource,
      walletRepository: walletRepository,
      getStripeConfigUseCase: getStripeConfigUseCase,
      stripePaymentService: stripePaymentService,
    );
    runWalletDepositUseCase = RunWalletDepositUseCase(walletDepositRepository);

    kycRemoteDataSource = KycRemoteDataSourceImpl(apiClient: apiClient);
    kycRepository = KycRepositoryImpl(remoteDataSource: kycRemoteDataSource);
    getKycStatusUseCase = GetKycStatusUseCase(kycRepository);
    startKycUseCase = StartKycUseCase(kycRepository);

    bankAccountsRemoteDataSource =
        BankAccountsRemoteDataSourceImpl(apiClient: apiClient);
    bankAccountsRepository =
        BankAccountsRepositoryImpl(remoteDataSource: bankAccountsRemoteDataSource);
    listBankAccountsUseCase = ListBankAccountsUseCase(bankAccountsRepository);
    removeBankAccountUseCase = RemoveBankAccountUseCase(bankAccountsRepository);

    walletWithdrawalRemoteDataSource =
        WalletWithdrawalRemoteDataSourceImpl(apiClient: apiClient);
    walletWithdrawalRepository = WalletWithdrawalRepositoryImpl(
      remoteDataSource: walletWithdrawalRemoteDataSource,
      walletRepository: walletRepository,
    );
    previewWithdrawalUseCase =
        PreviewWithdrawalUseCase(walletWithdrawalRepository);
    runWalletWithdrawUseCase = RunWalletWithdrawUseCase(walletWithdrawalRepository);

    projectAnnouncementsRemoteDataSource =
        ProjectAnnouncementsRemoteDataSourceImpl(apiClient: apiClient);
    projectAnnouncementsRepository = ProjectAnnouncementsRepositoryImpl(
      remoteDataSource: projectAnnouncementsRemoteDataSource,
    );
    createProjectAnnouncementUseCase =
        CreateProjectAnnouncementUseCase(projectAnnouncementsRepository);
    deleteProjectAnnouncementUseCase =
        DeleteProjectAnnouncementUseCase(projectAnnouncementsRepository);

    notificationsRemoteDataSource =
        NotificationsRemoteDataSourceImpl(apiClient: apiClient);
    notificationsRepository =
        NotificationsRepositoryImpl(remoteDataSource: notificationsRemoteDataSource);
    listNotificationsUseCase = ListNotificationsUseCase(notificationsRepository);
    markNotificationsReadUseCase =
        MarkNotificationsReadUseCase(notificationsRepository);
    registerDeviceTokenUseCase =
        RegisterDeviceTokenUseCase(notificationsRepository);
    unregisterDeviceTokenUseCase =
        UnregisterDeviceTokenUseCase(notificationsRepository);

    // ── Contributions Feature ──────────────────────────────────────────────
    contributionRemoteDataSource = ContributionRemoteDataSourceImpl(apiClient: apiClient);
    contributionRepository = ContributionRepositoryImpl(
      remoteDataSource: contributionRemoteDataSource,
      walletRepository: walletRepository,
    );
    fetchContributionConfigUseCase = FetchContributionConfigUseCase(contributionRepository);
    previewContributionUseCase = PreviewContributionUseCase(contributionRepository);
    confirmContributionUseCase = ConfirmContributionUseCase(contributionRepository);

    // ── Borrow Feature ─────────────────────────────────────────────────────
    borrowRemoteDataSource = BorrowRemoteDataSourceImpl(dioClient);
    borrowRepository = BorrowRepositoryImpl(borrowRemoteDataSource);
    createBorrowRequestUseCase = CreateBorrowRequestUseCase(borrowRepository);
    approveBorrowRequestUseCase = ApproveBorrowRequestUseCase(borrowRepository);
    rejectBorrowRequestUseCase = RejectBorrowRequestUseCase(borrowRepository);

    // ── VFF Feature ────────────────────────────────────────────────────────
    vffRemoteDataSource = VffRemoteDataSourceImpl(apiClient: apiClient);
    vffRepository = VffRepositoryImpl(remoteDataSource: vffRemoteDataSource);
    listMyVffsUseCase = ListMyVffsUseCase(vffRepository);
    getConnectedVffProfileUseCase = GetConnectedVffProfileUseCase(vffRepository);
    getPublicVffProfileUseCase = GetPublicVffProfileUseCase(vffRepository);
    removeVffConnectionUseCase = RemoveVffConnectionUseCase(vffRepository);
    getVffReceivedInboxUseCase = GetVffReceivedInboxUseCase(vffRepository);
    getVffSentInboxUseCase = GetVffSentInboxUseCase(vffRepository);
    sendVffRequestUseCase = SendVffRequestUseCase(vffRepository);
    acceptVffRequestUseCase = AcceptVffRequestUseCase(vffRepository);
    declineVffRequestUseCase = DeclineVffRequestUseCase(vffRepository);
    inviteVffsToProjectUseCase = InviteVffsToProjectUseCase(vffRepository);
    acceptVffProjectInviteUseCase = AcceptVffProjectInviteUseCase(vffRepository);
    declineVffProjectInviteUseCase = DeclineVffProjectInviteUseCase(vffRepository);
    joinFromVffProfileUseCase = JoinFromVffProfileUseCase(vffRepository);

    // ── Home user summary ──────────────────────────────────────────────────
    userMeSummaryRemoteDataSource =
        UserMeSummaryRemoteDataSourceImpl(apiClient: apiClient);
    userMeSummaryRepository =
        UserMeSummaryRepositoryImpl(remoteDataSource: userMeSummaryRemoteDataSource);
    getUserMeSummaryUseCase = GetUserMeSummaryUseCase(userMeSummaryRepository);

    // ── Unified API Client & Action Handlers ──────────────────────────────
    votingRemoteDataSource = VotingRemoteDataSourceImpl(apiClient: apiClient);
    votingRepository = VotingRepositoryImpl(remoteDataSource: votingRemoteDataSource);
    submitVoteUseCase = SubmitVoteUseCase(repository: votingRepository);
    moderateMemberUseCase = ModerateMemberUseCase(repository: projectActionsRepository);

    // ── New Enterprise Blocs ────────────────────────────────────────────────
    moderationBloc = ModerationBloc(moderateMemberUseCase: moderateMemberUseCase);
    votingBloc = VotingBloc(submitVoteUseCase: submitVoteUseCase);
  }

  /// Fresh bloc per contribute flow — [BlocProvider] closes it on pop.
  ContributeBloc createContributeBloc() => ContributeBloc(
        configUseCase: fetchContributionConfigUseCase,
        previewUseCase: previewContributionUseCase,
        confirmUseCase: confirmContributionUseCase,
        getWalletUseCase: getWalletUseCase,
      );

  /// Fresh bloc per detail route — avoids stale project state from a shared instance.
  ProjectDetailBloc createProjectDetailBloc() => ProjectDetailBloc(
        repository: projectDetailRepository,
        listPendingJoinRequests: listPendingJoinRequestsUseCase,
        sendVffRequestUseCase: sendVffRequestUseCase,
      );
}
