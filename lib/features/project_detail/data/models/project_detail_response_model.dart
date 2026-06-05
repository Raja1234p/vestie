import 'package:vestie/core/utils/safe_parser.dart';
import 'package:vestie/features/projects/data/models/project_list_json_parsing.dart';
import 'package:vestie/user/features/home/domain/entities/project.dart';
import 'package:vestie/user/features/vff/domain/entities/vff_enums.dart';

import '../../domain/entities/borrow_request_entity.dart';
import '../../domain/entities/member_entity.dart';
import '../../domain/entities/project_announcement_entity.dart';
import '../../domain/entities/project_detail_entity.dart';
import '../../domain/entities/project_invite_entity.dart';
import '../../domain/entities/viewer_membership_role.dart';

/// `GET /projects/{id}` — `project`, `rules`, `viewerMembership`, `members`, `invites`.
class ProjectDetailResponseModel {
  final _ProjectPayload _project;
  final _RulesPayload _rules;
  final _MembershipPayload _viewerMembership;
  final List<_MembershipPayload> _members;
  final List<_InvitePayload> _invites;
  final List<_AnnouncementPayload> _announcements;

  const ProjectDetailResponseModel._({
    required _ProjectPayload project,
    required _RulesPayload rules,
    required _MembershipPayload viewerMembership,
    required List<_MembershipPayload> members,
    required List<_InvitePayload> invites,
    required List<_AnnouncementPayload> announcements,
  })  : _project = project,
        _rules = rules,
        _viewerMembership = viewerMembership,
        _members = members,
        _invites = invites,
        _announcements = announcements;

  factory ProjectDetailResponseModel.fromJson(Map<String, dynamic> json) {
    final projectJson =
        (json['project'] as Map?)?.cast<String, dynamic>() ??
            const <String, dynamic>{};
    final rulesJson =
        (json['rules'] as Map?)?.cast<String, dynamic>() ??
            const <String, dynamic>{};
    final viewerMembershipJson =
        (json['viewerMembership'] as Map?)?.cast<String, dynamic>() ??
            const <String, dynamic>{};
    final membersJson = (json['members'] as List?)
            ?.whereType<Map>()
            .map((m) => m.cast<String, dynamic>())
            .toList() ??
        const <Map<String, dynamic>>[];
    final invitesJson = (json['invites'] as List?)
            ?.whereType<Map>()
            .map((m) => m.cast<String, dynamic>())
            .toList() ??
        const <Map<String, dynamic>>[];
    final announcementsJson = (json['announcements'] as List?)
            ?.whereType<Map>()
            .map((m) => m.cast<String, dynamic>())
            .toList() ??
        const <Map<String, dynamic>>[];

    return ProjectDetailResponseModel._(
      project: _ProjectPayload.fromJson(projectJson),
      rules: _RulesPayload.fromJson(rulesJson),
      viewerMembership: _MembershipPayload.fromJson(viewerMembershipJson),
      members: membersJson.map(_MembershipPayload.fromJson).toList(growable: false),
      invites: invitesJson.map(_InvitePayload.fromJson).toList(growable: false),
      announcements: announcementsJson
          .map(_AnnouncementPayload.fromJson)
          .toList(growable: false),
    );
  }

