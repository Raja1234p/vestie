import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vestie/core/error/failures.dart';
import 'package:vestie/features/project_detail/domain/entities/project_detail_entity.dart';
import 'package:vestie/features/project_detail/domain/repositories/project_detail_repository.dart';
import 'package:vestie/features/projects/presentation/bloc/project_detail_bloc.dart';
import 'package:vestie/user/features/home/domain/entities/project.dart';

class _MockRepository extends Mock implements ProjectDetailRepository {}

ProjectDetailEntity _project({required String name}) {
  return ProjectDetailEntity(
    id: 'p1',
    name: name,
    category: ProjectCategory.vacations,
    status: ProjectStatus.ongoing,
    goalAmount: 100,
    currentAmount: 0,
    endsIn: '',
    announcement: '',
    members: const [],
    borrowRequests: const [],
  );
}

void main() {
  late _MockRepository repository;

  setUp(() {
    repository = _MockRepository();
    registerFallbackValue(_project(name: 'fallback'));
  });

  test(
    'reloadDetailAndWait during in-flight load waits for queued fresh reload',
    () async {
      var callCount = 0;
      when(
        () => repository.getProjectDetail(projectId: any(named: 'projectId')),
      ).thenAnswer((_) async {
        callCount++;
        await Future<void>.delayed(const Duration(milliseconds: 30));
        return Right(_project(name: 'v$callCount'));
      });

      final bloc = ProjectDetailBloc(repository: repository);
      addTearDown(bloc.close);

      bloc.add(const LoadProjectDetailEvent(projectId: 'p1'));
      final syncFuture = bloc.reloadDetailAndWait('p1');

      await syncFuture;

      expect(callCount, 2);
      final state = bloc.state;
      expect(state, isA<ProjectDetailLoaded>());
      expect((state as ProjectDetailLoaded).project.name, 'v2');
    },
  );

  test('silent refresh failure keeps loaded detail and surfaces message', () async {
    when(
      () => repository.getProjectDetail(projectId: any(named: 'projectId')),
    ).thenAnswer(
      (_) async => Right(_project(name: 'loaded')),
    );

    final bloc = ProjectDetailBloc(repository: repository);
    addTearDown(bloc.close);

    bloc.add(const LoadProjectDetailEvent(projectId: 'p1'));
    await bloc.stream.firstWhere((s) => s is ProjectDetailLoaded);

    when(
      () => repository.getProjectDetail(projectId: any(named: 'projectId')),
    ).thenAnswer(
      (_) async => const Left(ServerFailure('Failed to load project')),
    );

    bloc.add(const LoadProjectDetailEvent(projectId: 'p1'));
    final afterFail = await bloc.stream.firstWhere(
      (s) =>
          s is ProjectDetailLoaded &&
          (s as ProjectDetailLoaded).refreshErrorMessage != null,
    );

    expect(afterFail, isA<ProjectDetailLoaded>());
    final loaded = afterFail as ProjectDetailLoaded;
    expect(loaded.project.name, 'loaded');
    expect(loaded.refreshErrorMessage, 'Failed to load project');
  });
}
