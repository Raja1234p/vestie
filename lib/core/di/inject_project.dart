import '../../features/project_announcements/data/datasources/project_announcements_remote_data_source.dart';
import '../../features/project_announcements/data/repositories/project_announcements_repository_impl.dart';
import '../../features/project_announcements/domain/usecases/project_announcements_usecases.dart';
import '../../features/project_detail/data/datasources/project_actions_remote_data_source.dart';
import '../../features/project_detail/data/datasources/project_detail_remote_data_source_impl.dart';
import '../../features/project_detail/data/datasources/voting_remote_data_source.dart';
import '../../features/project_detail/data/repositories/project_actions_repository_impl.dart';
import '../../features/project_detail/data/repositories/project_detail_repository_impl.dart';
import '../../features/project_detail/data/repositories/voting_repository_impl.dart';
import '../../features/project_detail/domain/usecases/get_member_activity_usecase.dart';
import '../../features/project_detail/domain/usecases/list_pending_join_requests_usecase.dart';
import '../../features/project_detail/domain/usecases/moderate_member_usecase.dart';
import '../../features/project_detail/domain/usecases/project_actions_usecases.dart';
import '../../features/project_detail/domain/usecases/submit_vote_usecase.dart';
import '../../features/project_detail/presentation/bloc/moderation_bloc.dart';
import '../../features/project_detail/presentation/bloc/voting_bloc.dart';
import '../../features/project_pot/data/datasources/project_pot_remote_data_source.dart';
import '../../features/project_pot/data/repositories/project_pot_repository_impl.dart';
import '../../features/project_pot/domain/usecases/get_project_pot_use_case.dart';
import '../../features/projects/data/datasources/project_remote_data_source.dart';
import '../../features/projects/data/datasources/projects_remote_data_source_impl.dart';
import '../../features/projects/data/repositories/project_repository_impl.dart';
import '../../features/projects/data/repositories/projects_repository_impl.dart';
import '../../features/projects/domain/usecases/create_and_launch_project_use_case.dart';
import '../../features/projects/domain/usecases/create_project_use_case.dart';
import '../../features/projects/domain/usecases/get_project_detail_usecase.dart';
import '../../features/projects/domain/usecases/join_project_usecase.dart';
import '../../features/projects/domain/usecases/list_projects_use_case.dart';
import '../../features/projects/domain/usecases/preview_invite_usecase.dart';
import 'service_locator.dart';