  ProjectDetailEntity toEntity() {
    final viewerRole = ViewerMembershipRole.forProjectDetail(
      projectViewerRole: _project.viewerRole,
      membershipRole: _viewerMembership.role,
    );

    final mappedMembers = _members.map(_mapMember).toList(growable: false);
    final mappedInvites = _invites.map(_mapInvite).toList(growable: false);
    final mappedAnnouncements = _announcements
        .map(
          (a) => ProjectAnnouncementEntity(
            id: a.id,
            heading: a.heading,
            content: a.content,
            createdAtUtc: a.createdAtUtc,
          ),
        )
        .toList(growable: false);

    return ProjectDetailEntity(
      id: _project.id,
      name: _project.name,
      category: _mapCategory(_project.type),
      status: _mapStatus(_project.lifecycleState),
      goalAmount: _project.targetAmount,
      currentAmount: _project.raisedAmount,
      endsIn: _project.endsAtUtc,
      announcement: _project.description,
      announcements: mappedAnnouncements,
      members: mappedMembers,
      borrowRequests: const <BorrowRequestEntity>[],
      viewerRole: viewerRole,
      membershipId: _viewerMembership.membershipId,
      borrowLimitAmount: _viewerMembership.borrowLimitAmount ?? 0,
      repaymentWindowDays: _rules.repaymentWindowDays,
      repaymentGraceDays: _rules.repaymentGraceDays,
      contributionsAreNonRefundable: _rules.contributionsAreNonRefundable,
      displayStatusLabel: _project.displayStatus.isNotEmpty
          ? _project.displayStatus
          : _project.lifecycleState,
      borrowingEnabled:
          _project.borrowingEnabled && _rules.borrowingAllowed,
      pendingJoinRequestCount: _project.pendingRequestCount,
      projectInviteCode: _project.projectInviteCode,
      roiPercentage: _rules.roiPercentage ?? _project.roi,
      joinApprovalRequired: _rules.joinApprovalRequired,
      minimumContributionAmount: _rules.minimumContributionAmount,
      penaltyPercentage: _rules.penaltyPercentage,
      successVoteWindowHours: _rules.successVoteWindowHours,
      invites: mappedInvites,
      hasCoLeader: _project.hasCoLeader,
    );
  }

  static ProjectInviteEntity _mapInvite(_InvitePayload json) {
    return ProjectInviteEntity(
      id: json.id,
      inviteCode: json.inviteCode,
      requiresApproval: json.requiresApproval,
      expiresAtUtc: json.expiresAtUtc,
      maxUses: json.maxUses,
      usedCount: json.usedCount,
    );
  }

  static MemberEntity _mapMember(_MembershipPayload json) {
    final firstName = json.firstName;
    final lastName = json.lastName;
    final userName = json.userName;
    final fullName = ('$firstName $lastName').trim().isNotEmpty
        ? ('$firstName $lastName').trim()
        : userName;

    final mappedRole = switch (ViewerMembershipRole.parse(json.role)) {
      ViewerMembershipRole.groupLeader => MemberRole.leader,
      ViewerMembershipRole.coLeader => MemberRole.coLeader,
      ViewerMembershipRole.member => MemberRole.member,
    };

    return MemberEntity(
      id: json.userId.isEmpty ? json.membershipId : json.userId,
      membershipId: json.membershipId,
      userId: json.userId,
      initials: _initials(fullName),
      name: fullName.isEmpty ? 'Member' : fullName,
      username: userName,
      status: json.status,
      role: mappedRole,
      contributedAmount: 0,
      overdueAmount: null,
      photoUrl: json.photoUrl,
      vffAdded: json.vffAdded,
      vffConnectionState: json.vffConnectionState,
      canSendVffRequest: json.canSendVffRequest,
      pendingVffRequestId: json.pendingVffRequestId,
    );
  }

  static String _initials(String name) {
    final parts =
        name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return 'NA';
    String firstChar(String s) => s.isEmpty ? 'N' : s[0].toUpperCase();
    final first = firstChar(parts.first);
    final last = firstChar(parts.length > 1 ? parts.last : parts.first);
    return '$first$last';
  }

  static ProjectCategory _mapCategory(String type) {
    final t = type.toLowerCase().trim();
    if (t.contains('invest')) return ProjectCategory.investment;
    if (t.contains('emerg')) return ProjectCategory.emergency;
    return ProjectCategory.vacations;
  }

  static ProjectStatus _mapStatus(String state) {
    final s = state.toLowerCase().trim();
    if (s.contains('complete') || s.contains('cancel')) {
      return ProjectStatus.completed;
    }
    return ProjectStatus.ongoing;
  }
}

