import 'package:flutter_test/flutter_test.dart';
import 'package:vestie/user/features/vff/presentation/cubit/user_vff_inbox_mutation_guard_mixin.dart';
import 'package:vestie/user/features/vff/presentation/models/user_vff_inbox_action.dart';

class _GuardHarness with UserVffInboxMutationGuardMixin {}

void main() {
  group('UserVffInboxMutationGuardMixin', () {
    test('allows only one in-flight mutation', () {
      final guard = _GuardHarness();

      expect(guard.beginInboxMutation(), isTrue);
      expect(guard.beginInboxMutation(), isFalse);

      guard.endInboxMutation();
      expect(guard.beginInboxMutation(), isTrue);
    });
  });

  const acting = UserVffInboxRowAction(
    itemId: 'req-1',
    kind: UserVffInboxItemKind.vffRequest,
    isAccept: true,
  );

  group('UserVffInboxRowActionX', () {
    test('primaryLoading is true only for matching accept row', () {
      expect(
        acting.primaryLoading('req-1', UserVffInboxItemKind.vffRequest),
        isTrue,
      );
      expect(
        acting.primaryLoading('req-2', UserVffInboxItemKind.vffRequest),
        isFalse,
      );
      expect(
        acting.primaryLoading('req-1', UserVffInboxItemKind.projectInvite),
        isFalse,
      );
    });

    test('declineLoading is true only for matching decline row', () {
      const declining = UserVffInboxRowAction(
        itemId: 'req-1',
        kind: UserVffInboxItemKind.vffRequest,
        isAccept: false,
      );

      expect(
        declining.declineLoading('req-1', UserVffInboxItemKind.vffRequest),
        isTrue,
      );
      expect(
        declining.declineLoading('req-1', UserVffInboxItemKind.projectInvite),
        isFalse,
      );
      expect(acting.declineLoading('req-1', UserVffInboxItemKind.vffRequest),
          isFalse);
    });

    test('blocksRow is true only for the active row', () {
      expect(
        acting.blocksRow('req-1', UserVffInboxItemKind.vffRequest),
        isTrue,
      );
      expect(
        acting.blocksRow('req-2', UserVffInboxItemKind.vffRequest),
        isFalse,
      );
      const UserVffInboxRowAction? idle = null;
      expect(
        idle.blocksRow('req-1', UserVffInboxItemKind.vffRequest),
        isFalse,
      );
    });
  });
}