/// Registers projects, project detail, actions, pot, announcements, voting.
void registerProjectDependencies(ServiceLocator sl) {
  sl.projectsRemoteDataSource = ProjectsRemoteDataSourceImpl(sl.dioClient);
  sl.projectsRepository =
      ProjectsRepositoryImpl(sl.projectsRemoteDataSource);
  sl.projectRemoteDataSource =
      ProjectRemoteDataSourceImpl(apiClient: sl.apiClient);
  sl.projectRepository = ProjectRepositoryImpl(
    remoteDataSource: sl.projectRemoteDataSource,
    localDataSource: sl.projectLocalDataSource,
    networkInfo: sl.networkInfo,
  );
  sl.listProjectsUseCase = ListProjectsUseCase(sl.projectsRepository);
  sl.createProjectUseCase = CreateProjectUseCase(sl.projectsRepository);
  sl.createAndLaunchProjectUseCase =
      CreateAndLaunchProjectUseCase(sl.projectsRepository);
  sl.previewInviteUseCase = PreviewInviteUseCase(sl.projectRepository);
  sl.joinProjectUseCase = JoinProjectUseCase(sl.projectRepository);

  sl.projectDetailRemoteDataSource =
      ProjectDetailRemoteDataSourceImpl(sl.dioClient);
  sl.projectDetailRepository =
      ProjectDetailRepositoryImpl(sl.projectDetailRemoteDataSource);
  sl.getProjectDetailUseCase = GetProjectDetailUseCase(sl.projectRepository);
  sl.projectActionsRemoteDataSource =
      ProjectActionsRemoteDataSourceImpl(apiClient: sl.apiClient);
  sl.projectActionsRepository = ProjectActionsRepositoryImpl(
    remoteDataSource: sl.projectActionsRemoteDataSource,
  );
  sl.openClosureVotingUseCase =
      OpenClosureVotingUseCase(sl.projectActionsRepository);
  sl.openStopContributionsVotingUseCase =
      OpenStopContributionsVotingUseCase(sl.projectActionsRepository);
  sl.cancelProjectUseCase = CancelProjectUseCase(sl.projectActionsRepository);
  sl.leaveProjectUseCase = LeaveProjectUseCase(sl.projectActionsRepository);
  sl.listPendingJoinRequestsUseCase =
      ListPendingJoinRequestsUseCase(sl.projectActionsRepository);
  sl.approveMembershipUseCase =
      ApproveMembershipUseCase(sl.projectActionsRepository);
  sl.rejectMembershipUseCase =
      RejectMembershipUseCase(sl.projectActionsRepository);
  sl.createInviteUseCase = CreateInviteUseCase(sl.projectActionsRepository);
  sl.assignCoLeaderUseCase =
      AssignCoLeaderUseCase(sl.projectActionsRepository);
  sl.removeCoLeaderUseCase =
      RemoveCoLeaderUseCase(sl.projectActionsRepository);
  sl.updateCoLeaderRoleUseCase =
      UpdateCoLeaderRoleUseCase(sl.projectActionsRepository);
  sl.removeMemberUseCase = RemoveMemberUseCase(sl.projectActionsRepository);
  sl.getMemberActivityUseCase =
      GetMemberActivityUseCase(sl.projectActionsRepository);
  sl.markDefaultedUseCase = MarkDefaultedUseCase(sl.projectActionsRepository);
  sl.removeForNonRepaymentUseCase =
      RemoveForNonRepaymentUseCase(sl.projectActionsRepository);
  sl.castClosureVoteUseCase =
      CastClosureVoteUseCase(sl.projectActionsRepository);
  sl.extendClosureVotingUseCase =
      ExtendClosureVotingUseCase(sl.projectActionsRepository);
  sl.finalizeClosureVotingUseCase =
      FinalizeClosureVotingUseCase(sl.projectActionsRepository);
  sl.resolveGoalUseCase = ResolveGoalUseCase(sl.projectActionsRepository);
  sl.extendDeadlineUseCase =
      ExtendDeadlineUseCase(sl.projectActionsRepository);
  sl.completeProjectUseCase =
      CompleteProjectUseCase(sl.projectActionsRepository);

  sl.projectPotRemoteDataSource =
      ProjectPotRemoteDataSourceImpl(apiClient: sl.apiClient);
  sl.projectPotRepository =
      ProjectPotRepositoryImpl(remoteDataSource: sl.projectPotRemoteDataSource);
  sl.getProjectPotUseCase = GetProjectPotUseCase(sl.projectPotRepository);

  sl.projectAnnouncementsRemoteDataSource =
      ProjectAnnouncementsRemoteDataSourceImpl(apiClient: sl.apiClient);
  sl.projectAnnouncementsRepository = ProjectAnnouncementsRepositoryImpl(
    remoteDataSource: sl.projectAnnouncementsRemoteDataSource,
  );
  sl.createProjectAnnouncementUseCase =
      CreateProjectAnnouncementUseCase(sl.projectAnnouncementsRepository);
  sl.deleteProjectAnnouncementUseCase =
      DeleteProjectAnnouncementUseCase(sl.projectAnnouncementsRepository);

  sl.votingRemoteDataSource =
      VotingRemoteDataSourceImpl(apiClient: sl.apiClient);
  sl.votingRepository =
      VotingRepositoryImpl(remoteDataSource: sl.votingRemoteDataSource);
  sl.submitVoteUseCase = SubmitVoteUseCase(repository: sl.votingRepository);
  sl.moderateMemberUseCase =
      ModerateMemberUseCase(repository: sl.projectActionsRepository);

  sl.moderationBloc =
      ModerationBloc(moderateMemberUseCase: sl.moderateMemberUseCase);
  sl.votingBloc = VotingBloc(submitVoteUseCase: sl.submitVoteUseCase);
}
