import 'package:vestie/core/utils/safe_parser.dart';

import '../../domain/entities/vff_connection_entity.dart';
import '../../domain/entities/vff_enums.dart';
import 'vff_json_parsing.dart';

class VffConnectionModel {
  final VffConnectionEntity entity;

  const VffConnectionModel(this.entity);

  factory VffConnectionModel.fromJson(Map<String, dynamic> json) {
    return VffConnectionModel(
      VffConnectionEntity(
        userId: VffJsonParsing.readString(json, const ['userId', 'UserId']),
        fullName: VffJsonParsing.readString(json, const ['fullName', 'name']),
        username: json.safeStringNullable('username'),
        profilePhotoUrl:
            VffJsonParsing.readString(json, const [
              'profilePhotoUrl',
              'photoURL',
            ]).isEmpty
            ? null
            : VffJsonParsing.readString(json, const [
                'profilePhotoUrl',
                'photoURL',
              ]),
        mutualProjectsCount: json.safeInt('mutualProjectsCount'),
        outgoingRequestStatus: VffOutgoingRequestStatus.parse(
          json.safeStringNullable('outgoingRequestStatus'),
        ),
      ),
    );
  }

  VffConnectionEntity toEntity() => entity;
}
