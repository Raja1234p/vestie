import 'package:flutter_test/flutter_test.dart';

import 'package:vestie/features/project_detail/data/models/cancel_project_response_model.dart';

void main() {
  group('CancelProjectResponseModel', () {
    test('parses Week 10 cancel refund summary', () {
      const json = {
        'projectId': 'p1',
        'status': 'Cancelled',
        'totalRefunded': 4500.00,
        'refundedMemberCount': 3,
        'defaultedMemberCount': 1,
        'defaultedMembersReceived': 0.00,
      };

      final entity = CancelProjectResponseModel.fromJson(json).toEntity();

      expect(entity.projectId, 'p1');
      expect(entity.status, 'Cancelled');
      expect(entity.totalRefunded, 4500);
      expect(entity.refundedMemberCount, 3);
      expect(entity.defaultedMemberCount, 1);
      expect(entity.defaultedMembersReceived, 0);
    });
  });
}
