import 'package:flutter_test/flutter_test.dart';
import 'package:vestie/features/project_detail/data/models/project_detail_response_model.dart';
import 'package:vestie/features/project_detail/domain/entities/member_entity.dart';
import 'package:vestie/features/project_detail/domain/entities/project_detail_member_vote_extensions.dart';
import 'package:vestie/features/project_detail/domain/entities/project_detail_voting_entities.dart';
import 'package:vestie/features/project_detail/presentation/mappers/closure_vote_ui_mappers.dart';
import 'package:vestie/features/project_detail/presentation/mappers/project_detail_voting_ui_mappers.dart';
import 'package:vestie/features/success_vote/presentation/models/success_vote_cast_choice.dart';
import 'package:vestie/leader/features/project_detail/presentation/models/leader_success_vote_progress_ui_data.dart';
import 'package:vestie/user/features/home/domain/entities/project.dart';

/// Locks mobile behavior to [DOCS/backend_handoff_project_detail_voting_api.md].
void main() {
  group('Backend handoff contract — GET /projects/{id} voting', () {
    Map<String, dynamic> handoffLeaderPendingJson() {
      return {
        'project': {
          'id': 'eb3e9b1a-0cd1-4355-9547-751648ec5962',
          'name': 'ggg',
          'description': 'hhh',
          'type': 'vacation',
          'visibility': 'public',
          'state': 'active',
          'targetAmount': 500.0,
          'raisedAmount': 0,
          'potAmount': 0,
          'viewerRole': 'GroupLeader',
          'displayStatus': 'On Going',
        },
        'rules': {},
        'viewerMembership': {
          'membershipId': 'fc2154f0-0c65-452c-b73b-0ce26135750f',
          'userId': 'c90f3acd-5837-41c4-84ec-f58c6cf8cf59',
          'userName': 'rajakumr',
          'firstName': 'test',
          'lastName': 'kdkdk',
          'role': 'groupLead',
          'status': 'active',
        },
        'members': {
          'items': [
            {
              'membershipId': 'fc2154f0-0c65-452c-b73b-0ce26135750f',
              'userId': 'c90f3acd-5837-41c4-84ec-f58c6cf8cf59',
              'userName': 'rajakumr',
              'firstName': 'test',
              'lastName': 'kdkdk',
              'role': 'groupLead',
              'status': 'active',
            },
            {
              'membershipId': 'ea6f4b46-b032-42d7-9aae-9890f34f8d84',
              'userId': '2e820ba5-1f36-4ce8-b8bd-af108c00e232',
              'userName': 'mahazehra',
              'firstName': 'maha',
              'lastName': 'zehra',
              'role': 'member',
              'status': 'active',
            },
          ],
          'pagination': {'page': 1, 'pageSize': 50, 'totalCount': 2, 'totalPages': 1},
        },
        'invites': {
          'items': [],
          'pagination': {'page': 1, 'pageSize': 20, 'totalCount': 0, 'totalPages': 0},
        },
        'announcements': {
          'items': [],
          'pagination': {'page': 1, 'pageSize': 20, 'totalCount': 0, 'totalPages': 0},
        },
        'projectStatus': 'ongoing',
        'votingStatus': 'pending',
        'userRole': 'leader',
        'canStopContributions': false,
        'voting': {
          'startedAtUtc': '2026-06-30T17:55:23+00:00',
          'deadlineAtUtc': '2027-07-30T17:55:23+00:00',
          'agreedCount': 0,
          'disagreedCount': 0,
          'pendingCount': 1,
          'hasVoted': false,
          'isFinalized': false,
          'memberVotes': [
            {
              'membershipId': 'ea6f4b46-b032-42d7-9aae-9890f34f8d84',
              'userId': '2e820ba5-1f36-4ce8-b8bd-af108c00e232',
              'displayName': 'maha zehra',
              'voteStatus': 'waiting',
            },
          ],
        },
      };
    }

    test('leader monitor maps memberVotes waiting row', () {
      final entity = ProjectDetailResponseModel.fromJson(
        handoffLeaderPendingJson(),
      ).toEntity();
      final ui = leaderSuccessVoteProgressFromProjectVoting(
        project: entity,
        voting: entity.voting!,
      );

      expect(ui.agreedCount, 0);
      expect(ui.notVotedCount, 1);
      expect(ui.members, hasLength(1));
      expect(ui.members.first.name, 'maha zehra');
      expect(ui.members.first.status, LeaderMemberVoteStatus.waiting);
      expect(ui.totalMembers, 1);
    });

    test('member cast screen before vote', () {
      final json = handoffLeaderPendingJson()
        ..['userRole'] = 'member'
        ..['viewerMembership'] = {
          'membershipId': 'ea6f4b46-b032-42d7-9aae-9890f34f8d84',
          'userId': '2e820ba5-1f36-4ce8-b8bd-af108c00e232',
          'userName': 'mahazehra',
          'firstName': 'maha',
          'lastName': 'zehra',
          'role': 'member',
          'status': 'active',
        };

      final entity = ProjectDetailResponseModel.fromJson(json).toEntity();

      expect(entity.showsInlineMemberCastVote, isTrue);
      expect(entity.showsInlineMemberVoteSubmittedView, isFalse);
      expect(closureVoteEligibleMemberCountFromProject(entity), 1);
      expect(
        successVoteCastUiDataFromProjectDetail(entity).memberCount,
        1,
      );
    });

    test('member post-vote after agree', () {
      final json = handoffLeaderPendingJson()
        ..['userRole'] = 'member'
        ..['viewerMembership'] = {
          'membershipId': 'ea6f4b46-b032-42d7-9aae-9890f34f8d84',
          'userId': '2e820ba5-1f36-4ce8-b8bd-af108c00e232',
          'userName': 'mahazehra',
          'role': 'member',
          'status': 'active',
        };
      json['voting'] = {
        'startedAtUtc': '2026-06-30T17:55:23+00:00',
        'deadlineAtUtc': '2027-07-30T17:55:23+00:00',
        'agreedCount': 1,
        'disagreedCount': 0,
        'pendingCount': 0,
        'hasVoted': true,
        'isFinalized': false,
        'memberVotes': [
          {
            'membershipId': 'ea6f4b46-b032-42d7-9aae-9890f34f8d84',
            'userId': '2e820ba5-1f36-4ce8-b8bd-af108c00e232',
            'displayName': 'maha zehra',
            'voteStatus': 'agreed',
          },
        ],
      };

      final entity = ProjectDetailResponseModel.fromJson(json).toEntity();

      expect(entity.showsInlineMemberCastVote, isFalse);
      expect(entity.showsInlineMemberVoteSubmittedView, isTrue);
      expect(entity.memberSubmittedVoteChoice, SuccessVoteCastChoice.agreed);
    });

    test('parses vote alias yes/no on memberVotes', () {
      expect(parseProjectMemberVoteStatus('yes'), ProjectMemberVoteStatus.agreed);
      expect(parseProjectMemberVoteStatus('no'), ProjectMemberVoteStatus.disagreed);
    });

    test('leader list falls back to non-leader members as waiting when memberVotes missing', () {
      final json = handoffLeaderPendingJson();
      (json['voting'] as Map<String, dynamic>).remove('memberVotes');

      final entity = ProjectDetailResponseModel.fromJson(json).toEntity();
      final ui = leaderSuccessVoteProgressFromProjectVoting(
        project: entity,
        voting: entity.voting!,
      );

      expect(ui.members, hasLength(1));
      expect(ui.members.first.name, 'maha zehra');
      expect(ui.members.first.status, LeaderMemberVoteStatus.waiting);
    });
  });
}
