import 'package:vestie/core/domain/entities/pagination_info.dart';
import 'package:vestie/core/models/pagination_dto.dart';
import 'package:vestie/core/utils/safe_parser.dart';
import 'package:vestie/features/projects/data/models/project_image_model.dart';
import 'package:vestie/features/projects/data/models/project_list_json_parsing.dart';
import 'package:vestie/user/features/home/domain/entities/project.dart';
import 'package:vestie/user/features/vff/domain/entities/vff_enums.dart';

import '../../domain/entities/borrow_request_entity.dart';
import '../../domain/entities/member_entity.dart';
import '../../domain/entities/member_entity_extensions.dart';
import 'package:vestie/features/project_announcements/data/models/project_announcement_attachment_model.dart';
import 'package:vestie/features/project_announcements/data/models/project_announcement_response_model.dart';

import '../../domain/entities/project_announcement_entity.dart';
import '../../domain/entities/closure_vote_entities.dart';
import '../../domain/entities/project_detail_closure_extensions.dart';
import '../../domain/entities/project_detail_entity.dart';
import '../../domain/entities/project_detail_voting_entities.dart';
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
  final PaginationDto _membersPagination;
  final PaginationDto _invitesPagination;
  final PaginationDto _announcementsPagination;
  final String? _projectStatusRaw;
  final String? _votingStatusRaw;
  final String? _userRoleRaw;
  final bool? _canStopContributions;
  final _VotingPayload? _voting;

  const ProjectDetailResponseModel._({
    required _ProjectPayload project,
    required _RulesPayload rules,
    required _MembershipPayload viewerMembership,
    required List<_MembershipPayload> members,
    required List<_InvitePayload> invites,
    required List<_AnnouncementPayload> announcements,
    required PaginationDto membersPagination,
    required PaginationDto invitesPagination,
    required PaginationDto announcementsPagination,
    String? projectStatusRaw,
    String? votingStatusRaw,
    String? userRoleRaw,
    bool? canStopContributions,
    _VotingPayload? voting,
  }) : _project = project,
       _rules = rules,
       _viewerMembership = viewerMembership,
       _members = members,
       _invites = invites,
       _announcements = announcements,
       _membersPagination = membersPagination,
       _invitesPagination = invitesPagination,
       _announcementsPagination = announcementsPagination,
       _projectStatusRaw = projectStatusRaw,
       _votingStatusRaw = votingStatusRaw,
       _userRoleRaw = userRoleRaw,
       _canStopContributions = canStopContributions,
       _voting = voting;

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
    final membersSection = _parseSection(json['members']);
    final invitesSection = _parseSection(json['invites']);
    final announcementsSection = _parseSection(json['announcements']);
    final votingJson = (json['voting'] as Map?)?.cast<String, dynamic>();

    return ProjectDetailResponseModel._(
      project: _ProjectPayload.fromJson(projectJson),
      rules: _RulesPayload.fromJson(rulesJson),
      viewerMembership: _MembershipPayload.fromJson(viewerMembershipJson),
      members: membersSection.items
          .map(_MembershipPayload.fromJson)
          .toList(growable: false),
      invites: invitesSection.items
          .map(_InvitePayload.fromJson)
          .toList(growable: false),
      announcements: announcementsSection.items
          .map(_AnnouncementPayload.fromJson)
          .toList(growable: false),
      membersPagination: membersSection.pagination,
      invitesPagination: invitesSection.pagination,
      announcementsPagination: announcementsSection.pagination,
      projectStatusRaw: _nullableString(json['projectStatus']),
      votingStatusRaw: _nullableString(json['votingStatus']),
      userRoleRaw: _nullableString(json['userRole']),
      canStopContributions: json['canStopContributions'] is bool
          ? json['canStopContributions'] as bool
          : null,
      voting: votingJson == null ? null : _VotingPayload.fromJson(votingJson),
    );
  }

  static _PaginatedSection _parseSection(dynamic raw) {
    final maps = PaginatedListParser.parseItemMaps(raw);
    final pagination = PaginatedListParser.parsePagination(
      raw,
      fallbackItemCount: maps.length,
    );
    return _PaginatedSection(items: maps, pagination: pagination);
  }

  static String? _nullableString(dynamic value) {
    if (value == null) return null;
    final s = value.toString().trim();
    return s.isEmpty ? null : s;
  }

  /// Cover image from nested `project.coverImageUrl`.
  String? get coverImageUrl => _project.coverImageUrl;

  /// Gallery images from nested `project.images`.
  List<ProjectImageModel> get images => _project.images;

  ProjectDetailEntity toEntity() {
    final mappedMembers = _members.map(_mapMember).toList(growable: false);
    final viewerRole = ViewerMembershipRole.forProjectDetail(
      projectViewerRole: _project.viewerRole,
      membershipRole: _viewerMembership.role,
      viewerMembershipId: _viewerMembership.membershipId,
      viewerUserId: _viewerMembership.userId,
      members: mappedMembers,
    );

    final mergedMembers = _applyViewerMembershipPenalty(
      _applyViewerMembershipRole(
        _applyViewerMembershipBadge(
          mappedMembers,
          viewerMembershipId: _viewerMembership.membershipId,
          viewerBadge: _viewerMembership.badge,
        ),
        viewerMembershipId: _viewerMembership.membershipId,
        viewerUserId: _viewerMembership.userId,
        viewerRole: viewerRole,
      ),
      viewerMembership: _viewerMembership,
    );
    final mappedInvites = _invites.map(_mapInvite).toList(growable: false);
    final mappedAnnouncements = _announcements
        .map((a) => a.toEntity())
        .toList(growable: false);

    final lifecycleState = _project.lifecycleState;
    final projectBannerStatus = _projectStatusRaw != null
        ? parseProjectDetailBannerStatus(_projectStatusRaw)
        : projectDetailBannerStatusFromLifecycleState(lifecycleState);
    final votingStatus = _votingStatusRaw != null
        ? parseProjectVotingStatus(_votingStatusRaw)
        : ProjectVotingStatus.notStarted;
    final detailUserRole = _userRoleRaw != null
        ? parseProjectDetailUserRole(_userRoleRaw)
        : projectDetailUserRoleFromViewerRole(_project.viewerRole);
    final votingSummary = _voting?.toEntity();

    final entityStatus = switch (projectBannerStatus) {
      ProjectDetailBannerStatus.completed ||
      ProjectDetailBannerStatus.cancelled => ProjectStatus.completed,
      ProjectDetailBannerStatus.ongoing => ProjectStatus.ongoing,
    };

    final hasWeek11Envelope =
        _projectStatusRaw != null ||
        _votingStatusRaw != null ||
        _userRoleRaw != null;

    // Finalized `done` votes are complete — unlock Mark as Successful / ownership actions.
    final hasActiveVote = hasWeek11Envelope &&
        (votingStatus == ProjectVotingStatus.pending ||
            (votingStatus == ProjectVotingStatus.done &&
                votingSummary?.isFinalized != true));

    final entity = ProjectDetailEntity(
      id: _project.id,
      name: _project.name,
      category: _mapCategory(_project.type),
      status: entityStatus,
      goalAmount: _project.targetAmount,
      currentAmount: _project.displayPotAmount,
      totalContributed: _project.totalContributed,
      viewerRefundAmount: _project.viewerRefundAmount,
      endsIn: _project.endsAtUtc,
      announcement: _project.description,
      announcements: mappedAnnouncements,
      members: mergedMembers,
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
      projectLifecycleState: lifecycleState,
      projectBannerStatus: projectBannerStatus,
      votingStatus: votingStatus,
      detailUserRole: detailUserRole,
      voting: votingSummary,
      hasWeek11ProjectDetailEnvelope: hasWeek11Envelope,
      apiCanStopContributions: _canStopContributions,
      borrowingEnabled: _project.borrowingEnabled && _rules.borrowingAllowed,
      pendingJoinRequestCount: _project.pendingRequestCount,
      projectInviteCode: _project.projectInviteCode,
      roiPercentage: _rules.roiPercentage ?? _project.roi,
      joinApprovalRequired: _rules.joinApprovalRequired,
      minimumContributionAmount: _rules.minimumContributionAmount,
      penaltyPercentage: _rules.penaltyPercentage,
      successVoteWindowHours: _rules.successVoteWindowHours,
      hasActiveSuccessVote: hasActiveVote,
      invites: mappedInvites,
      hasCoLeader: _project.hasCoLeader,
      coverImageUrl: _project.coverImageUrl,
      images: _project.images,
      membersPagination: _toPaginationInfo(_membersPagination),
      invitesPagination: _toPaginationInfo(_invitesPagination),
      announcementsPagination: _toPaginationInfo(_announcementsPagination),
      viewerApiIsDefaulted: _viewerMembership.isDefaulted,
      viewerApiOverdueAmount: _viewerMembership.overdueAmount,
    );

    if (!hasActiveVote) return entity;

    return entity.withSyntheticClosureVoteFromDetailVoting();
  }

  static PaginationInfo _toPaginationInfo(PaginationDto dto) {
    return PaginationInfo(
      page: dto.page,
      pageSize: dto.pageSize,
      totalCount: dto.totalCount,
      totalPages: dto.totalPages,
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
      overdueAmount: json.overdueAmount,
      photoUrl: json.photoUrl,
      vffAdded: json.vffAdded,
      vffConnectionState: json.vffConnectionState,
      canSendVffRequest: json.canSendVffRequest,
      pendingVffRequestId: json.pendingVffRequestId,
      badge: MemberEntity.memberBadgeFromApi(json.badge),
      isDefaulted: json.isDefaulted,
    );
  }

  /// Elevates the viewer's roster row from `project.viewerRole` / membership — not `badge`.
  static List<MemberEntity> _applyViewerMembershipRole(
    List<MemberEntity> members, {
    required String viewerMembershipId,
    required String viewerUserId,
    required ViewerMembershipRole viewerRole,
  }) {
    final elevatedRole = switch (viewerRole) {
      ViewerMembershipRole.groupLeader => MemberRole.leader,
      ViewerMembershipRole.coLeader => MemberRole.coLeader,
      ViewerMembershipRole.member => null,
    };
    if (elevatedRole == null) return members;

    return members
        .map((member) {
          if (!_isViewerMemberRow(
            member,
            viewerMembershipId: viewerMembershipId,
            viewerUserId: viewerUserId,
          )) {
            return member;
          }
          if (_roleRank(member.role) >= _roleRank(elevatedRole)) {
            return member.copyWith(
              badge: MemberEntity.memberBadgeFromApi(member.badge),
            );
          }
          return member.copyWith(
            role: elevatedRole,
            badge: MemberEntity.memberBadgeFromApi(member.badge),
          );
        })
        .toList(growable: false);
  }

  static bool _isViewerMemberRow(
    MemberEntity member, {
    required String viewerMembershipId,
    required String viewerUserId,
  }) {
    final membershipId = viewerMembershipId.trim();
    if (membershipId.isNotEmpty &&
        member.membershipId.trim() == membershipId) {
      return true;
    }
    final userId = viewerUserId.trim();
    return userId.isNotEmpty && member.apiUserId.trim() == userId;
  }

  static int _roleRank(MemberRole role) => switch (role) {
    MemberRole.leader => 3,
    MemberRole.coLeader => 2,
    MemberRole.member => 1,
  };

  static List<MemberEntity> _applyViewerMembershipBadge(
    List<MemberEntity> members, {
    required String viewerMembershipId,
    required String viewerBadge,
  }) {
    final badge = MemberEntity.memberBadgeFromApi(viewerBadge);
    final membershipId = viewerMembershipId.trim();
    if (badge.isEmpty || membershipId.isEmpty) return members;

    return members
        .map((member) {
          if (member.membershipId.trim() != membershipId) return member;
          if (member.badge.trim().isNotEmpty) return member;
          return member.copyWith(badge: badge);
        })
        .toList(growable: false);
  }

  static List<MemberEntity> _applyViewerMembershipPenalty(
    List<MemberEntity> members, {
    required _MembershipPayload viewerMembership,
  }) {
    final membershipId = viewerMembership.membershipId.trim();
    if (membershipId.isEmpty) return members;

    final viewerBadge = MemberEntity.memberBadgeFromApi(viewerMembership.badge);
    return members
        .map((member) {
          if (member.membershipId.trim() != membershipId) return member;
          return member.copyWith(
            isDefaulted:
                viewerMembership.isDefaulted || member.isDefaulted,
            overdueAmount:
                viewerMembership.overdueAmount ?? member.overdueAmount,
            badge: member.badge.trim().isNotEmpty ? member.badge : viewerBadge,
          );
        })
        .toList(growable: false);
  }

  static String _initials(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
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
}

