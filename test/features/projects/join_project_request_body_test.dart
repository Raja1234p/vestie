import 'package:flutter_test/flutter_test.dart';
import 'package:vestie/features/projects/data/datasources/join_project_request_body.dart';

void main() {
  group('buildJoinProjectRequestBody', () {
    test('invite join sends inviteCode only', () {
      expect(buildJoinProjectRequestBody(inviteCode: '4W26FFZP86'), {
        'inviteCode': '4W26FFZP86',
      });
    });

    test('public join sends projectId only', () {
      expect(
        buildJoinProjectRequestBody(
          projectId: '43b78933-d41a-4d26-95a3-226abaf05d94',
        ),
        {'projectId': '43b78933-d41a-4d26-95a3-226abaf05d94'},
      );
    });

    test('rejects both or neither', () {
      expect(
        () => buildJoinProjectRequestBody(projectId: 'a', inviteCode: 'b'),
        throwsArgumentError,
      );
      expect(() => buildJoinProjectRequestBody(), throwsArgumentError);
    });
  });
}
