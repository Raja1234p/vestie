import '../../domain/entities/closure_vote_entities.dart';

/// Raw Week 10 API string values — parse here, not in widgets.
abstract final class ClosureVoteApiValues {
  static const voteYes = 'Yes';
  static const voteNo = 'No';

  static const voteTypeSuccess = 'SuccessVote';
  static const voteTypeStopContributions = 'StopContributionsVote';
  static const voteTypeFinalClosure = 'FinalClosureVote';

  static const statusOpen = 'Open';

  static const outcomeSuccess = 'Success';
  static const outcomeInvestmentStarted = 'InvestmentStarted';
  static const outcomeRefund = 'Refund';
  static const outcomeDisputed = 'Disputed';
}

class ActiveClosureVoteResponseModel {
  final String closureVoteId;
  final String voteTypeRaw;
  final String statusRaw;
  final String votingDeadlineUtc;
  final int daysRemaining;
  final int thumbsUp;
  final int thumbsDown;
  final int notYetVoted;
  final double goalAmount;
  final double totalRaised;
  final int memberCount;
  final String? callerVoteRaw;
  final bool callerIsGroupLeader;

  const ActiveClosureVoteResponseModel({
    required this.closureVoteId,
    required this.voteTypeRaw,
    required this.statusRaw,
    required this.votingDeadlineUtc,
    required this.daysRemaining,
    required this.thumbsUp,
    required this.thumbsDown,
    required this.notYetVoted,
    required this.goalAmount,
    required this.totalRaised,
    required this.memberCount,
    this.callerVoteRaw,
    this.callerIsGroupLeader = false,
  });

  factory ActiveClosureVoteResponseModel.fromJson(Map<String, dynamic> json) {
    return ActiveClosureVoteResponseModel(
      closureVoteId: _string(json['closureVoteId']),
      voteTypeRaw: _string(json['voteType']),
      statusRaw: _string(json['status']),
      votingDeadlineUtc: _string(json['votingDeadlineUtc']),
      daysRemaining: (json['daysRemaining'] as num?)?.toInt() ?? 0,
      thumbsUp: (json['thumbsUp'] as num?)?.toInt() ?? 0,
      thumbsDown: (json['thumbsDown'] as num?)?.toInt() ?? 0,
      notYetVoted: (json['notYetVoted'] as num?)?.toInt() ?? 0,
      goalAmount: (json['goalAmount'] as num?)?.toDouble() ?? 0,
      totalRaised: (json['totalRaised'] as num?)?.toDouble() ?? 0,
      memberCount: (json['memberCount'] as num?)?.toInt() ?? 0,
      callerVoteRaw: _nullableString(json['callerVote']),
      callerIsGroupLeader: json['callerIsGL'] == true,
    );
  }

  ActiveClosureVoteEntity toEntity() {
    return ActiveClosureVoteEntity(
      closureVoteId: closureVoteId,
      voteType: parseClosureVoteType(voteTypeRaw),
      status: parseClosureVoteStatus(statusRaw),
      votingDeadlineUtc: DateTime.parse(votingDeadlineUtc).toUtc(),
      daysRemaining: daysRemaining,
      thumbsUp: thumbsUp,
      thumbsDown: thumbsDown,
      notYetVoted: notYetVoted,
      goalAmount: goalAmount,
      totalRaised: totalRaised,
      memberCount: memberCount,
      callerVote: parseClosureVoteValue(callerVoteRaw),
      callerIsGroupLeader: callerIsGroupLeader,
    );
  }
}

class OpenClosureVoteResponseModel {
  final String closureVoteId;
  final String voteTypeRaw;
  final String votingDeadlineUtc;
  final int votingWindowDays;
  final String statusRaw;
  final int thumbsUp;
  final int thumbsDown;
  final int notYetVoted;

  const OpenClosureVoteResponseModel({
    required this.closureVoteId,
    required this.voteTypeRaw,
    required this.votingDeadlineUtc,
    required this.votingWindowDays,
    required this.statusRaw,
    required this.thumbsUp,
    required this.thumbsDown,
    required this.notYetVoted,
  });

  factory OpenClosureVoteResponseModel.fromJson(Map<String, dynamic> json) {
    return OpenClosureVoteResponseModel(
      closureVoteId: _string(json['closureVoteId']),
      voteTypeRaw: _string(json['voteType']),
      votingDeadlineUtc: _string(json['votingDeadlineUtc']),
      votingWindowDays: (json['votingWindowDays'] as num?)?.toInt() ?? 0,
      statusRaw: _string(json['status']),
      thumbsUp: (json['thumbsUp'] as num?)?.toInt() ?? 0,
      thumbsDown: (json['thumbsDown'] as num?)?.toInt() ?? 0,
      notYetVoted: (json['notYetVoted'] as num?)?.toInt() ?? 0,
    );
  }

  OpenClosureVoteEntity toEntity() {
    return OpenClosureVoteEntity(
      closureVoteId: closureVoteId,
      voteType: parseClosureVoteType(voteTypeRaw),
      votingDeadlineUtc: DateTime.parse(votingDeadlineUtc).toUtc(),
      votingWindowDays: votingWindowDays,
      status: parseClosureVoteStatus(statusRaw),
      thumbsUp: thumbsUp,
      thumbsDown: thumbsDown,
      notYetVoted: notYetVoted,
    );
  }
}

class CastClosureVoteResponseModel {
  final String closureVoteId;
  final String callerVoteRaw;
  final int thumbsUp;
  final int thumbsDown;
  final int notYetVoted;

