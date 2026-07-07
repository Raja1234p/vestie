import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/error/exceptions.dart';
import 'package:vestie/features/projects/data/models/create_project_multipart_builder.dart';
import 'package:vestie/features/projects/data/models/create_project_request_model.dart';
import 'package:vestie/leader/features/create_project/domain/create_project_image_limits.dart';

void main() {
  group('CreateProjectMultipartBuilder', () {
    const request = CreateProjectRequestModel(
      name: 'Beach Trip',
      description: 'Summer savings',
      type: 'Vacation',
      visibility: 'Public',
      targetAmount: 5000,
      endsAtUtc: '2026-12-31T00:00:00.000Z',
      borrowingEnabled: true,
      joinApprovalRequired: false,
      roiPercentage: 5,
      repaymentWindowDays: 30,
      penaltyPercentage: 2,
    );

    test('builds form fields and repeated images key', () async {
      final dir = await Directory.systemTemp.createTemp('vestie_create_project');
      final paths = <String>[];
      for (var i = 0; i < 2; i++) {
        final file = File('${dir.path}/photo_$i.jpg');
        await file.writeAsBytes(List<int>.filled(16, i + 1));
        paths.add(file.path);
      }

      final formData = await CreateProjectMultipartBuilder.build(
        request: request,
        imagePaths: paths,
      );

      expect(formData.fields.map((e) => e.key), contains('name'));
      expect(formData.fields.map((e) => e.key), contains('targetAmount'));
      expect(
        formData.files.where(
          (e) => e.key == CreateProjectImageLimits.multipartFieldName,
        ),
        hasLength(2),
      );

      await dir.delete(recursive: true);
    });

    test('rejects more than maxImages', () async {
      final dir = await Directory.systemTemp.createTemp('vestie_create_project');
      final paths = <String>[];
      for (var i = 0; i < 6; i++) {
        final file = File('${dir.path}/photo_$i.png');
        await file.writeAsBytes([1, 2, 3]);
        paths.add(file.path);
      }

      await expectLater(
        CreateProjectMultipartBuilder.build(
          request: request,
          imagePaths: paths,
        ),
        throwsA(
          isA<ServerException>().having(
            (e) => e.message,
            'message',
            AppStrings.createProjectImageTooMany,
          ),
        ),
      );

      await dir.delete(recursive: true);
    });

    test('rejects file larger than 5 MB', () async {
      final dir = await Directory.systemTemp.createTemp('vestie_create_project');
      final file = File('${dir.path}/large.webp');
      await file.writeAsBytes(
        List<int>.filled(CreateProjectImageLimits.maxBytesPerFile + 1, 1),
      );

      await expectLater(
        CreateProjectMultipartBuilder.build(
          request: request,
          imagePaths: [file.path],
        ),
        throwsA(
          isA<ServerException>().having(
            (e) => e.message,
            'message',
            AppStrings.createProjectImageTooLarge,
          ),
        ),
      );

      await dir.delete(recursive: true);
    });

    test('rejects unsupported extension', () async {
      final dir = await Directory.systemTemp.createTemp('vestie_create_project');
      final file = File('${dir.path}/notes.txt');
      await file.writeAsString('not an image');

      await expectLater(
        CreateProjectMultipartBuilder.build(
          request: request,
          imagePaths: [file.path],
        ),
        throwsA(
          isA<ServerException>().having(
            (e) => e.message,
            'message',
            AppStrings.createProjectImageInvalidType,
          ),
        ),
      );

      await dir.delete(recursive: true);
    });
  });
}
