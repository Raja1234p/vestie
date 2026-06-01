import 'package:vestie/core/utils/safe_parser.dart';
import 'package:vestie/features/project_pot/domain/entities/project_pot_entity.dart';

class ProjectPotModel extends ProjectPotEntity {
  const ProjectPotModel({
    required super.potAmount,
    required super.contributorCount,
    super.vffMemberUserIds,
  });

  factory ProjectPotModel.fromJson(Map<String, dynamic> json) {
    final vff = (json['vffMemberUserIds'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList(growable: false) ??
        const <String>[];

    final pot = json.safeDouble('potAmount');
    return ProjectPotModel(
      potAmount: pot > 0 ? pot : json.safeDouble('potBalance'),
      contributorCount: json.safeInt('contributorCount'),
      vffMemberUserIds: vff,
    );
  }
}
