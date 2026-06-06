import '../../../../core/utils/safe_parser.dart';
import '../../domain/entities/project_detail_entity.dart';

class ProjectDetailModel extends ProjectDetailEntity {
  const ProjectDetailModel({
    required super.id,
    required super.name,
    required super.description,
    required super.type,
    required super.visibility,
    required super.state,
    required super.targetAmount,
    required super.currentAmount,
    required super.maxMembers,
    required super.currentMembers,
    required super.endsAtUtc,
    super.launchedAtUtc,
    required super.borrowingEnabled,
    required super.suggestedContributionAmount,
    required super.viewerMembership,
    required super.rules,
  });

  factory ProjectDetailModel.fromJson(Map<String, dynamic> json) {
    return ProjectDetailModel(
      id: json.safeString('id'),
      name: json.safeString('name'),
      description: json.safeString('description'),
      type: json.safeString('type'),
      visibility: json.safeString('visibility'),
      state: json.safeString('state'),
      targetAmount: json.safeDouble('targetAmount'),
      currentAmount: json.safeDouble('currentAmount'),
      maxMembers: json.safeInt('maxMembers'),
      currentMembers: json.safeInt('currentMembers'),
      endsAtUtc: json.safeDateTimeUtc('endsAtUtc') ?? DateTime.now().toUtc(),
      launchedAtUtc: json.safeDateTimeUtc('launchedAtUtc'),
      borrowingEnabled: json.safeBool('borrowingEnabled'),
      suggestedContributionAmount: json.safeDouble(
        'suggestedContributionAmount',
      ),
      viewerMembership: ViewerMembershipModel.fromJson(
        json.safeMap('viewerMembership'),
      ),
      rules: ProjectRulesModel.fromJson(json.safeMap('rules')),
    );
  }
}

class ViewerMembershipModel extends ViewerMembershipEntity {
  const ViewerMembershipModel({required super.role, required super.status});

  factory ViewerMembershipModel.fromJson(Map<String, dynamic> json) {
    return ViewerMembershipModel(
      role: json.safeString('role', defaultValue: 'Member'),
      status: json.safeString('status', defaultValue: 'None'),
    );
  }
}

class ProjectRulesModel extends ProjectRulesEntity {
  const ProjectRulesModel({
    required super.minimumContributionAmount,
    required super.platformFeeRatePercent,
  });

  factory ProjectRulesModel.fromJson(Map<String, dynamic> json) {
    return ProjectRulesModel(
      minimumContributionAmount: json.safeDouble('minimumContributionAmount'),
      platformFeeRatePercent: json.safeDouble('platformFeeRatePercent'),
    );
  }
}
