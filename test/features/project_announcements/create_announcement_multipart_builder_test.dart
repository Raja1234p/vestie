import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:vestie/features/project_announcements/data/models/create_announcement_multipart_builder.dart';
import 'package:vestie/features/project_announcements/domain/announcement_attachment_limits.dart';

void main() {
  test('builds multipart fields without attachments', () async {
    final formData = await CreateAnnouncementMultipartBuilder.build(
      heading: 'Team update',
      content: 'See attached photos.',
    );

    expect(formData.fields.length, 2);
    expect(formData.fields[0].key, 'heading');
    expect(formData.fields[0].value, 'Team update');
    expect(formData.fields[1].key, 'content');
    expect(formData.fields[1].value, 'See attached photos.');
    expect(formData.files, isEmpty);
  });

  test('uses attachments field name for files', () async {
  final formData = FormData.fromMap({
    'heading': 'h',
    'content': 'c',
  });
  formData.files.add(
    MapEntry(
      AnnouncementAttachmentLimits.multipartFieldName,
      MultipartFile.fromString('bytes', filename: 'file1.jpg'),
    ),
  );

  expect(formData.files.single.key, 'attachments');
  expect(formData.files.single.value.filename, 'file1.jpg');
  });
}
