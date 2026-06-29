import 'package:flutter_test/flutter_test.dart';
import 'package:vestie/features/project_detail/data/models/project_detail_response_model.dart';
import 'package:vestie/features/project_detail/domain/entities/project_detail_voting_entities.dart';

void main() {
  group('ProjectDetailResponseModel Week 11 voting fields', () {
    Map<String, dynamic> minimalJson({
      String? projectStatus,
      String? votingStatus,
      String? userRole,
      Map<String, dynamic>? voting,
    }) {
      return {
        'project': {
          'id': 'p1',
          'name': 'Trip',
          'description': '',
          'type': 'vacation',
          'visibility': 'private',
          'state': 'active',
          'targetAmount': 5000,
          'raisedAmount': 4000,
          'endsAtUtc': '2026-12-31T00:00:00Z',
        },
        'rules': {},
        'viewerMembership': {
          'membershipId': 'vm1',
          'userId': 'u1',
          'userName': 'member',
          'firstName': 'Mem',
          'lastName': 'Ber',
          'role': 'member',
          'status': 'active',
          'badge': '',
        },
        'members': [],
        'invites': [],
        'announcements': [],
        if (projectStatus != null) 'projectStatus': projectStatus,
        if (votingStatus != null) 'votingStatus': votingStatus,
        if (userRole != null) 'userRole': userRole,
        if (voting != null) 'voting': voting,
      };
    }

    test('parses projectStatus, votingStatus, userRole, and voting summary', () {
      final entity = ProjectDetailResponseModel.fromJson(
        minimalJson(
          projectStatus: 'ongoing',
          votingStatus: 'pending',
          userRole: 'member',
          voting: {
            'startedAtUtc': '2026-05-01T10:00:00Z',
            'deadlineAtUtc': '2026-05-12T23:59:59Z',
            'agreedCount': 4,
            'disagreedCount': 2,
            'pendingCount': 5,
            'hasVoted': false,
            'isFinalized': false,
          },
        ),
      ).toEntity();

      expect(entity.projectBannerStatus, ProjectDetailBannerStatus.ongoing);
      expect(entity.votingStatus, ProjectVotingStatus.pending);
      expect(entity.detailUserRole, ProjectDetailUserRole.member);
      expect(entity.voting, isNotNull);
      expect(entity.voting!.agreedCount, 4);
      expect(entity.hasActiveSuccessVote, isTrue);
      expect(entity.showsInlineMemberCastVote, isTrue);
      expect(entity.activeClosureVote, isNotNull);
    });

    test('member with hasVoted true does not show inline cast', () {
      final entity = ProjectDetailResponseModel.fromJson(
        minimalJson(
          projectStatus: 'ongoing',
          votingStatus: 'pending',
          userRole: 'member',
          voting: {
            'startedAtUtc': '2026-05-01T10:00:00Z',
            'deadlineAtUtc': '2026-05-12T23:59:59Z',
            'agreedCount': 1,
            'disagreedCount': 0,
            'pendingCount': 0,
            'hasVoted': true,
            'isFinalized': false,
          },
        ),
      ).toEntity();

      expect(entity.showsInlineMemberCastVote, isFalse);
      expect(entity.showsMemberVoteSubmittedLabel, isTrue);
    });

    test('co-leader with pending vote shows inline cast', () {
      final entity = ProjectDetailResponseModel.fromJson(
        minimalJson(
          projectStatus: 'ongoing',
          votingStatus: 'pending',
          userRole: 'co_leader',
          voting: {
            'startedAtUtc': '2026-05-01T10:00:00Z',
            'deadlineAtUtc': '2026-05-12T23:59:59Z',
            'agreedCount': 2,
            'disagreedCount': 1,
            'pendingCount': 3,
            'hasVoted': false,
            'isFinalized': false,
          },
        ),
      ).toEntity();

      expect(entity.isDetailCoLeader, isTrue);
      expect(entity.showsInlineMemberCastVote, isTrue);
    });

    test('co-leader with hasVoted true shows vote submitted label', () {
      final entity = ProjectDetailResponseModel.fromJson(
        minimalJson(
          projectStatus: 'ongoing',
          votingStatus: 'pending',
          userRole: 'co_leader',
          voting: {
            'startedAtUtc': '2026-05-01T10:00:00Z',
            'deadlineAtUtc': '2026-05-12T23:59:59Z',
            'agreedCount': 3,
            'disagreedCount': 0,
            'pendingCount': 0,
            'hasVoted': true,
            'isFinalized': false,
          },
        ),
      ).toEntity();

      expect(entity.showsInlineMemberCastVote, isFalse);
      expect(entity.showsMemberVoteSubmittedLabel, isTrue);
    });

    test('co-leader can start voting when not_started', () {
      final entity = ProjectDetailResponseModel.fromJson(
        minimalJson(
          projectStatus: 'ongoing',
          votingStatus: 'not_started',
          userRole: 'co_leader',
        ),
      ).toEntity();

      expect(entity.canStartVotingOnDetail, isTrue);
      expect(entity.showsCastVoteAction, isFalse);
      expect(entity.showsProjectDetailVotingCard, isFalse);
    });

    test('ongoing project hides voting card until voting starts', () {
      final entity = ProjectDetailResponseModel.fromJson(
        minimalJson(
          projectStatus: 'ongoing',
          votingStatus: 'not_started',
          userRole: 'leader',
        ),
      ).toEntity();

      expect(entity.showsProjectDetailVotingCard, isFalse);
    });

    test('ongoing project never shows detail voting card', () {
      final entity = ProjectDetailResponseModel.fromJson(
        minimalJson(
          projectStatus: 'ongoing',
          votingStatus: 'pending',
          userRole: 'leader',
          voting: {
            'startedAtUtc': '2026-05-01T10:00:00Z',
            'deadlineAtUtc': '2026-05-12T23:59:59Z',
            'agreedCount': 1,
            'disagreedCount': 0,
            'pendingCount': 2,
            'hasVoted': false,
            'isFinalized': false,
          },
        ),
      ).toEntity();

      expect(entity.showsProjectDetailVotingCard, isFalse);
    });

    test('completed project hides voting card', () {
      final entity = ProjectDetailResponseModel.fromJson(
        minimalJson(
          projectStatus: 'completed',
          votingStatus: 'not_started',
          userRole: 'leader',
        ),
      ).toEntity();

      expect(entity.showsProjectDetailVotingCard, isFalse);
      expect(entity.projectBannerStatus, ProjectDetailBannerStatus.completed);
    });

    test('legacy response without Week 11 envelope keeps old detail layout', () {
      final entity = ProjectDetailResponseModel.fromJson(
        minimalJson(),
      ).toEntity();

      expect(entity.hasWeek11ProjectDetailEnvelope, isFalse);
      expect(entity.showsProjectDetailStatusBanner, isFalse);
      expect(entity.showsProjectDetailVotingCard, isFalse);
      expect(entity.showsCastVoteAction, isFalse);
      expect(entity.showsViewSuccessVotesAction, isFalse);
      expect(entity.hidesWalletActionsForVoting, isFalse);
    });
  });
}
