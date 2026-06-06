import 'package:flutter_test/flutter_test.dart';
import 'package:vestie/user/features/vff/data/models/vff_connection_model.dart';
import 'package:vestie/user/features/vff/domain/entities/vff_enums.dart';

void main() {
  test(
    'parses connected row from GET /users/me/vffs (null outgoingRequestStatus)',
    () {
      const json = {
        'userId': '631d4543-07c1-4ffc-8613-401bfd9589ea',
        'fullName': 'ai studio',
        'username': 'aistudioaistudio30',
        'profilePhotoUrl':
            'https://vestiestorage.blob.core.windows.net/vestie-attachments/profile-pictures/30e95783db1e4713a8304b47cf46f519.jpg',
        'mutualProjectsCount': 11,
        'outgoingRequestStatus': null,
      };

      final entity = VffConnectionModel.fromJson(json).toEntity();

      expect(entity.userId, '631d4543-07c1-4ffc-8613-401bfd9589ea');
      expect(entity.fullName, 'ai studio');
      expect(entity.username, 'aistudioaistudio30');
      expect(entity.mutualProjectsCount, 11);
      expect(entity.outgoingRequestStatus, isNull);
      expect(entity.isPendingOutgoing, isFalse);
    },
  );

  test('parses pending outgoing when outgoingRequestStatus is RequestSent', () {
    final entity = VffConnectionModel.fromJson({
      'userId': 'u1',
      'fullName': 'Pat',
      'mutualProjectsCount': 2,
      'outgoingRequestStatus': 'RequestSent',
    }).toEntity();

    expect(entity.isPendingOutgoing, isTrue);
    expect(entity.outgoingRequestStatus, VffOutgoingRequestStatus.requestSent);
  });
}
