import 'package:flutter_test/flutter_test.dart';

import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/features/success_vote/presentation/models/success_vote_outcome_load_route_args.dart';
import 'package:vestie/features/success_vote/presentation/models/success_vote_outcome_role.dart';
import 'package:vestie/features/success_vote/presentation/models/success_vote_outcome_route_args.dart';
import 'package:vestie/features/success_vote/presentation/models/success_vote_outcome_ui_data.dart';

void main() {
  group('Completed profile outcome CTA routing flags', () {
    const data = SuccessVoteOutcomeUiData(
      isApproved: true,
      amountUsd: 9800,
      agreedCount: 5,
      disagreedCount: 2,
      totalMemberCount: 7,
    );

    test('profile load args enable View Details flow', () {
      const loadArgs = SuccessVoteOutcomeLoadRouteArgs(
        projectId: 'p1',
        initialProjectName: 'Trip',
        fromCompletedProjectsList: true,
      );

      expect(loadArgs.fromCompletedProjectsList, isTrue);
    });

    test('home completed load args keep default dashboard CTA', () {
      const loadArgs = SuccessVoteOutcomeLoadRouteArgs(
        projectId: 'p1',
        initialProjectName: 'Trip',
      );

      expect(loadArgs.fromCompletedProjectsList, isFalse);
    });

    test('outcome args copyWith preserves completed profile navigation', () {
      final args = const SuccessVoteOutcomeRouteArgs(
        data: data,
        viewerRole: SuccessVoteOutcomeRole.member,
      ).copyWith(
        fromCompletedProjectsList: true,
        projectId: 'p1',
        initialProjectName: 'Trip',
      );

      expect(args.fromCompletedProjectsList, isTrue);
      expect(args.projectId, 'p1');
      expect(AppStrings.btnViewDetails, isNotEmpty);
    });
  });
}
