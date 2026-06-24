import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:signalr_netcore/signalr_client.dart';
import 'package:vestie/core/constants/api_constants.dart';
import 'package:vestie/core/constants/storage_keys.dart';
import 'package:vestie/core/di/service_locator.dart';
import 'package:vestie/core/realtime/signalr_hub_options.dart';

/// SignalR `/hubs/wallet` — live balance updates (deposit, withdraw, contribute).
class WalletSignalRService {
  WalletSignalRService._();

  static final WalletSignalRService instance = WalletSignalRService._();

  HubConnection? _connection;
  final _balanceChanged = StreamController<void>.broadcast();
  bool _connecting = false;

  /// Fires when the server pushes a wallet/balance change for the logged-in user.
  Stream<void> get balanceChanged => _balanceChanged.stream;

  static const _walletEvents = <String>[
    'wallet_updated',
    'balance_updated',
    'deposit_completed',
    'deposit_succeeded',
    'withdrawal_updated',
    'withdrawal_completed',
    'contribution_made',
  ];

  Future<void> connectIfLoggedIn() async {
    if (kIsWeb) return;

    if (!await _hasAccessToken()) return;

    if (_connection?.state == HubConnectionState.Connected) return;
    if (_connecting) return;

    _connecting = true;
    try {
      await _connection?.stop();

      final connection = HubConnectionBuilder()
          .withUrl(
            ApiConstants.walletHubUrl,
            options: SignalRHubOptions.loggedIn(
              accessTokenFactory: _readAccessToken,
            ),
          )
          .withAutomaticReconnect()
          .build();

      for (final name in _walletEvents) {
        connection.on(name, (_) => _notifyBalanceChanged());
      }

      await startSignalRHub(connection);
      _connection = connection;

      if (kDebugMode) {
        debugPrint('WalletSignalRService: connected');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('WalletSignalRService: connect failed ($e)');
      }
    } finally {
      _connecting = false;
    }
  }

  /// Drops any stale hub connection and reconnects with the latest access token.
  Future<void> reconnectAfterTokenRefresh() async {
    if (kIsWeb) return;
    if (!await _hasAccessToken()) return;

    try {
      await _connection?.stop();
    } catch (_) {}
    _connection = null;
    await connectIfLoggedIn();
  }

  static Future<String> _readAccessToken() async {
    final token = await ServiceLocator.instance.secureStorage.getString(
      StorageKeys.accessToken,
    );
    return token ?? '';
  }

  static Future<bool> _hasAccessToken() async {
    final token = await _readAccessToken();
    return token.isNotEmpty;
  }

  Future<void> disconnect() async {
    try {
      await _connection?.stop();
    } catch (_) {}
    _connection = null;
  }

  void _notifyBalanceChanged() {
    if (_balanceChanged.isClosed) return;
    _balanceChanged.add(null);
  }
}