class _PaginatedSection {
  final List<Map<String, dynamic>> items;
  final PaginationDto pagination;

  const _PaginatedSection({
    required this.items,
    required this.pagination,
  });
}

class _VotingPayload {
  final String startedAtUtc;
  final String deadlineAtUtc;
  final int agreedCount;
  final int disagreedCount;
  final int pendingCount;
  final bool hasVoted;
  final bool isFinalized;
  final List<ProjectVotingMemberVoteEntity> memberVotes;
  final ClosureVoteType? voteType;
  final ClosureVoteOutcome? outcome;
  final bool? isApproved;
  final int? eligibleVoterCount;
  final String? distributionStatus;
  final double viewerRefundAmount;

  const _VotingPayload({
    required this.startedAtUtc,
    required this.deadlineAtUtc,
    required this.agreedCount,
    required this.disagreedCount,
    required this.pendingCount,
    this.hasVoted = false,
    this.isFinalized = false,
    this.memberVotes = const [],
    this.voteType,
    this.outcome,
    this.isApproved,
    this.eligibleVoterCount,
    this.distributionStatus,
    this.viewerRefundAmount = 0,
  });

  factory _VotingPayload.fromJson(Map<String, dynamic> json) {
    final voteTypeRaw = json['voteType']?.toString();
    final outcomeRaw = json['outcome']?.toString();
    return _VotingPayload(
      startedAtUtc: _jsonString(json['startedAtUtc']),
      deadlineAtUtc: _jsonString(json['deadlineAtUtc']),
      agreedCount: (json['agreedCount'] as num?)?.toInt() ?? 0,
      disagreedCount: (json['disagreedCount'] as num?)?.toInt() ?? 0,
      pendingCount: (json['pendingCount'] as num?)?.toInt() ?? 0,
      hasVoted: json['hasVoted'] == true,
      isFinalized: json['isFinalized'] == true,
      memberVotes: _parseMemberVotes(json['memberVotes']),
      voteType: voteTypeRaw != null && voteTypeRaw.trim().isNotEmpty
          ? parseClosureVoteType(voteTypeRaw)
          : null,
      outcome: outcomeRaw != null && outcomeRaw.trim().isNotEmpty
          ? parseClosureVoteOutcome(outcomeRaw)
          : null,
      isApproved: json['isApproved'] is bool
          ? json['isApproved'] as bool
          : null,
      eligibleVoterCount: (json['eligibleVoterCount'] as num?)?.toInt(),
      distributionStatus: _nullableString(json['distributionStatus']),
      viewerRefundAmount:
          (json['viewerRefundAmount'] as num?)?.toDouble() ?? 0.0,
    );
  }

