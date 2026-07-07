import 'package:flutter_test/flutter_test.dart';
import 'package:vestie/leader/features/create_project/domain/create_project_image_limits.dart';
import 'package:vestie/leader/features/create_project/presentation/cubit/create_project_cubit.dart';

void main() {
  group('CreateProjectCubit project images', () {
    late CreateProjectCubit cubit;

    setUp(() => cubit = CreateProjectCubit());

    tearDown(() => cubit.close());

    test('addProjectImages caps at maxImages', () {
      cubit.addProjectImages(List.generate(3, (i) => '/tmp/img_$i.jpg'));
      expect(cubit.state.projectImagePaths, hasLength(3));
      expect(cubit.state.canAddMoreProjectImages, isTrue);

      cubit.addProjectImages(List.generate(4, (i) => '/tmp/more_$i.jpg'));
      expect(cubit.state.projectImagePaths, hasLength(5));
      expect(cubit.state.canAddMoreProjectImages, isFalse);
      expect(cubit.state.remainingProjectImageSlots, 0);
    });

    test('addProjectImages is no-op when max reached', () {
      cubit.addProjectImages(
        List.generate(
          CreateProjectImageLimits.maxImages,
          (i) => '/tmp/full_$i.jpg',
        ),
      );

      cubit.addProjectImages(const ['/tmp/extra.jpg']);
      expect(cubit.state.projectImagePaths, hasLength(5));
    });

    test('clearProjectImages empties selection', () {
      cubit.addProjectImages(const ['/tmp/a.jpg', '/tmp/b.jpg']);
      expect(cubit.state.projectImagePaths, hasLength(2));

      cubit.clearProjectImages();
      expect(cubit.state.projectImagePaths, isEmpty);
      expect(cubit.state.canAddMoreProjectImages, isTrue);
    });

    test('removeProjectImageAt re-enables upload slot', () {
      cubit.addProjectImages(
        List.generate(
          CreateProjectImageLimits.maxImages,
          (i) => '/tmp/full_$i.jpg',
        ),
      );
      expect(cubit.state.canAddMoreProjectImages, isFalse);

      cubit.removeProjectImageAt(2);
      expect(cubit.state.projectImagePaths, hasLength(4));
      expect(cubit.state.canAddMoreProjectImages, isTrue);
      expect(cubit.state.remainingProjectImageSlots, 1);
    });
  });
}
