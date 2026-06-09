import 'package:flutter_test/flutter_test.dart';
import 'package:vestie/app/router/route_args/project_detail_flow_args.dart';
import 'package:vestie/features/project_detail/domain/entities/borrow_request_entity.dart';
import 'package:vestie/user/features/borrow/data/models/my_borrow_screen_model.dart';
import 'package:vestie/user/features/borrow/presentation/cubit/my_borrow_request_cubit.dart';

void main() {
  group('MyBorrowScreenModel', () {
    test('RequestSent currentRequest maps to pending entity', () {
      final model = MyBorrowScreenModel.fromJson({
        'currentRequest': {
          'id': 'ede8076f-a3d1-42b0-81c8-1dfeac15beca',
          'requestedAmount': 0.1,
          'currency': 'USD',
          'status': 'RequestSent',
          'statusDisplay': 'Pending – waiting for decision',
          'memberVotesAgree': 0,
          'memberVotesDisagree': 0,
          'dueAtUtc': '2026-07-09T11:20:21+00:00',
          'dueByDisplay': 'July 9, 2026 (30 days)',
          'createdAtUtc': '2026-06-09T11:20:21+00:00',
        },
        'history': [],
      });

      final entity = model.currentRequest?.toEntity();
      expect(entity, isNotNull);
      expect(entity!.isPending, isTrue);
      expect(entity.status, 'RequestSent');
    });

    test('approved borrow in history when currentRequest is null', () {
      final model = MyBorrowScreenModel.fromJson({
        'currentRequest': null,
        'history': [
          {
            'id': 'daa65aaf-ac17-4e64-a908-b0aa473ce038',
            'requestedAmount': 5.0,
            'currency': 'USD',
            'status': 'Approved',
            'statusDisplay': 'Approved',
            'createdAtUtc': '2026-06-09T09:05:19+00:00',
          },
        ],
      });

      expect(model.currentRequest, isNull);
      expect(model.history, hasLength(1));
      expect(model.history.first.id, 'daa65aaf-ac17-4e64-a908-b0aa473ce038');
      expect(model.history.first.status, 'Approved');

      final entry = model.history.first.toHistoryEntry();
      expect(entry.isRepayable, isTrue);
      expect(entry.isApproved, isTrue);
    });

    test('cancelled history row is not labelled rejected', () {
      final model = MyBorrowScreenModel.fromJson({
        'currentRequest': null,
        'history': [
          {
            'id': 'ede8076f-a3d1-42b0-81c8-1dfeac15beca',
            'requestedAmount': 0.1,
            'currency': 'USD',
            'status': 'Cancelled',
            'statusDisplay': 'Cancelled',
            'createdAtUtc': '2026-06-09T11:20:21+00:00',
          },
        ],
      });

      final entry = model.history.first.toHistoryEntry();
      expect(entry.isApproved, isFalse);
      expect(entry.isCancelled, isTrue);
      expect(entry.badgeKind, MyBorrowHistoryBadgeKind.cancelled);
      expect(entry.statusDisplay, 'Cancelled');
    });
  });

  group('MyBorrowRequestCubit.resolveRepayableRequestId', () {
    test('uses history id when currentRequest is null', () {
      final id = MyBorrowRequestCubit.resolveRepayableRequestId(
        current: null,
        history: const [
          MyBorrowHistoryEntry(
            id: 'daa65aaf-ac17-4e64-a908-b0aa473ce038',
            amount: 5,
            dateLabel: 'Jun 9',
            isApproved: true,
            status: 'Approved',
          ),
        ],
      );

      expect(id, 'daa65aaf-ac17-4e64-a908-b0aa473ce038');
    });

    test('skips non-repayable history rows', () {
      final id = MyBorrowRequestCubit.resolveRepayableRequestId(
        current: null,
        history: const [
          MyBorrowHistoryEntry(
            id: 'rejected-1',
            amount: 5,
            dateLabel: 'Jun 1',
            isApproved: false,
            status: 'Rejected',
          ),
          MyBorrowHistoryEntry(
            id: 'disbursed-1',
            amount: 10,
            dateLabel: 'Jun 9',
            isApproved: true,
            status: 'Disbursed',
          ),
        ],
      );

      expect(id, 'disbursed-1');
    });
  });
}
