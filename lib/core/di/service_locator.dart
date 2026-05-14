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
import '../../features/auth/domain/usecases/update_me_use_case.dart';
import '../../features/projects/data/datasources/project_remote_data_source.dart';
import '../../features/projects/data/datasources/projects_remote_data_source.dart';
import '../../features/projects/data/datasources/projects_remote_data_source_impl.dart';
import '../../features/projects/data/repositories/project_repository_impl.dart';
import '../../features/projects/data/repositories/projects_repository_impl.dart';
import '../../features/projects/domain/repositories/project_repository.dart';
import '../../features/projects/domain/repositories/projects_repository.dart';
import '../../features/projects/domain/usecases/list_projects_use_case.dart';
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

  // ── Projects Feature ─────────────────────────────────────────────────────
  late final ProjectsRemoteDataSource projectsRemoteDataSource;
  late final ProjectRemoteDataSource projectRemoteDataSource;
  late final ProjectsRepository projectsRepository;
  late final ProjectRepository projectRepository;
  late final ListProjectsUseCase listProjectsUseCase;
  late final CreateProjectUseCase createProjectUseCase;
  late final PreviewInviteUseCase previewInviteUseCase;
  late final JoinProjectUseCase joinProjectUseCase;

  // ── Project Detail Feature ───────────────────────────────────────────────
  late final ProjectDetailRemoteDataSource projectDetailRemoteDataSource;
  late final ProjectDetailRepository projectDetailRepository;
  late final GetProjectDetailUseCase getProjectDetailUseCase;
  late final ProjectActionsRemoteDataSource projectActionsRemoteDataSource;
  late final ProjectActionsRepository projectActionsRepository;
  late final OpenClosureVotingUseCase openClosureVotingUseCase;
  late final CancelProjectUseCase cancelProjectUseCase;
  late final ApproveMembershipUseCase approveMembershipUseCase;
  late final RejectMembershipUseCase rejectMembershipUseCase;
  late final CreateInviteUseCase createInviteUseCase;
  late final AssignCoLeaderUseCase assignCoLeaderUseCase;
  late final RemoveCoLeaderUseCase removeCoLeaderUseCase;
  late final RemoveMemberUseCase removeMemberUseCase;
  late final MarkDefaultedUseCase markDefaultedUseCase;
  late final RemoveForNonRepaymentUseCase removeForNonRepaymentUseCase;
  late final CastClosureVoteUseCase castClosureVoteUseCase;
  late final ExtendClosureVotingUseCase extendClosureVotingUseCase;
  late final FinalizeClosureVotingUseCase finalizeClosureVotingUseCase;
  late final ResolveGoalUseCase resolveGoalUseCase;
  late final ExtendDeadlineUseCase extendDeadlineUseCase;
  late final CompleteProjectUseCase completeProjectUseCase;

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

  late final BaseApiClient apiClient;
  late final VotingRemoteDataSource votingRemoteDataSource;
  late final VotingRepository votingRepository;
  late final SubmitVoteUseCase submitVoteUseCase;
  late final ModerateMemberUseCase moderateMemberUseCase;

  late final ProjectDetailBloc projectDetailBloc;
  late final ModerationBloc moderationBloc;
  late final VotingBloc votingBloc;
  late final ContributeBloc contributeBloc;

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
    previewInviteUseCase = PreviewInviteUseCase(projectRepository);
    joinProjectUseCase = JoinProjectUseCase(projectRepository);

    // ── Project Detail Feature ─────────────────────────────────────────────
    projectDetailRemoteDataSource = ProjectDetailRemoteDataSourceImpl(dioClient);
    projectDetailRepository = ProjectDetailRepositoryImpl(projectDetailRemoteDataSource);
    getProjectDetailUseCase = GetProjectDetailUseCase(projectRepository);
    projectActionsRemoteDataSource = ProjectActionsRemoteDataSourceImpl(apiClient: apiClient);
    projectActionsRepository = ProjectActionsRepositoryImpl(remoteDataSource: projectActionsRemoteDataSource);
    openClosureVotingUseCase = OpenClosureVotingUseCase(projectActionsRepository);
    cancelProjectUseCase = CancelProjectUseCase(projectActionsRepository);
    approveMembershipUseCase = ApproveMembershipUseCase(projectActionsRepository);
    rejectMembershipUseCase = RejectMembershipUseCase(projectActionsRepository);
    createInviteUseCase = CreateInviteUseCase(projectActionsRepository);
    assignCoLeaderUseCase = AssignCoLeaderUseCase(projectActionsRepository);
    removeCoLeaderUseCase = RemoveCoLeaderUseCase(projectActionsRepository);
    removeMemberUseCase = RemoveMemberUseCase(projectActionsRepository);
    markDefaultedUseCase = MarkDefaultedUseCase(projectActionsRepository);
    removeForNonRepaymentUseCase = RemoveForNonRepaymentUseCase(projectActionsRepository);
    castClosureVoteUseCase = CastClosureVoteUseCase(projectActionsRepository);
    extendClosureVotingUseCase = ExtendClosureVotingUseCase(projectActionsRepository);
    finalizeClosureVotingUseCase = FinalizeClosureVotingUseCase(projectActionsRepository);
    resolveGoalUseCase = ResolveGoalUseCase(projectActionsRepository);
    extendDeadlineUseCase = ExtendDeadlineUseCase(projectActionsRepository);
    completeProjectUseCase = CompleteProjectUseCase(projectActionsRepository);

    // ── Contributions Feature ──────────────────────────────────────────────
    contributionRemoteDataSource = ContributionRemoteDataSourceImpl(apiClient: apiClient);
    contributionRepository = ContributionRepositoryImpl(remoteDataSource: contributionRemoteDataSource);
    fetchContributionConfigUseCase = FetchContributionConfigUseCase(contributionRepository);
    previewContributionUseCase = PreviewContributionUseCase(contributionRepository);
    confirmContributionUseCase = ConfirmContributionUseCase(contributionRepository);

    // ── Borrow Feature ─────────────────────────────────────────────────────
    borrowRemoteDataSource = BorrowRemoteDataSourceImpl(dioClient);
    borrowRepository = BorrowRepositoryImpl(borrowRemoteDataSource);
    createBorrowRequestUseCase = CreateBorrowRequestUseCase(borrowRepository);
    approveBorrowRequestUseCase = ApproveBorrowRequestUseCase(borrowRepository);
    rejectBorrowRequestUseCase = RejectBorrowRequestUseCase(borrowRepository);

    // ── Unified API Client & Action Handlers ──────────────────────────────
    votingRemoteDataSource = VotingRemoteDataSourceImpl(apiClient: apiClient);
    votingRepository = VotingRepositoryImpl(remoteDataSource: votingRemoteDataSource);
    submitVoteUseCase = SubmitVoteUseCase(repository: votingRepository);
    moderateMemberUseCase = ModerateMemberUseCase(repository: projectActionsRepository);

    // ── New Enterprise Blocs ────────────────────────────────────────────────
    projectDetailBloc = ProjectDetailBloc(repository: projectDetailRepository);
    moderationBloc = ModerationBloc(moderateMemberUseCase: moderateMemberUseCase);
    votingBloc = VotingBloc(submitVoteUseCase: submitVoteUseCase);
    contributeBloc = ContributeBloc(
      configUseCase: fetchContributionConfigUseCase,
      previewUseCase: previewContributionUseCase,
      confirmUseCase: confirmContributionUseCase,
    );
  }
}
