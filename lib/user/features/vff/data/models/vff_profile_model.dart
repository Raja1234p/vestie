import 'package:vestie/core/utils/safe_parser.dart';

import '../../domain/entities/vff_profile_entity.dart';
import 'vff_json_parsing.dart';

class VffConnectedProfileModel {
  final VffConnectedProfileEntity entity;

  const VffConnectedProfileModel(this.entity);

  factory VffConnectedProfileModel.fromJson(Map<String, dynamic> json) {
    final statsJson = json.safeMap('stats');
    final projects = json
        .safeList('joinedProjects')
        .whereType<Map>()
        .map((m) => VffJsonParsing.mapJoinedProject(m.cast<String, dynamic>()))
        .toList(growable: false);

    return VffConnectedProfileModel(
      VffConnectedProfileEntity(
        userId: json.safeString('userId'),
        fullName: VffJsonParsing.readString(json, const ['fullName', 'name']),
        username: json.safeStringNullable('username'),
        profilePhotoUrl: _photoUrl(json),
        mutualProjectsCount: json.safeInt('mutualProjectsCount'),
        stats: VffJsonParsing.mapStats(statsJson),
        joinedProjects: projects,
      ),
    );
  }

  VffConnectedProfileEntity toEntity() => entity;

  static String? _photoUrl(Map<String, dynamic> json) {
    final raw = VffJsonParsing.readString(json, const [
      'profilePhotoUrl',
      'photoURL',
    ]);
    return raw.isEmpty ? null : raw;
  }
}

class VffPublicProfileModel {
  final VffPublicProfileEntity entity;

  const VffPublicProfileModel(this.entity);

  factory VffPublicProfileModel.fromJson(Map<String, dynamic> json) {
    final statsJson = json.safeMap('stats');
    final projects = json
        .safeList('joinedProjects')
        .whereType<Map>()
        .map((m) => VffJsonParsing.mapJoinedProject(m.cast<String, dynamic>()))
        .toList(growable: false);

    return VffPublicProfileModel(
      VffPublicProfileEntity(
        userId: json.safeString('userId'),
        fullName: VffJsonParsing.readString(json, const ['fullName', 'name']),
        username: json.safeStringNullable('username'),
        profilePhotoUrl: VffConnectedProfileModel._photoUrl(json),
        isVffConnected: json.safeBool('isVffConnected'),
        stats: VffJsonParsing.mapStats(statsJson),
        joinedProjects: projects,
      ),
    );
  }

  VffPublicProfileEntity toEntity() => entity;
}
