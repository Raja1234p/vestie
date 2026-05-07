import '../../../../core/utils/safe_parser.dart';
import '../../domain/entities/project_summary_entity.dart';

class ProjectSummaryModel extends ProjectSummaryEntity {
  const ProjectSummaryModel({
    required super.id,
    required super.name,
    required super.description,
    required super.type,
    required super.visibility,
    required super.state,
    required super.targetAmount,
    required super.maxMembers,
    required super.endsAtUtc,
    super.launchedAtUtc,
    required super.borrowingEnabled,
    required super.suggestedContributionAmount,
    required super.createdUtc,
  });

  factory ProjectSummaryModel.fromJson(Map<String, dynamic> json) {
    return ProjectSummaryModel(
      id: json.safeString('id'),
      name: json.safeString('name'),
      description: json.safeString('description'),
      type: json.safeString('type'),
      visibility: json.safeString('visibility'),
      state: json.safeString('state'),
      targetAmount: json.safeDouble('targetAmount'),
      maxMembers: json.safeInt('maxMembers'),
      endsAtUtc: json.safeDateTimeUtc('endsAtUtc') ?? DateTime.now().toUtc(),
      launchedAtUtc: json.safeDateTimeUtc('launchedAtUtc'),
      borrowingEnabled: json.safeBool('borrowingEnabled'),
      suggestedContributionAmount: json.safeDouble('suggestedContributionAmount'),
      createdUtc: json.safeDateTimeUtc('createdUtc') ?? DateTime.now().toUtc(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type,
      'visibility': visibility,
      'state': state,
      'targetAmount': targetAmount,
      'maxMembers': maxMembers,
      'endsAtUtc': endsAtUtc.toIso8601String(),
      'launchedAtUtc': launchedAtUtc?.toIso8601String(),
      'borrowingEnabled': borrowingEnabled,
      'suggestedContributionAmount': suggestedContributionAmount,
      'createdUtc': createdUtc.toIso8601String(),
    };
  }
}
