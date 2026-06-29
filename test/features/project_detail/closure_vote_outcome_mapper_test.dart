import 'package:flutter_test/flutter_test.dart';

import 'package:vestie/features/project_detail/domain/entities/closure_vote_entities.dart';
import 'package:vestie/features/project_detail/domain/entities/project_detail_entity.dart';
import 'package:vestie/features/project_detail/domain/entities/viewer_membership_role.dart';
import 'package:vestie/features/project_detail/presentation/mappers/closure_vote_ui_mappers.dart';
import 'package:vestie/features/success_vote/presentation/models/success_vote_outcome_role.dart';
import 'package:vestie/features/success_vote/presentation/models/success_vote_outcome_variant.dart';
import 'package:vestie/user/features/home/domain/entities/project.dart';

ProjectDetailEntity _project({ProjectCategory category = ProjectCategory.vacations}) {
  return ProjectDetailEntity(
    id: 'p1',
    name: 'Trip',
    category: category,
    status: ProjectStatus.ongoing,
    goalAmount: 5000,
    currentAmount: 4200,
    endsIn: '2026-12-01',
    announcement: '',
    members: const [],
    borrowRequests: const [],
    viewerRole: ViewerMembershipRole.groupLeader,
  );
}

FinalizeClosureVoteResultEntity _finalizeResult({
  ClosureVoteType voteType = ClosureVoteType.successVote,
  ClosureVoteOutcome outcome = ClosureVoteOutcome.success,
}) {
  return FinalizeClosureVoteResultEntity(
    closureVoteId: 'v1',
    voteType: voteType,
    outcome: outcome,
    thumbsUp: 4,
    thumbsDown: 1,
    notYetVoted: 0,
    projectStatus: 'Completed',
  );
}

void main() {
  group('isClosureVoteOutcomeApproved', () {
    test('success and investmentStarted are approved', () {
      expect(isClosureVoteOutcomeApproved(ClosureVoteOutcome.success), isTrue);
      expect(
        isClosureVoteOutcomeApproved(ClosureVoteOutcome.investmentStarted),
        isTrue,
      );
    });

    test('refund and disputed are rejected', () {
      expect(isClosureVoteOutcomeApproved(ClosureVoteOutcome.refund), isFalse);
      expect(isClosureVoteOutcomeApproved(ClosureVoteOutcome.disputed), isFalse);
    });
  });

  group('successVoteOutcomeVariantFromClosureVote', () {
    test('stop contributions failure uses dedicated variant', () {
      expect(
        successVoteOutcomeVariantFromClosureVote(
          voteType: ClosureVoteType.stopContributionsVote,
          outcome: ClosureVoteOutcome.refund,
        ),
        SuccessVoteOutcomeVariant.stopContributionsRejected,
      );
    });

    test('success vote refund uses default variant', () {
      expect(
        successVoteOutcomeVariantFromClosureVote(
          voteType: ClosureVoteType.successVote,
          outcome: ClosureVoteOutcome.refund,
        ),
        SuccessVoteOutcomeVariant.successVote,
      );
    });
  });

  group('successVoteOutcomeRouteArgsFromFinalize', () {
    test('maps finalize tallies and role', () {
      final args = successVoteOutcomeRouteArgsFromFinalize(
        project: _project(),
        result: _finalizeResult(),
      );

      expect(args.data.isApproved, isTrue);
      expect(args.data.agreedCount, 4);
      expect(args.data.disagreedCount, 1);
      expect(args.data.amountUsd, 4200);
      expect(args.viewerRole, SuccessVoteOutcomeRole.groupLeader);
      expect(args.variant, SuccessVoteOutcomeVariant.successVote);
      expect(args.project, isNotNull);
    });

    test('investment final closure success stays on successVote variant', () {
      final args = successVoteOutcomeRouteArgsFromFinalize(
        project: _project(category: ProjectCategory.investment),
        result: _finalizeResult(
          voteType: ClosureVoteType.finalClosureVote,
          outcome: ClosureVoteOutcome.investmentStarted,
        ),
      );

      expect(args.data.isApproved, isTrue);
      expect(args.variant, SuccessVoteOutcomeVariant.successVote);
    });
  });
}
