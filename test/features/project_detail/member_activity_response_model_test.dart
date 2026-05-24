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
    });
  });
}
