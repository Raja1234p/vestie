import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vestie/core/domain/entities/paginated_result.dart';
import 'package:vestie/core/domain/entities/pagination_info.dart';
import 'package:vestie/features/projects/domain/usecases/list_projects_use_case.dart';
import 'package:vestie/features/projects/domain/usecases/join_project_usecase.dart';
import 'package:vestie/user/features/discover/presentation/cubit/discover_cubit.dart';
import 'package:vestie/user/features/home/domain/entities/project.dart';

class _MockListProjectsUseCase extends Mock implements ListProjectsUseCase {}

class _MockJoinProjectUseCase extends Mock implements JoinProjectUseCase {}

void main() {
  late _MockListProjectsUseCase listProjects;
  late _MockJoinProjectUseCase joinProject;

  const projects = [
    Project(
      id: 'p1',
      name: 'Beach Trip',
      category: ProjectCategory.vacations,
      status: ProjectStatus.ongoing,
      relation: ProjectRelation.joined,
    ),
    Project(
      id: 'p2',
      name: 'Emergency Fund',
      category: ProjectCategory.emergency,
      status: ProjectStatus.ongoing,
      relation: ProjectRelation.joined,
    ),
  ];

  setUp(() {
    listProjects = _MockListProjectsUseCase();
    joinProject = _MockJoinProjectUseCase();

    when(() => listProjects(scope: any(named: 'scope')))
        .thenAnswer((_) async => Right(PaginatedResult.singlePage(projects)));
  });

  DiscoverCubit createCubit() => DiscoverCubit(
        listProjectsUseCase: listProjects,
        joinProjectUseCase: joinProject,
      );

  group('DiscoverCubit search', () {
    test('clearSearch restores projects after a no-match query', () async {
      final cubit = createCubit();
      addTearDown(cubit.close);

      cubit.onTabActivated();
      await Future<void>.delayed(Duration.zero);

      cubit.search('does-not-exist');
      expect(cubit.state.filtered, isEmpty);

      cubit.clearSearch();
      expect(cubit.state.searchQuery, '');
      expect(cubit.state.filtered, projects);
    });

    test('onTabDeactivated clears stale search when leaving Discover tab', () async {
      final cubit = createCubit();
      addTearDown(cubit.close);

      cubit.onTabActivated();
      await Future<void>.delayed(Duration.zero);

      cubit.search('does-not-exist');
      expect(cubit.state.filtered, isEmpty);

      cubit.onTabDeactivated();
      expect(cubit.state.searchQuery, '');
      expect(cubit.state.filtered, projects);
    });
  });
}