  static List<ProjectVotingMemberVoteEntity> _parseMemberVotes(dynamic raw) {
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map((item) => item.cast<String, dynamic>())
        .map(_memberVoteFromJson)
        .toList(growable: false);
  }

  static ProjectVotingMemberVoteEntity _memberVoteFromJson(
    Map<String, dynamic> json,
  ) {
    final firstName = _jsonString(json['firstName']);
    final lastName = _jsonString(json['lastName']);
    final userName = _jsonString(json['userName']);
    final displayName = _jsonString(json['displayName']).isNotEmpty
        ? _jsonString(json['displayName'])
        : [
            firstName,
            lastName,
          ].where((s) => s.isNotEmpty).join(' ').trim().isNotEmpty
        ? [firstName, lastName].where((s) => s.isNotEmpty).join(' ')
        : userName;

    final voteStatusRaw = json['voteStatus'] ?? json['vote'];
    return ProjectVotingMemberVoteEntity(
      membershipId: _jsonString(json['membershipId']),
      userId: _jsonString(json['userId']),
      displayName: displayName,
      status: parseProjectMemberVoteStatus(voteStatusRaw?.toString()),
    );
  }

  ProjectVotingSummaryEntity toEntity() {
    final started = _parseUtcDateTimeOrNull(startedAtUtc) ?? DateTime.now().toUtc();
    final deadline = _parseUtcDateTimeOrNull(deadlineAtUtc) ?? started;
    return ProjectVotingSummaryEntity(
      startedAtUtc: started,
      deadlineAtUtc: deadline,
      agreedCount: agreedCount,
      disagreedCount: disagreedCount,
      pendingCount: pendingCount,
      hasVoted: hasVoted,
      isFinalized: isFinalized,
      memberVotes: memberVotes,
      voteType: voteType,
      outcome: outcome,
      isApproved: isApproved,
      eligibleVoterCount: eligibleVoterCount,
      distributionStatus: distributionStatus,
      viewerRefundAmount: viewerRefundAmount,
    );
  }
}

