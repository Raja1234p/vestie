import 'dart:math';

/// Generates a unique idempotency key for POST retries.
String newIdempotencyKey([String prefix = 'req']) {
  final r = Random();
  return '$prefix-${DateTime.now().microsecondsSinceEpoch}-${r.nextInt(0x7fffffff)}';
}