String _jsonString(dynamic value) {
  if (value == null) return '';
  return value.toString();
}

double? _jsonDoubleNullable(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}

class _ProjectPayload {
  final String id;
  final String name;
  final String description;
  final String type;
  final String visibility;
  final String lifecycleState;
  final double targetAmount;
  final double raisedAmount;
  final String endsAtUtc;
  final String? launchedAtUtc;
  final String viewerRole;
  final String displayStatus;
  final String projectInviteCode;
  final bool borrowingEnabled;
  final double? suggestedContributionAmount;
  final String createdUtc;
  final int pendingRequestCount;
  final double? roi;
  final bool hasCoLeader;

  const _ProjectPayload({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.visibility,
    required this.lifecycleState,
    required this.targetAmount,
    required this.raisedAmount,
    required this.endsAtUtc,
    this.launchedAtUtc,
    required this.viewerRole,
    required this.displayStatus,
    required this.projectInviteCode,
    required this.borrowingEnabled,
    this.suggestedContributionAmount,
    required this.createdUtc,
    required this.pendingRequestCount,
    this.roi,
    this.hasCoLeader = false,
  });

  factory _ProjectPayload.fromJson(Map<String, dynamic> json) {
    final display = json.safeString('displayStatus');
    final lifecycle = _jsonString(json['state']);
    return _ProjectPayload(
      id: _jsonString(json['id']),
      name: _jsonString(json['name']),
      description: _jsonString(json['description']),
      type: projectTypeApiValueToSummaryString(json['type']),
      visibility: projectVisibilityApiValueToSummaryString(json['visibility']),
      lifecycleState: lifecycle,
      targetAmount: (json['targetAmount'] as num?)?.toDouble() ?? 0.0,
      raisedAmount: (json['raisedAmount'] as num?)?.toDouble() ?? 0.0,
      endsAtUtc: _nullableString(json['endsAtUtc']) ?? '',
      launchedAtUtc: _nullableString(json['launchedAtUtc']),
      viewerRole: projectListItemViewerRole(json),
      displayStatus: display,
      projectInviteCode: _jsonString(json['projectInviteCode']),
      borrowingEnabled: json['borrowingEnabled'] == true,
      suggestedContributionAmount: _jsonDoubleNullable(
        json['suggestedContributionAmount'],
      ),
      createdUtc: _jsonString(json['createdUtc']),
      pendingRequestCount: (json['pendingRequestCount'] as num?)?.toInt() ?? 0,
      roi: parseApiRoiPercent(json),
      hasCoLeader: json['hasCoLeader'] == true,
    );
  }
}

String? _nullableString(dynamic value) {
  if (value == null) return null;
  final s = value.toString().trim();
  return s.isEmpty ? null : s;
}

class _RulesPayload {
  final double? roiPercentage;
  final bool joinApprovalRequired;
  final bool borrowingAllowed;
  final int successVoteWindowHours;
  final int repaymentWindowDays;
  final int repaymentGraceDays;
  final double? penaltyPercentage;
  final double minimumContributionAmount;
  final bool contributionsAreNonRefundable;

  const _RulesPayload({
    this.roiPercentage,
    required this.joinApprovalRequired,
    required this.borrowingAllowed,
    required this.successVoteWindowHours,
    required this.repaymentWindowDays,
    required this.repaymentGraceDays,
    this.penaltyPercentage,
    required this.minimumContributionAmount,
    required this.contributionsAreNonRefundable,
  });

