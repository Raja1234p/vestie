import 'dart:io';

import 'package:dio/dio.dart';

import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/error/exceptions.dart';
import 'package:vestie/features/project_announcements/domain/announcement_attachment_limits.dart';

/// Builds `multipart/form-data` for `POST /projects/{id}/announcements`.
abstract final class CreateAnnouncementMultipartBuilder {
  CreateAnnouncementMultipartBuilder._();

  static Future<FormData> build({
    required String heading,
    required String content,
    List<String> attachmentPaths = const [],
  }) async {
    final formData = FormData.fromMap({
      'heading': heading,
      'content': content,
    });

    for (final rawPath in attachmentPaths) {
      final path = rawPath.trim();
      if (path.isEmpty) continue;

      final file = File(path);
      if (!await file.exists()) {
        throw ServerException(AppStrings.announcementUploadImageInvalid);
      }

      final length = await file.length();
      if (length > AnnouncementAttachmentLimits.maxBytesPerFile) {
        throw ServerException(AppStrings.announcementUploadImageTooLarge);
      }

      final ext = _fileExtension(path);
      if (!AnnouncementAttachmentLimits.allowedExtensions.contains(ext)) {
        throw ServerException(AppStrings.announcementUploadImageFormatInvalid);
      }

      formData.files.add(
        MapEntry(
          AnnouncementAttachmentLimits.multipartFieldName,
          await MultipartFile.fromFile(path, filename: _basename(path)),
        ),
      );
    }

    return formData;
  }

  static String _basename(String path) {
    final normalized = path.replaceAll('\\', '/');
    final idx = normalized.lastIndexOf('/');
    return idx < 0 ? normalized : normalized.substring(idx + 1);
  }

  static String _fileExtension(String path) {
    final base = _basename(path);
    final dot = base.lastIndexOf('.');
    if (dot <= 0 || dot == base.length - 1) return '';
    return base.substring(dot + 1).toLowerCase();
  }
}
