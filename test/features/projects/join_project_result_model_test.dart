import 'package:flutter_test/flutter_test.dart';
import 'package:vestie/features/projects/data/models/join_project_result_model.dart';

void main() {
  group('JoinProjectResultModel.fromJson', () {
    test('parses flat pending membership response from POST /projects/join', () {
      final model = JoinProjectResultModel.fromJson({
        'projectId': 'e20ebd9d-02bb-42a5-a631-109a1c69c125',
        'membershipId': '65bd0f5e-5597-4a62-abb8-768785e57179',
        'status': 'pending',
        'role': 'contributor',
      });

      expect(model.projectId, 'e20ebd9d-02bb-42a5-a631-109a1c69c125');
      expect(model.membershipId, '65bd0f5e-5597-4a62-abb8-768785e57179');
      expect(model.status, 'pending');
      expect(model.role, 'contributor');
      expect(model.isPendingMembership, isTrue);
      expect(model.isImmediateMembership, isFalse);
    });

    test('parses active membership as immediate join', () {
      final model = JoinProjectResultModel.fromJson({
        'projectId': 'e20ebd9d-02bb-42a5-a631-109a1c69c125',
        'membershipId': '65bd0f5e-5597-4a62-abb8-768785e57179',
        'status': 'active',
        'role': 'contributor',
      });

      expect(model.isPendingMembership, isFalse);
      expect(model.isImmediateMembership, isTrue);
    });
  });
}
