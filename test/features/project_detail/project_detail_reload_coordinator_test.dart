import 'package:flutter_test/flutter_test.dart';
import 'package:vestie/features/project_detail/presentation/project_detail_reload_coordinator.dart';
import 'package:vestie/features/projects/presentation/bloc/project_detail_bloc.dart';
import 'package:vestie/features/project_detail/domain/repositories/project_detail_repository.dart';
import 'package:mocktail/mocktail.dart';

class _MockRepository extends Mock implements ProjectDetailRepository {}

void main() {
  group('ProjectDetailReloadCoordinator', () {
    test('reload without registration does not throw', () async {
      await ProjectDetailReloadCoordinator.reload('missing-project');
    });

    test('unregister only removes matching bloc instance', () async {
      final repository = _MockRepository();
      final bloc = ProjectDetailBloc(repository: repository);
      addTearDown(bloc.close);

      ProjectDetailReloadCoordinator.register('p1', bloc);
      ProjectDetailReloadCoordinator.unregister('p1', bloc);

      await ProjectDetailReloadCoordinator.reload('p1');
    });
  });
}
