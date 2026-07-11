import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vestie/features/project_detail/domain/entities/project_detail_entity.dart';
import 'package:vestie/features/project_detail/domain/repositories/project_detail_repository.dart';
import 'package:vestie/features/project_detail/domain/usecases/get_active_closure_vote_usecase.dart';
import 'package:vestie/features/project_pot/domain/entities/project_pot_entity.dart';
import 'package:vestie/features/project_pot/domain/repositories/project_pot_repository.dart';
import 'package:vestie/features/project_pot/domain/usecases/get_project_pot_use_case.dart';
import 'package:vestie/features/projects/presentation/bloc/project_detail_bloc.dart';
import 'package:vestie/user/features/home/domain/entities/project.dart';

class _MockRepository extends Mock implements ProjectDetailRepository {}

class _MockPotRepository extends Mock implements ProjectPotRepository {}

class _MockActiveVoteUseCase extends Mock implements GetActiveClosureVoteUseCase {}

ProjectDetailEntity _completedProject() {
  return ProjectDetailEntity(
    id: 'p1',
    name: 'Trip',
    category: ProjectCategory.investment,
    status: ProjectStatus.completed,
    goalAmount: 5555,
    currentAmount: 555.55,
    totalContributed: 555.55,
    endsIn: '',
    announcement: '',
    members: const [],
    borrowRequests: const [],
    displayStatusLabel: 'Completed',
    projectLifecycleState: 'completed',
  );
}

void main() {
  late _MockRepository repository;
  late _MockPotRepository potRepository;
  late GetProjectPotUseCase potUseCase;
  late _MockActiveVoteUseCase activeVoteUseCase;

  setUp(() {
    repository = _MockRepository();
    potRepository = _MockPotRepository();
    potUseCase = GetProjectPotUseCase(potRepository);
    activeVoteUseCase = _MockActiveVoteUseCase();

    registerFallbackValue(_completedProject());
  });

  test(
    'completed profile read-only load skips pot and active closure vote',
    () async {
      when(
        () => repository.getProjectDetail(
          projectId: any(named: 'projectId'),
          announcementsPageSize: any(named: 'announcementsPageSize'),
          invitesPageSize: any(named: 'invitesPageSize'),
        ),
      ).thenAnswer((_) async => Right(_completedProject()));

      when(() => potRepository.getPot(any()))
          .thenAnswer((_) async => const Right(
                ProjectPotEntity(
                  potAmount: 0,
                  contributorCount: 1,
                  vffMemberUserIds: [],
                ),
              ));

      when(() => activeVoteUseCase.call(any()))
          .thenAnswer((_) async => const Right(null));

      final bloc = ProjectDetailBloc(
        repository: repository,
        getProjectPotUseCase: potUseCase,
        getActiveClosureVoteUseCase: activeVoteUseCase,
        completedProjectsProfileReadOnly: true,
      );
      addTearDown(bloc.close);

      bloc.add(const LoadProjectDetailEvent(projectId: 'p1'));
      await bloc.stream.firstWhere((s) => s is ProjectDetailLoaded);

      verify(
        () => repository.getProjectDetail(
          projectId: 'p1',
          announcementsPageSize: 1,
          invitesPageSize: 1,
        ),
      ).called(1);
      verifyNever(() => potRepository.getPot(any()));
      verifyNever(() => activeVoteUseCase.call(any()));
    },
  );

  test('normal detail load still fetches pot and active closure vote', () async {
    when(
      () => repository.getProjectDetail(projectId: any(named: 'projectId')),
    ).thenAnswer((_) async => Right(_completedProject()));

    when(() => potRepository.getPot(any())).thenAnswer(
      (_) async => const Right(
        ProjectPotEntity(
          potAmount: 0,
          contributorCount: 1,
          vffMemberUserIds: [],
        ),
      ),
    );

    when(() => activeVoteUseCase.call(any())).thenAnswer((_) async => const Right(null));

    final bloc = ProjectDetailBloc(
      repository: repository,
      getProjectPotUseCase: potUseCase,
      getActiveClosureVoteUseCase: activeVoteUseCase,
    );
    addTearDown(bloc.close);

    bloc.add(const LoadProjectDetailEvent(projectId: 'p1'));
    await bloc.stream.firstWhere((s) => s is ProjectDetailLoaded);

    verify(() => potRepository.getPot('p1')).called(1);
    verify(() => activeVoteUseCase.call('p1')).called(1);
  });
}
