import 'package:intl/intl.dart';
import 'package:vestie/core/utils/safe_parser.dart';
import 'package:vestie/features/projects/data/models/project_list_json_parsing.dart';
import 'package:vestie/user/features/vff/domain/entities/vff_enums.dart';

import '../../domain/entities/member_activity_entity.dart';
import '../../domain/entities/member_entity.dart';
import '../../domain/entities/viewer_membership_role.dart';

class MemberActivityResponseModel {
  final MemberEntity member;
  final bool isCoLeader;
  final double totalContributed;
  final int contributionCount;
  final double totalBorrowed;
  final int overdueBorrowCount;
  final double? overdueAmount;
  final double totalReturned;
  final VffConnectionState vffConnectionState;
  final bool canSendVffRequest;
  final String? pendingVffRequestId;
  final List<MemberActivityTransactionEntity> transactions;

  const MemberActivityResponseModel({
    required this.member,
    this.isCoLeader = false,
    required this.totalContributed,
    required this.contributionCount,
    required this.totalBorrowed,
    this.overdueBorrowCount = 0,
    this.overdueAmount,
    this.totalReturned = 0,
    this.vffConnectionState = VffConnectionState.none,
    this.canSendVffRequest = false,
    this.pendingVffRequestId,
    required this.transactions,
  });

  factory MemberActivityResponseModel.fromJson(
    Map<String, dynamic> json, {
    required String projectName,
  }) {
    final summary = _summaryMap(json);
    final totalContributed = _readDouble(
      summary,
      const ['totalContributed', 'contributedTotal', 'totalContributionAmount'],
    );
    final contributionCount = _readInt(
      summary,
      const ['contributionCount', 'contributionsCount', 'numberOfContributions'],
    );
    final totalBorrowed = _readDouble(
      summary,
      const ['totalBorrowed', 'borrowedTotal', 'totalBorrowAmount'],
    );
    final overdueBorrowCount = _readInt(
      summary,
      const ['overdueBorrowCount', 'overdueCount'],
    );
    final overdueAmount = _readDoubleNullable(
      summary,
      const ['overdueAmount', 'totalOverdue', 'overdueBorrowAmount'],
    );
    final totalReturned = _readDouble(
      summary,
      const ['totalReturned', 'returnedTotal'],
    );

    final vffConnectionState = _readVffConnectionState(json);
    final canSendVffRequest = json.safeBool('canSendVffRequest');
    final pendingVffRequestId = json.safeStringNullable('pendingVffRequestId');

    final isCoLeader = _readIsCoLeader(json);
    final member = _mapMember(
      json,
      summary,
      overdueAmount,
      isCoLeader: isCoLeader,
      vffConnectionState: vffConnectionState,
      canSendVffRequest: canSendVffRequest,
      pendingVffRequestId: pendingVffRequestId,
    );
    final transactions = _transactionMaps(json)
        .map(
          (row) => _mapTransaction(
            row,
            projectName: projectName,
          ),
        )
        .toList(growable: false);

    return MemberActivityResponseModel(
      member: member,
      isCoLeader: isCoLeader,
      totalContributed: totalContributed,
      contributionCount: contributionCount,
      totalBorrowed: totalBorrowed,
      overdueBorrowCount: overdueBorrowCount,
      overdueAmount: overdueAmount,
      totalReturned: totalReturned,
      vffConnectionState: vffConnectionState,
      canSendVffRequest: canSendVffRequest,
      pendingVffRequestId: pendingVffRequestId,
      transactions: transactions,
    );
  }

  MemberActivityEntity toEntity() => MemberActivityEntity(
        member: member,
        isCoLeader: isCoLeader,
        totalContributed: totalContributed,
        contributionCount: contributionCount,
        totalBorrowed: totalBorrowed,
        overdueBorrowCount: overdueBorrowCount,
        overdueAmount: overdueAmount,
        totalReturned: totalReturned,
        vffConnectionState: vffConnectionState,
        canSendVffRequest: canSendVffRequest,
        pendingVffRequestId: pendingVffRequestId,
        transactions: transactions,
      );

  static Map<String, dynamic> _summaryMap(Map<String, dynamic> json) {
    return _nested(json, const [
          'summary',
          'stats',
          'totals',
          'activitySummary',
          'metrics',
        ]) ??
        json;
  }

  static Map<String, dynamic>? _nested(
    Map<String, dynamic> json,
    List<String> keys,
  ) {
    for (final key in keys) {
      final value = json[key];
      if (value is Map) return value.cast<String, dynamic>();
    }
    return null;
  }

  static List<Map<String, dynamic>> _transactionMaps(Map<String, dynamic> json) {
    for (final key in const [
      'transactions',
      'activities',
      'ledger',
      'items',
      'entries',
      'history',
    ]) {
      final value = json[key];
      if (value is List) {
        return value
            .whereType<Map>()
            .map((m) => m.cast<String, dynamic>())
            .toList(growable: false);
      }
    }
    return const [];
  }

