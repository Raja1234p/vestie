import 'package:equatable/equatable.dart';

import '../../../../core/utils/safe_parser.dart';
import '../../domain/entities/created_project_entity.dart';
import 'project_list_json_parsing.dart';

/// Parses POST /projects JSON into [CreatedProjectEntity].
class CreateProjectResponseModel extends Equatable {
  final CreatedProjectEntity entity;

  const CreateProjectResponseModel(this.entity);

  factory CreateProjectResponseModel.fromJson(Map<String, dynamic> json) {
    final typeRaw = json['type'];
    final visibilityRaw = json['visibility'];
    final stateRaw = json['state'];

    return CreateProjectResponseModel(
      CreatedProjectEntity(
        id: json.safeString('id'),
        name: json.safeString('name'),
        description: json.safeString('description'),
        type: projectTypeToApiInt(typeRaw) ?? json.safeInt('type'),
        visibility:
            projectVisibilityToApiInt(visibilityRaw) ??
            json.safeInt('visibility'),
        state: projectStateToApiInt(stateRaw) ?? json.safeInt('state'),
        targetAmount: json.safeDouble('targetAmount'),
        endsAtUtc: json.safeDateTimeUtc('endsAtUtc') ?? DateTime.now().toUtc(),
        launchedAtUtc: json.safeDateTimeUtc('launchedAtUtc'),
        borrowingEnabled: json.safeBool('borrowingEnabled'),
        suggestedContributionAmount: json.safeDoubleNullable(
          'suggestedContributionAmount',
        ),
        createdUtc:
            json.safeDateTimeUtc('createdUtc') ?? DateTime.now().toUtc(),
      ),
    );
  }

  /// Values aligned with [ProjectSummaryEntity] string fields for list/home code.
  String get typeSummaryString =>
      projectTypeApiValueToSummaryString(entity.type);

  String get visibilitySummaryString =>
      projectVisibilityApiValueToSummaryString(entity.visibility);

  String get stateSummaryString =>
      projectStateApiValueToSummaryString(entity.state);

  @override
  List<Object?> get props => [entity];
}
