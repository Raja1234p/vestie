import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vestie/app/router/route_args/project_joined_success_route_args.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/features/projects/presentation/pages/project_joined_success_screen.dart';

void main() {
  group('ProjectJoinedSuccessScreen', () {
    testWidgets('immediate join shows Project Joined copy', (tester) async {
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(390, 844),
          builder: (_, __) => MaterialApp(
            home: ProjectJoinedSuccessScreen(
              args: ProjectJoinedSuccessRouteArgs(
                projectId: 'p1',
                projectName: 'Crypto Growth Pool',
              ),
            ),
          ),
        ),
      );

      expect(find.text(AppStrings.projectJoinedSuccessTitle), findsOneWidget);
      expect(
        find.text(AppStrings.projectJoinedWelcomeSubtitle('Crypto Growth Pool')),
        findsOneWidget,
      );
      expect(find.text(AppStrings.btnOpenProject), findsOneWidget);
    });

    testWidgets('pending from discover shows Done', (tester) async {
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(390, 844),
          builder: (_, __) => MaterialApp(
            home: ProjectJoinedSuccessScreen(
              args: ProjectJoinedSuccessRouteArgs(
                projectId: 'p1',
                projectName: 'Family Trip',
                kind: ProjectJoinSuccessKind.requestPending,
              ),
            ),
          ),
        ),
      );

      expect(find.text(AppStrings.projectJoinRequestSentTitle), findsOneWidget);
      expect(find.text(AppStrings.projectJoinRequestSentSubtitle), findsOneWidget);
      expect(find.text(AppStrings.btnDone), findsOneWidget);
    });

    testWidgets('pending from invite shows Done to home', (tester) async {
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(390, 844),
          builder: (_, __) => MaterialApp(
            home: ProjectJoinedSuccessScreen(
              args: ProjectJoinedSuccessRouteArgs(
                projectId: 'p1',
                projectName: 'Family Trip',
                kind: ProjectJoinSuccessKind.requestPending,
                fromInviteLink: true,
              ),
            ),
          ),
        ),
      );

      expect(find.text(AppStrings.projectJoinRequestSentTitle), findsOneWidget);
      expect(find.text(AppStrings.btnDone), findsOneWidget);
      expect(find.text(AppStrings.btnOpenProject), findsNothing);
    });
  });
}