String _jsonString(dynamic value) {
  if (value == null) return '';
  return value.toString();
}

DateTime? _parseUtcDateTimeOrNull(String raw) {
  final trimmed = raw.trim();
  if (trimmed.isEmpty) return null;
  return DateTime.tryParse(trimmed)?.toUtc();
}

double? _jsonDoubleNullable(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}

double? _jsonDoubleNullableFromKeys(
  Map<String, dynamic> json,
  List<String> keys,
) {
  for (final key in keys) {
    final parsed = _jsonDoubleNullable(json[key]);
    if (parsed != null) return parsed;
  }
  return null;
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
  final double totalContributed;

  /// When present on `project`, shown instead of [raisedAmount] on project detail.
  final double? potAmount;

  /// Viewer refund when pot/raised/contributions are zero (cancelled/refund).
  final double viewerRefundAmount;
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
  final String? coverImageUrl;
  final List<ProjectImageModel> images;

  const _ProjectPayload({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.visibility,
    required this.lifecycleState,
    required this.targetAmount,
    required this.raisedAmount,
    this.totalContributed = 0,
    this.potAmount,
    this.viewerRefundAmount = 0,
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
    this.coverImageUrl,
    this.images = const [],
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
      totalContributed:
          (json['totalContributed'] as num?)?.toDouble() ?? 0.0,
      viewerRefundAmount:
          (json['viewerRefundAmount'] as num?)?.toDouble() ?? 0.0,
      potAmount: json.containsKey('potAmount')
          ? (json['potAmount'] as num?)?.toDouble() ?? 0.0
          : null,
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
      coverImageUrl: json.safeStringNullable('coverImageUrl'),
      images: ProjectImageModel.listFromJson(json['images']),
    );
  }

  /// `potAmount` when API sends it (including `0`); otherwise [raisedAmount].
  double get displayPotAmount => potAmount ?? raisedAmount;
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
    repaymentWindowDays: (json['repaymentWindowDays'] as num?)?.toInt() ?? 0,
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
  final double? overdueAmount;
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
    this.overdueAmount,
    required this.isDefaulted,
    required this.badge,
    this.photoUrl,
    this.vffAdded = false,
    this.vffConnectionState = VffConnectionState.none,
    this.canSendVffRequest = false,
    this.pendingVffRequestId,
  });

  factory _MembershipPayload.fromJson(Map<String, dynamic> json) {
    final vffConnectionState = membershipVffConnectionStateFromJson(json);
    return _MembershipPayload(
      membershipId: _jsonString(json['membershipId']),
      userId: _jsonString(json['userId']),
      userName: _jsonString(json['userName']),
      firstName: _jsonString(json['firstName']),
      lastName: _jsonString(json['lastName']),
      role: membershipRoleApiValueToString(json['role']),
      status: membershipStatusApiValueToString(json['status']),
      borrowLimitAmount: _jsonDoubleNullable(json['borrowLimitAmount']),
      overdueAmount: _jsonDoubleNullableFromKeys(json, const [
        'overdueAmount',
        'totalOverdue',
        'overdueBorrowAmount',
      ]),
      isDefaulted: json['isDefaulted'] == true,
      badge: _jsonString(json['badge']),
      photoUrl: membershipPhotoUrlFromJson(json),
      vffConnectionState: vffConnectionState,
      vffAdded: membershipViewerVffLinkedFromJson(
        json,
        connectionState: vffConnectionState,
      ),
      canSendVffRequest: json.safeBool('canSendVffRequest'),
      pendingVffRequestId: membershipPendingVffRequestId(json),
    );
  }
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
  final List<ProjectAnnouncementAttachmentModel> attachments;

  const _AnnouncementPayload({
    required this.id,
    required this.heading,
    required this.content,
    this.createdAtUtc,
    this.attachments = const [],
  });

  factory _AnnouncementPayload.fromJson(Map<String, dynamic> json) =>
      _AnnouncementPayload(
        id: _jsonString(json['id']),
        heading: _jsonString(json['heading']),
        content: _jsonString(json['content']),
        createdAtUtc:
            _nullableString(json['createdAtUtc']) ??
            _nullableString(json['createdUtc']),
        attachments: ProjectAnnouncementAttachmentModel.listFromJson(
          json['attachments'],
        ),
      );

  ProjectAnnouncementEntity toEntity() {
    return ProjectAnnouncementResponseModel(
      id: id,
      heading: heading,
      content: content,
      createdAtUtc: createdAtUtc,
      attachments: attachments,
    ).toEntity();
  }
}
