import 'dart:convert';
import 'dart:developer' as developer;

import 'package:dio/dio.dart';

/// Pretty console logging for Dio (debug-friendly layout, JSON indented).
class LoggingInterceptor extends Interceptor {
  static const int _maxBodyChars = 16000;
  static const String _bar =
      '────────────────────────────────────────────────────────────';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _logBlock(
      title: 'HTTP REQUEST',
      lines: [
        '${options.method} ${options.uri}',
        '',
        'Headers:',
        _prettyJsonLike(_safeHeaders(options.headers)),
        '',
        'Body:',
        _truncate(_prettyBody(options.data)),
      ],
    );
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _logBlock(
      title: 'HTTP RESPONSE ${response.statusCode}',
      lines: [
        '${response.requestOptions.method} ${response.requestOptions.uri}',
        '',
        'Body:',
        _truncate(_prettyBody(response.data)),
      ],
    );
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final status = err.response?.statusCode;
    final lines = <String>[
      '${err.requestOptions.method} ${err.requestOptions.uri}',
      '',
      'Type: ${err.type}',
      if (err.message != null) 'Message: ${err.message}',
      if (status != null) 'Status: $status',
      if (err.response?.data != null) ...[
        '',
        'Body:',
        _truncate(_prettyBody(err.response!.data)),
      ],
    ];
    _logBlock(title: 'HTTP ERROR', lines: lines);
    super.onError(err, handler);
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
