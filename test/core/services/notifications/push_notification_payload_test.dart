import 'package:flutter_test/flutter_test.dart';
import 'package:vestie/app/router/app_routes.dart';
import 'package:vestie/app/router/route_args/user_vff_flow_args.dart';
import 'package:vestie/core/services/notifications/push_notification_payload.dart';
import 'package:vestie/core/services/notifications/push_notification_router.dart';

void main() {
  group('PushNotificationPayload.fromData — VFF request', () {
    const metadata = {
      'projectId': 'b4de3170-e378-4a61-902c-582ca0329a9a',
      'requestId': '156e2bbc-e288-440a-9d1c-975cef07d852',
      'senderUserId': '331e733d-9d1f-4570-bbec-e1b5703747d5',
    };

    test('parses VffRequestReceived metadata JSON string', () {
      final payload = PushNotificationPayload.fromData({
        'type': 'VffRequestReceived',
        'title': 'VFF Request Received',
        'body':
            'aistudio aistudio wants to connect with you as a Vestie Financial Friend.',
        'metadata':
            '{"projectId":"${metadata['projectId']}","requestId":"${metadata['requestId']}","senderUserId":"${metadata['senderUserId']}"}',
      });

      expect(payload.type, PushNotificationType.vffRequestReceived);
      expect(payload.tapTarget, PushNotificationTapTarget.vffHubRequests);
      expect(payload.requestId, metadata['requestId']);
      expect(payload.senderUserId, metadata['senderUserId']);
      expect(payload.projectId, metadata['projectId']);
    });

    test('maps VFFRequestReceived alias', () {
      final payload = PushNotificationPayload.fromData({
        'type': 'VFFRequestReceived',
        'title': 'VFF Request Received',
        'body': 'wants to connect',
      });
      expect(payload.type, PushNotificationType.vffRequestReceived);
    });

    test('infers VFF from title when type is missing', () {
      final payload = PushNotificationPayload.fromData({
        'title': 'VFF Request Received',
        'body':
            'aistudio wants to connect with you as a Vestie Financial Friend.',
      });
      expect(payload.type, PushNotificationType.vffRequestReceived);
      expect(payload.tapTarget, PushNotificationTapTarget.vffHubRequests);
    });
  });

  group('PushNotificationPayload.fromData — join request', () {
    const metadata = {
      'projectId': 'd038a71f-48e3-4bf3-a49b-94dc38b61041',
      'projectName': 'ggg',
      'requesterUserId': '331e733d-9d1f-4570-bbec-e1b5703747d5',
      'membershipId': '1070e5fa-1949-414c-b23f-54ff3f678bf9',
    };

    test('parses JoinRequest metadata JSON string', () {
      final payload = PushNotificationPayload.fromData({
        'type': 'JoinRequest',
        'title': 'New Join Request',
        'body': 'aistudio aistudio has requested to join ggg.',
        'metadata':
            '{"projectId":"${metadata['projectId']}","projectName":"${metadata['projectName']}","requesterUserId":"${metadata['requesterUserId']}","membershipId":"${metadata['membershipId']}"}',
      });

      expect(payload.type, PushNotificationType.joinRequest);
      expect(payload.tapTarget, PushNotificationTapTarget.joinRequests);
      expect(payload.projectId, metadata['projectId']);
      expect(payload.projectName, metadata['projectName']);
      expect(payload.membershipId, metadata['membershipId']);
      expect(payload.requesterUserId, metadata['requesterUserId']);
    });

    test('maps JoinRequestReceived alias', () {
      final payload = PushNotificationPayload.fromData({
        'type': 'JoinRequestReceived',
        'title': 'New Join Request',
        'body': 'requested to join',
        'metadata': '{"projectId":"abc"}',
      });
      expect(payload.type, PushNotificationType.joinRequest);
      expect(payload.projectId, 'abc');
    });

    test('infers join request from title when type is missing', () {
      final payload = PushNotificationPayload.fromData({
        'title': 'New Join Request',
        'body': 'aistudio has requested to join ggg.',
        'metadata': '{"projectId":"p1"}',
      });
      expect(payload.type, PushNotificationType.joinRequest);
      expect(payload.tapTarget, PushNotificationTapTarget.joinRequests);
    });

    test('join-request tap is not category-specific', () {
      // Payload has no category — router always opens join-requests, not
      // vacation vs investment detail.
      final payload = PushNotificationPayload.fromData({
        'type': 'JoinRequest',
        'title': 'New Join Request',
        'body': 'requested to join',
        'metadata': '{"projectId":"any-id"}',
      });
      expect(payload.tapTarget, isNot(PushNotificationTapTarget.projectDetail));
      expect(payload.tapTarget, PushNotificationTapTarget.joinRequests);
      expect(AppRoutes.joinRequests, '/project/join-requests');
    });
  });

  group('existing types stay on their screens', () {
    test('ProjectCreated still opens project detail', () {
      final payload = PushNotificationPayload.fromData({
        'type': 'ProjectCreated',
        'title': 'Project Created',
        'body': 'created',
        'payload': '{"projectId":"p1","projectName":"ddd"}',
      });
      expect(payload.type, PushNotificationType.projectCreated);
      expect(payload.tapTarget, PushNotificationTapTarget.projectDetail);
    });

    test('WithdrawalFailed still opens wallet', () {
      final payload = PushNotificationPayload.fromData({
        'type': 'WithdrawalFailed',
        'title': 'Withdrawal Failed',
        'body': 'failed',
        'metadata': '{"withdrawalId":"w1","amount":500}',
      });
      expect(payload.tapTarget, PushNotificationTapTarget.walletTab);
    });

    test('unknown type still falls back to Home', () {
      final payload = PushNotificationPayload.fromData({
        'type': 'SomethingNew',
        'title': 'Hello',
        'body': 'unrelated copy',
      });
      expect(payload.type, PushNotificationType.unknown);
      expect(payload.tapTarget, PushNotificationTapTarget.homeTab);
    });
  });

  group('VFF hub route args', () {
    test('requestsTab opens the Requests tab without demo hub data', () {
      final args = UserVffHubRouteArgs.requestsTab();
      expect(args.initialTabIndex, UserVffHubRouteArgs.requestsTabIndex);
      expect(args.hub, isNull);
      expect(AppRoutes.userVffMain, '/user/vff');
    });
  });

  group('PushNotificationRouter cold-start gate', () {
    test('blocks splash so Home go cannot replace VFF / join-requests', () {
      expect(PushNotificationRouter.isLaunchRouteBlocking(AppRoutes.splash), isTrue);
      expect(PushNotificationRouter.isLaunchRouteBlocking(''), isTrue);
      expect(
        PushNotificationRouter.isLaunchRouteBlocking(AppRoutes.agreement),
        isTrue,
      );
      expect(
        PushNotificationRouter.isLaunchRouteBlocking(AppRoutes.login),
        isTrue,
      );
    });

    test('allows dashboard and VFF after splash has finished', () {
      expect(
        PushNotificationRouter.isLaunchRouteBlocking(AppRoutes.dashboard),
        isFalse,
      );
      expect(
        PushNotificationRouter.isLaunchRouteBlocking(AppRoutes.userVffMain),
        isFalse,
      );
      expect(
        PushNotificationRouter.isLaunchRouteBlocking(AppRoutes.joinRequests),
        isFalse,
      );
    });
  });
}
