import 'package:flutter_test/flutter_test.dart';
import 'package:vestie/core/constants/api_constants.dart';

void main() {
  test('signalRRequestTimeout is above signalr_netcore 2s default', () {
    expect(
      ApiConstants.signalRRequestTimeout.inMilliseconds,
      greaterThan(2000),
    );
  });
}
