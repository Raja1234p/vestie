import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vestie/core/widgets/common/project_cover_image.dart';
import 'package:vestie/user/features/home/domain/entities/project.dart';

void main() {
  group('ProjectCoverImage', () {
    testWidgets('shows category asset when cover url is empty', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ProjectCoverImage(
              coverImageUrl: null,
              category: ProjectCategory.vacations,
              width: 100,
              height: 69,
            ),
          ),
        ),
      );

      expect(find.byType(ProjectCoverImage), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);
    });
  });
}
