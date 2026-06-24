import 'package:signalr_netcore/signalr_client.dart';

import '../constants/api_constants.dart';

/// Shared SignalR HTTP/WebSocket options for Vestie hubs.
abstract final class SignalRHubOptions {
  SignalRHubOptions._();

  /// `signalr_netcore` defaults to 2000ms — too low for Azure cold start / mobile.
  static int get requestTimeoutMs =>
      ApiConstants.signalRRequestTimeout.inMilliseconds;

  static HttpConnectionOptions loggedIn({
    required AccessTokenFactory accessTokenFactory,
  }) {
    return HttpConnectionOptions(
      accessTokenFactory: accessTokenFactory,
      transport: HttpTransportType.WebSockets,
      requestTimeout: requestTimeoutMs,
    );
  }
}

/// Starts a hub with short retries (negotiate/WebSocket can lag on device networks).
Future<void> startSignalRHub(
  HubConnection connection, {
  int attempts = 3,
}) async {
  Object? lastError;
  for (var attempt = 0; attempt < attempts; attempt++) {
    try {
      await connection.start();
      return;
    } catch (e) {
      lastError = e;
      if (attempt == attempts - 1) break;
      await Future<void>.delayed(Duration(milliseconds: 400 * (attempt + 1)));
    }
  }
  throw lastError ?? StateError('SignalR hub start failed');
}
