import '../../../../core/utils/safe_parser.dart';
import '../../domain/entities/project_summary_entity.dart';
import 'project_image_model.dart';
import 'project_list_json_parsing.dart';

class ProjectSummaryModel extends ProjectSummaryEntity {
  const ProjectSummaryModel({
    required super.id,
    required super.name,
    required super.description,
    required super.type,
    required super.visibility,
    required super.state,
    required super.targetAmount,
    super.raisedAmount,
    super.potAmount,
    super.totalContributed,
    super.viewerRefundAmount,
    super.maxMembers,
    required super.endsAtUtc,
    super.launchedAtUtc,
    required super.borrowingEnabled,
    super.suggestedContributionAmount,
    required super.createdUtc,
    super.viewerRole,
    super.displayStatus,
    super.projectInviteCode,
    super.pendingRequestCount,
    super.roiPercentage,
    super.coverImageUrl,
    super.images,
    super.successVoteApproved,
    super.lastVoteType,
    super.lastVoteOutcome,
    super.eligibleMemberCount,
    super.distributionStatus,
  });

  factory ProjectSummaryModel.fromJson(Map<String, dynamic> json) {
    final listMemberCount = parseProjectListMemberCount(json);
    return ProjectSummaryModel(
      id: json.safeString('id'),
      name: json.safeString('name'),
      description: json.safeString('description'),
      type: projectTypeApiValueToSummaryString(json['type']),
      visibility: projectVisibilityApiValueToSummaryString(json['visibility']),
      state: projectListStateLabel(json),
      targetAmount: json.safeDouble('targetAmount'),
      raisedAmount: json.safeDouble('raisedAmount'),
      potAmount: json.containsKey('potAmount')
          ? json.safeDouble('potAmount')
          : null,
      totalContributed: json.safeDouble('totalContributed'),
      viewerRefundAmount: json.safeDouble('viewerRefundAmount'),
      maxMembers: json['maxMembers'] != null
          ? json.safeInt('maxMembers')
          : (listMemberCount > 0
              ? listMemberCount
              : json.safeInt('memberCount')),
      eligibleMemberCount: listMemberCount,
      endsAtUtc: json.safeDateTimeUtc('endsAtUtc') ??
          json.safeDateTimeUtc('completedAtUtc'),
      launchedAtUtc: json.safeDateTimeUtc('launchedAtUtc'),
      borrowingEnabled: json.safeBool('borrowingEnabled'),
      suggestedContributionAmount: json.safeDoubleNullable(
        'suggestedContributionAmount',
      ),
      createdUtc: json.safeDateTimeUtc('createdUtc') ?? DateTime.now().toUtc(),
      viewerRole: projectListItemViewerRole(json),
      displayStatus: json.safeString('displayStatus'),
      projectInviteCode: json.safeStringNullable('projectInviteCode'),
      pendingRequestCount: json.safeInt('pendingRequestCount'),
      roiPercentage: _parseRoiPercentage(json),
      coverImageUrl: json.safeStringNullable('coverImageUrl'),
      images: ProjectImageModel.listFromJson(json['images']),
      successVoteApproved: json['successVoteApproved'] is bool
          ? json['successVoteApproved'] as bool
          : null,
      lastVoteType: json.safeStringNullable('lastVoteType'),
      lastVoteOutcome: json.safeStringNullable('lastVoteOutcome'),
      distributionStatus: json.safeStringNullable('distributionStatus'),
    );
  }

  static double? _parseRoiPercentage(Map<String, dynamic> json) {
    final direct = parseApiRoiPercent(json);
    if (direct != null) return direct;
    final rules = json['projectRules'];
    if (rules is Map) {
      final nested = rules.map((k, v) => MapEntry(k.toString(), v));
      return parseApiRoiPercent(nested);
    }
    return null;
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
      'raisedAmount': raisedAmount,
      if (potAmount != null) 'potAmount': potAmount,
      'totalContributed': totalContributed,
      'viewerRefundAmount': viewerRefundAmount,
      'maxMembers': maxMembers,
      if (endsAtUtc != null) 'endsAtUtc': endsAtUtc!.toIso8601String(),
      'launchedAtUtc': launchedAtUtc?.toIso8601String(),
      'borrowingEnabled': borrowingEnabled,
      'suggestedContributionAmount': suggestedContributionAmount,
      'createdUtc': createdUtc.toIso8601String(),
      'viewerRole': viewerRole,
      'displayStatus': displayStatus,
      'projectInviteCode': projectInviteCode,
      'pendingRequestCount': pendingRequestCount,
      if (coverImageUrl != null) 'coverImageUrl': coverImageUrl,
      if (images.isNotEmpty)
        'images': images
            .map(
              (image) => {
                'id': image.id,
                'imageUrl': image.imageUrl,
                'sortOrder': image.sortOrder,
              },
            )
            .toList(),
    };
  }
}
