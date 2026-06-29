import 'package:flutter_test/flutter_test.dart';
import 'package:vestie/features/project_detail/data/models/member_activity_response_model.dart';
import 'package:vestie/user/features/vff/domain/entities/vff_enums.dart';

void main() {
  group('MemberActivityResponseModel.fromJson', () {
    test('parses flat member activity payload with photoURL', () {
      const json = {
        'memberId': 'c90f3acd-5837-41c4-84ec-f58c6cf8cf59',
        'memberName': 'test',
        'memberUsername': '@rajakumr',
        'photoURL':
            'https://vestiestorage.blob.core.windows.net/vestie-attachments/profile-pictures/278cbf7e7e284ea0b541afe9b6ab6ba7.jpg?sv=2026-04-06',
        'isCoLeader': false,
        'summary': {
          'totalContributed': 0,
          'contributionCount': 0,
          'totalBorrowed': 0,
          'overdueBorrowCount': 0,
          'totalReturned': 0.0,
        },
        'transactions': <dynamic>[],
        'vffConnectionState': 'None',
        'canSendVffRequest': false,
        'pendingVffRequestId': null,
      };

      final model = MemberActivityResponseModel.fromJson(
        json,
        projectName: 'Trip',
      );
      final entity = model.toEntity();

      expect(model.member.userId, 'c90f3acd-5837-41c4-84ec-f58c6cf8cf59');
      expect(model.member.name, 'test');
      expect(model.member.username, '@rajakumr');
      expect(
        model.member.photoUrl,
        startsWith('https://vestiestorage.blob.core.windows.net'),
      );
      expect(model.isCoLeader, isFalse);
      expect(model.totalContributed, 0);
      expect(model.contributionCount, 0);
      expect(model.transactions, isEmpty);
      expect(entity.vffConnectionState, VffConnectionState.none);
      expect(entity.canSendVffRequest, isFalse);
      expect(entity.pendingVffRequestId, isNull);
      expect(model.member.vffConnectionState, VffConnectionState.none);
      expect(model.penalty, isNull);
    });

    test('parses penalty block and transaction date field', () {
      const json = {
        'memberId': '0c7bdebb-a618-4706-a1e7-43b996f651a8',
        'memberName': 'KOL K.',
        'memberUsername': '',
        'isCoLeader': false,
        'summary': {
          'totalContributed': 500,
          'contributionCount': 1,
          'totalBorrowed': 250,
          'overdueBorrowCount': 1,
          'totalReturned': 0,
        },
        'transactions': [
          {
            'id': '26009949-a233-43e3-a034-2bb89a87f9ee',
            'type': 'Borrow',
            'amount': 250,
            'direction': 'Debit',
            'projectName': 'Penalty Action Test',
            'date': '2026-06-24T13:04:11+00:00',
          },
        ],
        'penalty': {
          'borrowedAmount': 250,
          'breakdown': {
            'dueAmount': 250,
            'overdueDate': '2026-06-22T13:11:01+00:00',
            'penaltyAmount': 20,
            'totalOwed': 270,
          },
          'currency': 'USD',
          'borrowRequestId': '26009949-a233-43e3-a034-2bb89a87f9ee',
          'canMarkAsDefaulted': true,
          'canRemoveMember': true,
        },
        'vffConnectionState': 'Connected',
        'canSendVffRequest': false,
        'pendingVffRequestId': null,
      };

      final model = MemberActivityResponseModel.fromJson(
        json,
        projectName: 'Fallback',
      );
      final entity = model.toEntity();

      expect(model.penalty, isNotNull);
      expect(model.penalty!.borrowedAmount, 250);
      expect(model.penalty!.breakdown.dueAmount, 250);
      expect(model.penalty!.breakdown.penaltyAmount, 20);
      expect(model.penalty!.breakdown.totalOwed, 270);
      expect(model.penalty!.canMarkAsDefaulted, isTrue);
      expect(model.penalty!.canRemoveMember, isTrue);
      expect(model.penalty!.borrowRequestId,
          '26009949-a233-43e3-a034-2bb89a87f9ee');
      expect(entity.penalty?.breakdown.overdueDateUtc, isNotNull);
      expect(model.transactions, hasLength(1));
      expect(model.transactions.first.displayDate, isNotEmpty);
      expect(model.transactions.first.title, contains('Penalty Action Test'));
    });
  });
}
