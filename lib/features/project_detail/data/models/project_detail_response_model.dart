import '../../domain/entities/borrow_request_entity.dart';
import '../../domain/entities/member_entity.dart';
import '../../domain/entities/project_detail_entity.dart';
import '../../../home/domain/entities/project.dart';

class ProjectDetailResponseModel {
  final _ProjectPayload _project;
  final _RulesPayload _rules;
  final _ViewerMembershipPayload _viewerMembership;
  final List<_MemberPayload> _members;

  const ProjectDetailResponseModel._({
    required _ProjectPayload project,
    required _RulesPayload rules,
    required _ViewerMembershipPayload viewerMembership,
    required List<_MemberPayload> members,
  })  : _project = project,
        _rules = rules,
        _viewerMembership = viewerMembership,
        _members = members;

  factory ProjectDetailResponseModel.fromJson(Map<String, dynamic> json) {
    final projectJson = (json['project'] as Map?)?.cast<String, dynamic>() ?? const <String, dynamic>{};
    final rulesJson = (json['rules'] as Map?)?.cast<String, dynamic>() ?? const <String, dynamic>{};
    final viewerMembershipJson =
        (json['viewerMembership'] as Map?)?.cast<String, dynamic>() ?? const <String, dynamic>{};
    final membersJson = (json['members'] as List?)?.whereType<Map>().map((m) => m.cast<String, dynamic>()).toList() ?? const <Map<String, dynamic>>[];

    return ProjectDetailResponseModel._(
      project: _ProjectPayload.fromJson(projectJson),
      rules: _RulesPayload.fromJson(rulesJson),
      viewerMembership: _ViewerMembershipPayload.fromJson(viewerMembershipJson),
      members: membersJson.map(_MemberPayload.fromJson).toList(growable: false),
    );
  }

  ProjectDetailEntity toEntity() {
    final isLeader = _viewerMembership.isLeader;

    final mappedMembers = _members.map(_mapMember).toList(growable: false);

    return ProjectDetailEntity(
      id: _project.id,
      name: _project.name,
      category: _mapCategory(_project.type),
      status: _mapStatus(_project.state),
      goalAmount: _project.targetAmount,
      // Week4 detail response doesn't include pot balance yet in this endpoint.
      currentAmount: 0.0,
      endsIn: _endsInLabel(_project.endsAtUtc),
      announcement: '',
      members: mappedMembers,
      borrowRequests: const <BorrowRequestEntity>[],
      isLeader: isLeader,
      membershipId: _viewerMembership.membershipId,
      borrowLimitAmount: _viewerMembership.borrowLimitAmount,
      repaymentWindowDays: _rules.repaymentWindowDays,
      repaymentGraceDays: _rules.repaymentGraceDays,
      contributionsAreNonRefundable: _rules.contributionsAreNonRefundable,
    );
  }

  static MemberEntity _mapMember(_MemberPayload json) {
    final firstName = json.firstName;
    final lastName = json.lastName;
    final userName = json.userName;
    final fullName = ('$firstName $lastName').trim().isNotEmpty
        ? ('$firstName $lastName').trim()
        : userName;

    final mappedRole = switch (json.role.toLowerCase()) {
      'leader' => MemberRole.leader,
      'co-leader' => MemberRole.coLeader,
      'coleader' => MemberRole.coLeader,
      _ => MemberRole.member,
    };

    final initials = _initials(fullName);

    return MemberEntity(
      id: json.userId.isEmpty ? json.membershipId : json.userId,
      membershipId: json.membershipId,
      userId: json.userId,
      initials: initials,
      name: fullName.isEmpty ? 'Member' : fullName,
      username: userName,
      status: json.status,
      role: mappedRole,
      contributedAmount: 0,
      overdueAmount: null,
    );
  }

