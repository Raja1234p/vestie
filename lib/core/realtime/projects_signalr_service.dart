import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:signalr_netcore/signalr_client.dart';
import 'package:vestie/core/constants/api_constants.dart';
import 'package:vestie/core/constants/storage_keys.dart';
import 'package:vestie/core/di/service_locator.dart';
import 'package:vestie/core/realtime/project_realtime_event.dart';
import 'package:vestie/core/realtime/signalr_hub_options.dart';

/// Week 4 — SignalR `/hubs/projects` (`JoinProjectChannel` / `LeaveProjectChannel`).
class ProjectsSignalRService {
  ProjectsSignalRService._();

  static final ProjectsSignalRService instance = ProjectsSignalRService._();

  HubConnection? _connection;
  final _events = StreamController<ProjectRealtimeEvent>.broadcast();
  final Set<String> _joinedProjectIds = {};
  bool _connecting = false;

  Stream<ProjectRealtimeEvent> get events => _events.stream;

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
            ApiConstants.projectsHubUrl,
            options: SignalRHubOptions.loggedIn(
              accessTokenFactory: _readAccessToken,
            ),
          )
          .withAutomaticReconnect()
          .build();

      connection.on('contribution_made', (args) {
        _emitNamed('contribution_made', args);
      });
      connection.on('pot_updated', (args) {
        _emitNamed('pot_updated', args);
      });

      await startSignalRHub(connection);
      _connection = connection;

      if (kDebugMode) {
        debugPrint('ProjectsSignalRService: connected');
      }

      for (final projectId in _joinedProjectIds.toList()) {
        await _invokeJoin(projectId);
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('ProjectsSignalRService: connect failed ($e)');
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

  Future<void> joinProject(String projectId) async {
    final id = projectId.trim();
    if (id.isEmpty) return;

    _joinedProjectIds.add(id);
    await connectIfLoggedIn();

    if (_connection?.state == HubConnectionState.Connected) {
      await _invokeJoin(id);
    }
  }

  Future<void> leaveProject(String projectId) async {
    final id = projectId.trim();
    if (id.isEmpty) return;

    _joinedProjectIds.remove(id);

    if (_connection?.state == HubConnectionState.Connected) {
      try {
        await _connection!.invoke('LeaveProjectChannel', args: <Object>[id]);
      } catch (e) {
        if (kDebugMode) {
          debugPrint('ProjectsSignalRService: leave failed ($e)');
        }
      }
    }
  }

  Future<void> disconnect() async {
    _joinedProjectIds.clear();
    try {
      await _connection?.stop();
    } catch (_) {}
    _connection = null;
  }

  Future<void> _invokeJoin(String projectId) async {
    try {
      await _connection!.invoke(
        'JoinProjectChannel',
        args: <Object>[projectId],
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('ProjectsSignalRService: join failed ($e)');
      }
    }
  }

  void _emitNamed(String signalName, List<Object?>? arguments) {
    final event = _parseEvent(signalName, arguments);
    if (event == null || _events.isClosed) return;
    _events.add(event);
  }

  ProjectRealtimeEvent? _parseEvent(
    String signalName,
    List<Object?>? arguments,
  ) {
    final map = _firstMap(arguments);
    final projectId = map != null
        ? (_stringFrom(map, 'projectId') ?? _stringFrom(map, 'ProjectId') ?? '')
        : (arguments != null && arguments.isNotEmpty
              ? arguments.first?.toString().trim() ?? ''
              : '');

    if (projectId.isEmpty) return null;

    final kind = switch (signalName) {
      'contribution_made' => ProjectRealtimeEventKind.contributionMade,
      'pot_updated' => ProjectRealtimeEventKind.potUpdated,
      _ => ProjectRealtimeEventKind.unknown,
    };

    return ProjectRealtimeEvent(
      kind: kind,
      projectId: projectId,
      potAmount: map != null
          ? (_doubleFrom(map, 'potAmount') ?? _doubleFrom(map, 'PotAmount'))
          : null,
      contributorCount: map != null
          ? (_intFrom(map, 'contributorCount') ??
                _intFrom(map, 'ContributorCount'))
          : null,
    );
  }

  Map<String, dynamic>? _firstMap(List<Object?>? arguments) {
    if (arguments == null || arguments.isEmpty) return null;
    final first = arguments.first;
    if (first is Map<String, dynamic>) return first;
    if (first is Map) return first.cast<String, dynamic>();
    return null;
  }

  String? _stringFrom(Map<String, dynamic> map, String key) {
    final v = map[key];
    if (v == null) return null;
    return v.toString();
  }

  double? _doubleFrom(Map<String, dynamic> map, String key) {
    final v = map[key];
    if (v is num) return v.toDouble();
    return double.tryParse(v?.toString() ?? '');
  }

  int? _intFrom(Map<String, dynamic> map, String key) {
    final v = map[key];
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v?.toString() ?? '');
  }
}
