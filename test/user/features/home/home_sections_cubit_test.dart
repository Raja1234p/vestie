import 'package:flutter_test/flutter_test.dart';

import 'package:vestie/user/features/home/presentation/cubit/home_sections_cubit.dart';

void main() {
  group('HomeSectionsCubit', () {
    late HomeSectionsCubit cubit;

    setUp(() => cubit = HomeSectionsCubit());
    tearDown(() => cubit.close());

    test('starts with both sections expanded', () {
      expect(cubit.state.myProjectsExpanded, isTrue);
      expect(cubit.state.joinedProjectsExpanded, isTrue);
    });

    test('toggleMyProjects flips myProjectsExpanded only', () {
      cubit.toggleMyProjects();
      expect(cubit.state.myProjectsExpanded, isFalse);
      expect(cubit.state.joinedProjectsExpanded, isTrue);

      cubit.toggleMyProjects();
      expect(cubit.state.myProjectsExpanded, isTrue);
    });

    test('toggleJoined flips joinedProjectsExpanded only', () {
      cubit.toggleJoined();
      expect(cubit.state.joinedProjectsExpanded, isFalse);
      expect(cubit.state.myProjectsExpanded, isTrue);
    });

    test('states are equatable for buildWhen', () {
      final first = cubit.state;
      cubit.toggleMyProjects();
      expect(cubit.state, isNot(equals(first)));
    });
  });
}
