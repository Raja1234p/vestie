import 'dart:io';

import 'package:dio/dio.dart';

import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/error/exceptions.dart';
import 'package:vestie/leader/features/create_project/domain/create_project_image_limits.dart';

import 'create_project_request_model.dart';

/// Builds `multipart/form-data` for `POST /projects` (fields + optional images).
abstract final class CreateProjectMultipartBuilder {
  CreateProjectMultipartBuilder._();

  static Future<FormData> build({
    required CreateProjectRequestModel request,
    required List<String> imagePaths,
  }) async {
    final paths = imagePaths
        .map((path) => path.trim())
        .where((path) => path.isNotEmpty)
        .take(CreateProjectImageLimits.maxImages)
        .toList(growable: false);

    if (imagePaths.length > CreateProjectImageLimits.maxImages) {
      throw ServerException(AppStrings.createProjectImageTooMany);
    }

    final formData = FormData.fromMap(request.toMultipartFields());

    for (final path in paths) {
      final file = File(path);
      if (!await file.exists()) {
        throw ServerException(AppStrings.createProjectImageNotFound);
      }

      final length = await file.length();
      if (length > CreateProjectImageLimits.maxBytesPerFile) {
        throw ServerException(AppStrings.createProjectImageTooLarge);
      }

      final ext = _fileExtension(path);
      if (!CreateProjectImageLimits.allowedExtensions.contains(ext)) {
        throw ServerException(AppStrings.createProjectImageInvalidType);
      }

      final filename = _basename(path);
      formData.files.add(
        MapEntry(
          CreateProjectImageLimits.multipartFieldName,
          await MultipartFile.fromFile(
            path,
            filename: filename,
          ),
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
