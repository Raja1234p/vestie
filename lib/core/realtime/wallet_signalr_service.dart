import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:signalr_netcore/signalr_client.dart';
import 'package:vestie/core/constants/api_constants.dart';
import 'package:vestie/core/constants/storage_keys.dart';
import 'package:vestie/core/di/service_locator.dart';

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

    final token = await ServiceLocator.instance.secureStorage.getString(
      StorageKeys.accessToken,
    );
    if (token == null || token.isEmpty) return;

    if (_connection?.state == HubConnectionState.Connected) return;
    if (_connecting) return;

    _connecting = true;
    try {
      await _connection?.stop();

      final connection = HubConnectionBuilder()
          .withUrl(
            ApiConstants.walletHubUrl,
            options: HttpConnectionOptions(
              accessTokenFactory: () async => token,
              transport: HttpTransportType.WebSockets,
            ),
          )
          .withAutomaticReconnect()
          .build();

      for (final name in _walletEvents) {
        connection.on(name, (_) => _notifyBalanceChanged());
      }

      await connection.start();
      _connection = connection;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('WalletSignalRService: connect failed ($e)');
      }
    } finally {
      _connecting = false;
    }
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
