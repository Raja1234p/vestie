import 'package:flutter_test/flutter_test.dart';

import 'package:vestie/features/project_announcements/data/models/project_announcement_attachment_model.dart';
import 'package:vestie/features/project_announcements/data/models/project_announcement_response_model.dart';

void main() {
  test('parses announcement attachments from API JSON', () {
    final model = ProjectAnnouncementResponseModel.fromJson({
      'id': 'ann-1',
      'heading': 'Tickets Booked',
      'content': 'Good News, I\'ve booked the tickets for trip.',
      'createdAtUtc': '2026-07-07T12:00:00Z',
      'attachments': [
        {
          'id': 'a1111111-1111-1111-1111-111111111111',
          'attachmentUrl': 'https://storage.example.com/file.jpg?sas=token',
          'sortOrder': 0,
        },
      ],
    });

    expect(model.attachments, hasLength(1));
    expect(model.attachments.first.id, 'a1111111-1111-1111-1111-111111111111');
    expect(
      model.attachments.first.attachmentUrl,
      'https://storage.example.com/file.jpg?sas=token',
    );
    expect(model.attachments.first.sortOrder, 0);

    final entity = model.toEntity();
    expect(entity.attachments, hasLength(1));
    expect(entity.attachments.first.attachmentUrl, contains('storage.example.com'));
  });

  test('sorts attachments by sortOrder', () {
    final attachments = ProjectAnnouncementAttachmentModel.listFromJson([
      {
        'id': 'b',
        'attachmentUrl': 'https://example.com/b.jpg',
        'sortOrder': 2,
      },
      {
        'id': 'a',
        'attachmentUrl': 'https://example.com/a.jpg',
        'sortOrder': 0,
      },
    ]);

    expect(attachments.map((a) => a.id).toList(), ['a', 'b']);
  });
}
