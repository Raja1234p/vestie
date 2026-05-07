import '../../domain/entities/borrow_request_entity.dart';
import '../../domain/entities/member_entity.dart';
import '../../domain/entities/project_detail_entity.dart';
import '../../../home/domain/entities/project.dart';

class ProjectDetailResponseModel {
  final Map<String, dynamic> project;
  final Map<String, dynamic> rules;
  final Map<String, dynamic> viewerMembership;
  final List<Map<String, dynamic>> members;

  const ProjectDetailResponseModel({
    required this.project,
    required this.rules,
    required this.viewerMembership,
    required this.members,
  });

  factory ProjectDetailResponseModel.fromJson(Map<String, dynamic> json) {
    return ProjectDetailResponseModel(
      project: (json['project'] as Map?)?.cast<String, dynamic>() ?? const {},
      rules: (json['rules'] as Map?)?.cast<String, dynamic>() ?? const {},
      viewerMembership:
          (json['viewerMembership'] as Map?)?.cast<String, dynamic>() ?? const {},
      members: (json['members'] as List?)
              ?.whereType<Map>()
              .map((m) => m.cast<String, dynamic>())
              .toList() ??
          const [],
    );
  }

  ProjectDetailEntity toEntity() {
    final id = (project['id'] as String?) ?? '';
    final name = (project['name'] as String?) ?? '';
    final type = (project['type'] as String?) ?? '';
    final state = (project['state'] as String?) ?? '';

    final goalAmount = (project['targetAmount'] as num?)?.toDouble() ?? 0.0;

    final role = (viewerMembership['role'] as String?) ?? '';
    final isLeader = role.toLowerCase().contains('leader');
    final membershipId = (viewerMembership['membershipId'] as String?) ?? '';
    final borrowLimitAmount =
        (viewerMembership['borrowLimitAmount'] as num?)?.toDouble() ?? 0.0;

    final repaymentWindowDays =
        (rules['repaymentWindowDays'] as num?)?.toInt() ?? 0;
    final repaymentGraceDays =
        (rules['repaymentGraceDays'] as num?)?.toInt() ?? 0;
    final nonRefundable =
        (rules['contributionsAreNonRefundable'] as bool?) ?? false;

    final mappedMembers = members.map(_mapMember).toList(growable: false);

    return ProjectDetailEntity(
      id: id,
      name: name,
      category: _mapCategory(type),
      status: _mapStatus(state),
      goalAmount: goalAmount,
      // Week4 detail response doesn't include pot balance yet in this endpoint.
      currentAmount: 0.0,
      endsIn: _endsInLabel(project['endsAtUtc'] as String?),
      announcement: '',
      members: mappedMembers,
      borrowRequests: const <BorrowRequestEntity>[],
      isLeader: isLeader,
      membershipId: membershipId,
      borrowLimitAmount: borrowLimitAmount,
      repaymentWindowDays: repaymentWindowDays,
      repaymentGraceDays: repaymentGraceDays,
      contributionsAreNonRefundable: nonRefundable,
    );
  }

  static MemberEntity _mapMember(Map<String, dynamic> json) {
    final firstName = (json['firstName'] as String?) ?? '';
    final lastName = (json['lastName'] as String?) ?? '';
    final userName = (json['userName'] as String?) ?? '';
    final fullName = ('$firstName $lastName').trim().isNotEmpty
        ? ('$firstName $lastName').trim()
        : userName;

    final role = (json['role'] as String?) ?? '';
    final mappedRole = switch (role.toLowerCase()) {
      'leader' => MemberRole.leader,
      'co-leader' => MemberRole.coLeader,
      'coleader' => MemberRole.coLeader,
      _ => MemberRole.member,
    };

    final initials = _initials(fullName);

    return MemberEntity(
      id: (json['membershipId'] as String?) ?? (json['userId'] as String?) ?? '',
      initials: initials,
      name: fullName.isEmpty ? 'Member' : fullName,
      username: userName,
      status: (json['status'] as String?) ?? '',
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
    if (s.contains('complete')) return ProjectStatus.completed;
    return ProjectStatus.ongoing;
  }
}