  static String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return 'NA';
    String firstChar(String s) => s.isEmpty ? 'N' : s[0].toUpperCase();
    final first = firstChar(parts.first);
    final last = firstChar(parts.length > 1 ? parts.last : parts.first);
    return '$first$last';
  }

  static String _endsInLabel(String? endsAtUtc) {
    if (endsAtUtc == null || endsAtUtc.isEmpty) return '';
    // Keep simple label for now; can be improved with real time-ago logic.
    return endsAtUtc;
  }

  static ProjectCategory _mapCategory(String type) {
    final t = type.toLowerCase().trim();
    if (t.contains('invest')) return ProjectCategory.investment;
    if (t.contains('emerg')) return ProjectCategory.emergency;
    return ProjectCategory.vacations;
  }

  static ProjectStatus _mapStatus(String state) {
    final s = state.toLowerCase().trim();
    if (s.contains('complete') || s.contains('cancel')) return ProjectStatus.completed;
    return ProjectStatus.ongoing;
  }
}

class _ProjectPayload {
  final String id;
  final String name;
  final String type;
  final String state;
  final double targetAmount;
  final String endsAtUtc;

  const _ProjectPayload({
    required this.id,
    required this.name,
    required this.type,
    required this.state,
    required this.targetAmount,
    required this.endsAtUtc,
  });

  factory _ProjectPayload.fromJson(Map<String, dynamic> json) => _ProjectPayload(
        id: (json['id'] as String?) ?? '',
        name: (json['name'] as String?) ?? '',
        type: (json['type'] as String?) ?? '',
        state: (json['state'] as String?) ?? '',
        targetAmount: (json['targetAmount'] as num?)?.toDouble() ?? 0.0,
        endsAtUtc: (json['endsAtUtc'] as String?) ?? '',
      );
}

class _RulesPayload {
  final int repaymentWindowDays;
  final int repaymentGraceDays;
  final bool contributionsAreNonRefundable;

  const _RulesPayload({
    required this.repaymentWindowDays,
    required this.repaymentGraceDays,
    required this.contributionsAreNonRefundable,
  });

  factory _RulesPayload.fromJson(Map<String, dynamic> json) => _RulesPayload(
        repaymentWindowDays: (json['repaymentWindowDays'] as num?)?.toInt() ?? 0,
        repaymentGraceDays: (json['repaymentGraceDays'] as num?)?.toInt() ?? 0,
        contributionsAreNonRefundable:
            (json['contributionsAreNonRefundable'] as bool?) ?? false,
      );
}

class _ViewerMembershipPayload {
  final String membershipId;
  final String role;
  final double borrowLimitAmount;

  const _ViewerMembershipPayload({
    required this.membershipId,
    required this.role,
    required this.borrowLimitAmount,
  });

  factory _ViewerMembershipPayload.fromJson(Map<String, dynamic> json) => _ViewerMembershipPayload(
        membershipId: (json['membershipId'] as String?) ?? '',
        role: (json['role'] as String?) ?? '',
        borrowLimitAmount: (json['borrowLimitAmount'] as num?)?.toDouble() ?? 0.0,
      );

  bool get isLeader => role.toLowerCase().contains('leader');
}

class _MemberPayload {
  final String membershipId;
  final String userId;
  final String userName;
  final String firstName;
  final String lastName;
  final String role;
  final String status;

  const _MemberPayload({
    required this.membershipId,
    required this.userId,
    required this.userName,
    required this.firstName,
    required this.lastName,
    required this.role,
    required this.status,
  });

  factory _MemberPayload.fromJson(Map<String, dynamic> json) => _MemberPayload(
        membershipId: (json['membershipId'] as String?) ?? '',
        userId: (json['userId'] as String?) ?? '',
        userName: (json['userName'] as String?) ?? '',
        firstName: (json['firstName'] as String?) ?? '',
        lastName: (json['lastName'] as String?) ?? '',
        role: (json['role'] as String?) ?? '',
        status: (json['status'] as String?) ?? '',
      );
}