  static double _readDouble(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final v = json.safeDoubleNullable(key);
      if (v != null) return v;
    }
    return 0;
  }

  static double? _readDoubleNullable(
    Map<String, dynamic> json,
    List<String> keys,
  ) {
    for (final key in keys) {
      final v = json.safeDoubleNullable(key);
      if (v != null) return v;
    }
    return null;
  }

  static int _readInt(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      if (json[key] != null) return json.safeInt(key);
    }
    return 0;
  }

  static bool _readIsCoLeader(Map<String, dynamic> json) {
    if (json.containsKey('isCoLeader')) {
      return json.safeBool('isCoLeader');
    }
    final nested = _nested(json, const [
      'membership',
      'member',
      'viewerMembership',
      'profile',
    ]);
    if (nested != null && nested.containsKey('isCoLeader')) {
      return nested.safeBool('isCoLeader');
    }
    return false;
  }

  static MemberEntity _mapMember(
    Map<String, dynamic> json,
    Map<String, dynamic> summary,
    double? overdueAmount, {
    required bool isCoLeader,
    VffConnectionState vffConnectionState = VffConnectionState.none,
    bool canSendVffRequest = false,
    String? pendingVffRequestId,
  }) {
    final nested = _nested(json, const [
      'membership',
      'member',
      'viewerMembership',
      'profile',
    ]);
    final profile = nested ?? json;

    // Flat activity payload: memberId, memberName, memberUsername, photoURL.
    var userId = json.safeString('memberId');
    if (userId.isEmpty) userId = profile.safeString('userId');

    var displayName = json.safeString('memberName');
    if (displayName.isEmpty) {
      final firstName = profile.safeString('firstName');
      final lastName = profile.safeString('lastName');
      final fullName = '$firstName $lastName'.trim();
      if (fullName.isNotEmpty) {
        displayName = fullName;
      } else {
        displayName = profile.safeString('userName');
      }
    }
    if (displayName.isEmpty) displayName = 'Member';

    var userName = json.safeString('memberUsername');
    if (userName.isEmpty) {
      userName = profile.safeString('userName');
    }
    if (userName.isEmpty) {
      userName = profile.safeString('username');
    }

    final membershipId = profile.safeString('membershipId');

    final roleRaw = profile.containsKey('role')
        ? membershipRoleApiValueToString(profile['role'])
        : json.containsKey('role')
            ? membershipRoleApiValueToString(json['role'])
            : '';
    final mappedRole = roleRaw.isEmpty
        ? MemberRole.member
        : switch (ViewerMembershipRole.parse(roleRaw)) {
            ViewerMembershipRole.groupLeader => MemberRole.leader,
            ViewerMembershipRole.coLeader => MemberRole.coLeader,
            ViewerMembershipRole.member => MemberRole.member,
          };

    final role = mappedRole == MemberRole.leader
        ? MemberRole.leader
        : (isCoLeader ? MemberRole.coLeader : MemberRole.member);

    final contributed = _readDouble(
      summary,
      const ['totalContributed', 'contributedTotal'],
    );

    final photoUrl = membershipPhotoUrlFromJson(json) ??
        membershipPhotoUrlFromJson(profile);

    return MemberEntity(
      id: userId.isNotEmpty ? userId : membershipId,
      membershipId: membershipId,
      userId: userId,
      initials: _initials(displayName),
      name: displayName,
      username: userName,
      status: profile.safeString('status'),
      role: role,
      contributedAmount: contributed,
      overdueAmount: overdueAmount,
      photoUrl: photoUrl,
      vffAdded: membershipVffAddedFromJson(json) ||
          membershipVffAddedFromJson(profile),
      vffConnectionState: vffConnectionState,
      canSendVffRequest: canSendVffRequest,
      pendingVffRequestId: pendingVffRequestId,
    );
  }

  static VffConnectionState _readVffConnectionState(Map<String, dynamic> json) {
    final root = VffConnectionState.parse(
      json.safeStringNullable('vffConnectionState'),
    );
    if (root != VffConnectionState.none) return root;

    final nested = _nested(json, const [
      'membership',
      'member',
      'viewerMembership',
      'profile',
    ]);
    if (nested != null) {
      final fromNested = VffConnectionState.parse(
        nested.safeStringNullable('vffConnectionState'),
      );
      if (fromNested != VffConnectionState.none) return fromNested;
    }
    return VffConnectionState.none;
  }

  static MemberActivityTransactionEntity _mapTransaction(
    Map<String, dynamic> json, {
    required String projectName,
  }) {
    var typeRaw = json.safeString('type');
    if (typeRaw.isEmpty) typeRaw = json.safeString('activityType');
    if (typeRaw.isEmpty) typeRaw = json.safeString('transactionType');

    final kind = _parseKind(typeRaw);
    final amount = json.safeDouble('amount');
    var occurredRaw = json.safeString('occurredAtUtc');
    if (occurredRaw.isEmpty) occurredRaw = json.safeString('createdUtc');
    final displayDate = _formatOccurred(occurredRaw);

    final description = json.safeString('description');
    final title = description.isNotEmpty
        ? description
        : _defaultTitle(kind, projectName);

    return MemberActivityTransactionEntity(
      kind: kind,
      amount: amount,
      displayDate: displayDate,
      title: title,
    );
  }

  static MemberActivityTransactionKind _parseKind(String raw) {
    final t = raw.toLowerCase().trim();
    if (t.contains('contrib')) return MemberActivityTransactionKind.contribution;
    if (t.contains('borrow') || t.contains('loan')) {
      return MemberActivityTransactionKind.borrow;
    }
    return MemberActivityTransactionKind.other;
  }

  static String _defaultTitle(
    MemberActivityTransactionKind kind,
    String projectName,
  ) {
    return switch (kind) {
      MemberActivityTransactionKind.contribution => 'Contribution: $projectName',
      MemberActivityTransactionKind.borrow => 'Borrow: $projectName',
      MemberActivityTransactionKind.other => projectName,
    };
  }

  static String _formatOccurred(String raw) {
    if (raw.trim().isEmpty) return '';
    final parsed = DateTime.tryParse(raw);
    if (parsed == null) return raw;
    return DateFormat('d MMM yyyy').format(parsed.toLocal());
  }

  static String _initials(String name) {
    final parts =
        name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return 'NA';
    String c(String s) => s.isEmpty ? 'N' : s[0].toUpperCase();
    return '${c(parts.first)}${c(parts.length > 1 ? parts.last : parts.first)}';
  }
}
