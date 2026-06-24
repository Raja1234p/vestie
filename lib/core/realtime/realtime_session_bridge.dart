import 'dart:async';

import 'package:flutter/foundation.dart';

import 'projects_signalr_service.dart';
import 'wallet_signalr_service.dart';

/// Reconnects SignalR hubs after the access token is refreshed.
abstract final class RealtimeSessionBridge {
  RealtimeSessionBridge._();

  static Future<void> reconnectHubsAfterTokenRefresh() async {
    try {
      await Future.wait([
        ProjectsSignalRService.instance.reconnectAfterTokenRefresh(),
        WalletSignalRService.instance.reconnectAfterTokenRefresh(),
      ]);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('RealtimeSessionBridge: hub reconnect failed ($e)');
      }
    }
  }
}
