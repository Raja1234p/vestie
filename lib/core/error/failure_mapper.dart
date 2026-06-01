import 'dart:convert';

import 'package:dio/dio.dart';

import '../constants/app_strings.dart';
import '../models/api_error_response_model.dart';
import '../network/api_response_body.dart';
import 'failures.dart';

/// Maps exceptions and HTTP error payloads to [Failure] and user-facing dialog copy.
class FailureMapper {
  FailureMapper._();

  static Map<String, dynamic>? parseResponseBody(dynamic data) {
    if (data == null) return null;
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    if (data is String && data.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(data);
        if (decoded is Map) return Map<String, dynamic>.from(decoded);
      } catch (_) {}
    }
    return null;
  }

  static Failure fromException(Object error) {
    if (error is Failure) return error;
    if (error is DioException) return fromDioException(error);
    final raw = error.toString();
    if (looksLikeDioDump(raw)) {
      return const ServerFailure(AppStrings.errorGeneric);
    }
    return ServerFailure(raw);
  }

  static Failure fromDioException(DioException e) {
    final raw = parseResponseBody(e.response?.data);
    final body = raw != null ? unwrapApiResponseBody(raw) : null;
    if (body != null && body.isNotEmpty) {
      final apiError = ApiErrorResponseModel.fromJson(body);
      final message = _messageFromApiError(apiError);
      final title = apiError.title.trim().isEmpty ? null : apiError.title;
      final code = e.response?.statusCode;

      if (code == 400) {
        return ValidationFailure(message, title, apiError.errors);
      }
      if (code == 401) {
        return UnauthorizedFailure(message, title);
      }
      if (code == 403) {
        return ForbiddenFailure(message, title);
      }
      return ServerFailure(message, title);
    }

    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return const TimeoutFailure();
    }
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.unknown) {
      return const NetworkFailure();
    }
    return const NetworkFailure();
  }

  static String userMessage(Failure failure) {
    if (failure is NetworkFailure) return AppStrings.errorNetwork;
    if (failure is TimeoutFailure) return AppStrings.errorTimeout;
    if (failure is ForbiddenFailure) {
      final m = failure.message.trim();
      return m.isNotEmpty ? m : AppStrings.errorForbidden;
    }
    if (failure is UnauthorizedFailure) {
      final m = failure.message.trim();
      return m.isNotEmpty ? m : AppStrings.errorUnauthorized;
    }
    if (failure is ValidationFailure) {
      final fieldErrors = failure.errors;
      if (fieldErrors != null && fieldErrors.isNotEmpty) {
        return fieldErrors.values.expand((list) => list).join('\n');
      }
    }

    final msg = failure.message.trim();
    if (msg.isEmpty || looksLikeDioDump(msg)) {
      return AppStrings.errorGeneric;
    }
    return msg;
  }

  static String dialogTitle(Failure failure) {
    final title = failure.title?.trim();
    if (title != null && title.isNotEmpty) return title;
    return AppStrings.errorDialogTitle;
  }

  static bool looksLikeDioDump(String value) {
    final v = value.toLowerCase();
    return v.contains('dioexception') ||
        v.contains('developer.mozilla.org') ||
        (v.contains('status:') && v.contains('body:'));
  }

  static String _messageFromApiError(ApiErrorResponseModel apiError) {
    final detail = apiError.detail?.trim();
    if (detail != null && detail.isNotEmpty) return detail;

    final title = apiError.title.trim();
    if (title.isNotEmpty && title.toLowerCase() != 'error') return title;

    if (apiError.errors != null && apiError.errors!.isNotEmpty) {
      return apiError.errors!.values.expand((list) => list).join('\n');
    }

    return AppStrings.errorGeneric;
  }
}
