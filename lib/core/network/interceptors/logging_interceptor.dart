import 'dart:convert';
import 'dart:developer' as developer;

import 'package:dio/dio.dart';

import 'auth_interceptor.dart';
import 'dio_interceptor_extras.dart';

/// Pretty console logging for Dio (one bordered block per round-trip).
class LoggingInterceptor extends Interceptor {
  static const int _maxBodyChars = 16000;
  static const int _maxGetRetries = 3;
  static const String _bar =
      '────────────────────────────────────────────────────────────';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Auth retry reuses the same [RequestOptions]; request was already captured.
    if (options.extra[kAuthRetryExtraKey] == true) {
      return handler.next(options);
    }

    options.extra[kDioLogPendingKey] = _requestLines(options);
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _logRoundTrip(
      title: 'HTTP ${response.statusCode}',
      requestOptions: response.requestOptions,
      tail: [
        '',
        'Response:',
        _truncate(_prettyBody(response.data)),
      ],
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (_shouldSkipErrorLog(err)) {
      return handler.next(err);
    }

    final status = err.response?.statusCode;
    final lines = <String>[
      if (err.message != null) 'Message: ${err.message}',
      if (status != null) 'Status: $status',
      'Type: ${err.type}',
      if (err.response?.data != null) ...[
        '',
        'Response:',
        _truncate(_prettyBody(err.response!.data)),
      ],
    ];
    _logRoundTrip(
      title: 'HTTP ERROR',
      requestOptions: err.requestOptions,
      tail: lines,
    );
    handler.next(err);
  }

  static bool _shouldSkipErrorLog(DioException err) {
    if (AuthInterceptor.willRefreshAndRetry401(err)) return true;

    if (err.requestOptions.method != 'GET') return false;

    final retries = err.requestOptions.extra[kRetriesExtraKey] as int? ?? 0;
    if (retries >= _maxGetRetries) return false;

    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout) {
      return true;
    }

    final status = err.response?.statusCode;
    return status != null && status >= 500;
  }

  static void _logRoundTrip({
    required String title,
    required RequestOptions requestOptions,
    required List<String> tail,
  }) {
    final pending = requestOptions.extra[kDioLogPendingKey];
    final requestLines = pending is List
        ? pending.cast<String>()
        : <String>[
            '${requestOptions.method} ${requestOptions.uri}',
            '',
            'Request headers:',
            _prettyJsonLike(_safeHeaders(requestOptions.headers)),
            '',
            'Request body:',
            _truncate(_prettyBody(requestOptions.data)),
          ];

    _logBlock(title: title, lines: [...requestLines, ...tail]);
    requestOptions.extra.remove(kDioLogPendingKey);
  }

  static List<String> _requestLines(RequestOptions options) {
    return [
      '${options.method} ${options.uri}',
      '',
      'Request headers:',
      _prettyJsonLike(_safeHeaders(options.headers)),
      '',
      'Request body:',
      _truncate(_prettyBody(options.data)),
    ];
  }

  static void _logBlock({required String title, required List<String> lines}) {
    final buffer = StringBuffer()
      ..writeln()
      ..writeln(_bar)
      ..writeln('  $title')
      ..writeln(_bar);
    for (final line in lines) {
      buffer.writeln(line);
    }
    buffer.writeln(_bar);
    developer.log(buffer.toString(), name: 'DIO');
  }

  static Map<String, dynamic> _safeHeaders(Map<String, dynamic> headers) {
    final out = <String, dynamic>{};
    for (final e in headers.entries) {
      final key = e.key;
      final lower = key.toLowerCase();
      if (lower == 'authorization' ||
          lower == 'cookie' ||
          lower == 'x-api-key') {
        out[key] = '***';
      } else {
        out[key] = e.value;
      }
    }
    return out;
  }

  static String _prettyJsonLike(Object? value) {
    if (value == null) return '(null)';
    if (value is Map || value is List) {
      try {
        return const JsonEncoder.withIndent('  ').convert(value);
      } catch (_) {
        return value.toString();
      }
    }
    return value.toString();
  }

  static String _prettyBody(dynamic data) {
    if (data == null) return '(empty)';
    if (data is FormData) {
      final fieldKeys = data.fields.map((e) => e.key).join(', ');
      final fileKeys = data.files.map((e) => e.key).join(', ');
      final parts = <String>[];
      if (fieldKeys.isNotEmpty) parts.add('fields: $fieldKeys');
      if (fileKeys.isNotEmpty) parts.add('files: $fileKeys');
      return parts.isEmpty
          ? '(FormData, empty)'
          : 'FormData (${parts.join(' | ')})';
    }
    if (data is Map || data is List) {
      try {
        return const JsonEncoder.withIndent('  ').convert(data);
      } catch (_) {
        return data.toString();
      }
    }
    if (data is String) {
      final t = data.trim();
      if ((t.startsWith('{') && t.endsWith('}')) ||
          (t.startsWith('[') && t.endsWith(']'))) {
        try {
          final parsed = jsonDecode(t);
          return const JsonEncoder.withIndent('  ').convert(parsed);
        } catch (_) {
          return data;
        }
      }
      return data;
    }
    return data.toString();
  }

  static String _truncate(String text) {
    if (text.length <= _maxBodyChars) return text;
    return '${text.substring(0, _maxBodyChars)}\n… $_maxBodyChars of ${text.length} chars shown (truncated)';
  }
}