  factory _RulesPayload.fromJson(Map<String, dynamic> json) => _RulesPayload(
        roiPercentage: parseApiRoiPercent(json),
        joinApprovalRequired: json['joinApprovalRequired'] == true,
        borrowingAllowed: json['borrowingAllowed'] == true,
        successVoteWindowHours:
            (json['successVoteWindowHours'] as num?)?.toInt() ?? 0,
        repaymentWindowDays:
            (json['repaymentWindowDays'] as num?)?.toInt() ?? 0,
        repaymentGraceDays: (json['repaymentGraceDays'] as num?)?.toInt() ?? 0,
        penaltyPercentage: _jsonDoubleNullable(json['penaltyPercentage']),
        minimumContributionAmount:
            (json['minimumContributionAmount'] as num?)?.toDouble() ?? 0.0,
        contributionsAreNonRefundable:
            json['contributionsAreNonRefundable'] == true,
      );
}

class _MembershipPayload {
  final String membershipId;
  final String userId;
  final String userName;
  final String firstName;
  final String lastName;
  final String role;
  final String status;
  final double? borrowLimitAmount;
  final bool isDefaulted;
  final String badge;
  final String? photoUrl;
  final bool vffAdded;
  final VffConnectionState vffConnectionState;
  final bool canSendVffRequest;
  final String? pendingVffRequestId;

  const _MembershipPayload({
    required this.membershipId,
    required this.userId,
    required this.userName,
    required this.firstName,
    required this.lastName,
    required this.role,
    required this.status,
    this.borrowLimitAmount,
    required this.isDefaulted,
    required this.badge,
    this.photoUrl,
    this.vffAdded = false,
    this.vffConnectionState = VffConnectionState.none,
    this.canSendVffRequest = false,
    this.pendingVffRequestId,
  });

  factory _MembershipPayload.fromJson(Map<String, dynamic> json) =>
      _MembershipPayload(
        membershipId: _jsonString(json['membershipId']),
        userId: _jsonString(json['userId']),
        userName: _jsonString(json['userName']),
        firstName: _jsonString(json['firstName']),
        lastName: _jsonString(json['lastName']),
        role: membershipRoleApiValueToString(json['role']),
        status: membershipStatusApiValueToString(json['status']),
        borrowLimitAmount: _jsonDoubleNullable(json['borrowLimitAmount']),
        isDefaulted: json['isDefaulted'] == true,
        badge: _jsonString(json['badge']),
        photoUrl: membershipPhotoUrlFromJson(json),
        vffAdded: membershipVffAddedFromJson(json),
        vffConnectionState: membershipVffConnectionStateFromJson(json),
        canSendVffRequest: json.safeBool('canSendVffRequest'),
        pendingVffRequestId: membershipPendingVffRequestId(json),
      );
}

class _InvitePayload {
  final String id;
  final String inviteCode;
  final bool requiresApproval;
  final String expiresAtUtc;
  final int? maxUses;
  final int usedCount;

  const _InvitePayload({
    required this.id,
    required this.inviteCode,
    required this.requiresApproval,
    required this.expiresAtUtc,
    this.maxUses,
    required this.usedCount,
  });

  factory _InvitePayload.fromJson(Map<String, dynamic> json) => _InvitePayload(
        id: _jsonString(json['id']),
        inviteCode: _jsonString(json['inviteCode']),
        requiresApproval: json['requiresApproval'] == true,
        expiresAtUtc: _jsonString(json['expiresAtUtc']),
        maxUses: (json['maxUses'] as num?)?.toInt(),
        usedCount: (json['usedCount'] as num?)?.toInt() ?? 0,
      );
}

class _AnnouncementPayload {
  final String id;
  final String heading;
  final String content;
  final String? createdAtUtc;

  const _AnnouncementPayload({
    required this.id,
    required this.heading,
    required this.content,
    this.createdAtUtc,
  });

  factory _AnnouncementPayload.fromJson(Map<String, dynamic> json) =>
      _AnnouncementPayload(
        id: _jsonString(json['id']),
        heading: _jsonString(json['heading']),
        content: _jsonString(json['content']),
        createdAtUtc: _nullableString(json['createdAtUtc']) ??
            _nullableString(json['createdUtc']),
      );
}
