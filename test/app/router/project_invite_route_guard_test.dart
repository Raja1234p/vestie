import 'package:flutter_test/flutter_test.dart';
import 'package:vestie/app/router/app_routes.dart';
import 'package:vestie/app/router/project_invite_route_guard.dart';

void main() {
  group('ProjectInviteRouteGuard.redirectForInvite', () {
    test('sends signed-out users on /join to login', () {
      expect(
        ProjectInviteRouteGuard.redirectForInvite(
          uri: Uri.parse('https://vestie.app/join/summer-squad'),
          pathParameters: const {'inviteCode': 'summer-squad'},
          isAuthenticated: false,
        ),
        AppRoutes.login,
      );
    });

    test('allows signed-in users on /join', () {
      expect(
        ProjectInviteRouteGuard.redirectForInvite(
          uri: Uri.parse('https://vestie.app/join/summer-squad'),
          pathParameters: const {'inviteCode': 'summer-squad'},
          isAuthenticated: true,
        ),
        isNull,
      );
    });

    test('normalizes vestie scheme uri to /join path', () {
      expect(
        ProjectInviteRouteGuard.redirectForInvite(
          uri: Uri.parse('vestie://join/summer-squad'),
          pathParameters: const {},
          isAuthenticated: true,
        ),
        AppRoutes.projectInvitation('summer-squad'),
      );
    });
  });
}