  const CastClosureVoteResponseModel({
    required this.closureVoteId,
    required this.callerVoteRaw,
    required this.thumbsUp,
    required this.thumbsDown,
    required this.notYetVoted,
  });

  factory CastClosureVoteResponseModel.fromJson(Map<String, dynamic> json) {
    return CastClosureVoteResponseModel(
      closureVoteId: _string(json['closureVoteId']),
      callerVoteRaw: _string(json['callerVote']),
      thumbsUp: (json['thumbsUp'] as num?)?.toInt() ?? 0,
      thumbsDown: (json['thumbsDown'] as num?)?.toInt() ?? 0,
      notYetVoted: (json['notYetVoted'] as num?)?.toInt() ?? 0,
    );
  }

  CastClosureVoteResultEntity toEntity() {
    return CastClosureVoteResultEntity(
      closureVoteId: closureVoteId,
      callerVote: parseClosureVoteValue(callerVoteRaw) ?? ClosureVoteValue.yes,
      thumbsUp: thumbsUp,
      thumbsDown: thumbsDown,
      notYetVoted: notYetVoted,
    );
  }
}

class FinalizeClosureVoteResponseModel {
  final String closureVoteId;
  final String voteTypeRaw;
  final String outcomeRaw;
  final int thumbsUp;
  final int thumbsDown;
  final int notYetVoted;
  final String projectStatus;

  const FinalizeClosureVoteResponseModel({
    required this.closureVoteId,
    required this.voteTypeRaw,
    required this.outcomeRaw,
    required this.thumbsUp,
    required this.thumbsDown,
    required this.notYetVoted,
    required this.projectStatus,
  });

  factory FinalizeClosureVoteResponseModel.fromJson(Map<String, dynamic> json) {
    return FinalizeClosureVoteResponseModel(
      closureVoteId: _string(json['closureVoteId']),
      voteTypeRaw: _string(json['voteType']),
      outcomeRaw: _string(json['outcome']),
      thumbsUp: (json['thumbsUp'] as num?)?.toInt() ?? 0,
      thumbsDown: (json['thumbsDown'] as num?)?.toInt() ?? 0,
      notYetVoted: (json['notYetVoted'] as num?)?.toInt() ?? 0,
      projectStatus: _string(json['projectStatus']),
    );
  }

  FinalizeClosureVoteResultEntity toEntity() {
    return FinalizeClosureVoteResultEntity(
      closureVoteId: closureVoteId,
      voteType: parseClosureVoteType(voteTypeRaw),
      outcome: parseClosureVoteOutcome(outcomeRaw),
      thumbsUp: thumbsUp,
      thumbsDown: thumbsDown,
      notYetVoted: notYetVoted,
      projectStatus: projectStatus,
    );
  }
}

String closureVoteTypeToApiValue(ClosureVoteType type) {
  return switch (type) {
    ClosureVoteType.successVote => ClosureVoteApiValues.voteTypeSuccess,
    ClosureVoteType.stopContributionsVote =>
      ClosureVoteApiValues.voteTypeStopContributions,
    ClosureVoteType.finalClosureVote => ClosureVoteApiValues.voteTypeFinalClosure,
  };
}

String closureVoteValueToApiValue(bool voteForSuccess) {
  return voteForSuccess ? ClosureVoteApiValues.voteYes : ClosureVoteApiValues.voteNo;
}

ClosureVoteType parseClosureVoteType(String raw) {
  switch (raw.trim()) {
    case ClosureVoteApiValues.voteTypeStopContributions:
      return ClosureVoteType.stopContributionsVote;
    case ClosureVoteApiValues.voteTypeFinalClosure:
      return ClosureVoteType.finalClosureVote;
    case ClosureVoteApiValues.voteTypeSuccess:
    default:
      return ClosureVoteType.successVote;
  }
}

ClosureVoteStatus parseClosureVoteStatus(String raw) {
  if (raw.trim() == ClosureVoteApiValues.statusOpen) {
    return ClosureVoteStatus.open;
  }
  return ClosureVoteStatus.closed;
}

ClosureVoteOutcome parseClosureVoteOutcome(String raw) {
  switch (raw.trim()) {
    case ClosureVoteApiValues.outcomeInvestmentStarted:
      return ClosureVoteOutcome.investmentStarted;
    case ClosureVoteApiValues.outcomeRefund:
      return ClosureVoteOutcome.refund;
    case ClosureVoteApiValues.outcomeDisputed:
      return ClosureVoteOutcome.disputed;
    case ClosureVoteApiValues.outcomeSuccess:
    default:
      return ClosureVoteOutcome.success;
  }
}

ClosureVoteValue? parseClosureVoteValue(String? raw) {
  if (raw == null || raw.trim().isEmpty) return null;
  switch (raw.trim()) {
    case ClosureVoteApiValues.voteNo:
      return ClosureVoteValue.no;
    case ClosureVoteApiValues.voteYes:
      return ClosureVoteValue.yes;
    default:
      return null;
  }
}

Map<String, dynamic> _asMap(dynamic data) {
  if (data is Map<String, dynamic>) return data;
  if (data is Map) return Map<String, dynamic>.from(data);
  return <String, dynamic>{};
}

Map<String, dynamic> parseClosureVotingResponseMap(dynamic data) => _asMap(data);

String _string(dynamic value) => value?.toString().trim() ?? '';

String? _nullableString(dynamic value) {
  if (value == null) return null;
  final s = value.toString().trim();
  return s.isEmpty ? null : s;
}
