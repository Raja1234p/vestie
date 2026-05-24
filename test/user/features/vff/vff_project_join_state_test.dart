import 'package:flutter_test/flutter_test.dart';
import 'package:vestie/user/features/vff/data/models/vff_json_parsing.dart';
import 'package:vestie/user/features/vff/domain/entities/vff_enums.dart';
import 'package:vestie/user/features/vff/domain/entities/vff_profile_entity.dart';
import 'package:vestie/user/features/vff/presentation/mappers/user_vff_profile_mapper.dart';
import 'package:vestie/user/features/vff/presentation/models/user_vff_profile_ui_types.dart';

void main() {
  group('VffProjectJoinState.parse', () {
    test('maps API joinState strings', () {
      expect(
        VffProjectJoinState.parse('AlreadyMember'),
        VffProjectJoinState.alreadyMember,
      );
      expect(
        VffProjectJoinState.parse('RequestToJoin'),
        VffProjectJoinState.requestToJoin,
      );
      expect(
        VffProjectJoinState.parse('RequestSent'),
        VffProjectJoinState.requestSent,
      );
      expect(VffProjectJoinState.parse('Join'), VffProjectJoinState.join);
    });

    test('is case-insensitive', () {
      expect(
        VffProjectJoinState.parse('alreadymember'),
        VffProjectJoinState.alreadyMember,
      );
      expect(
        VffProjectJoinState.parse(' request_to_join '),
        VffProjectJoinState.requestToJoin,
      );
    });
  });

  group('joined project row UI', () {
    UserVffJoinedProjectRowUi row(VffProjectJoinState joinState) {
      return UserVffProfileMapper.connected(
        VffConnectedProfileEntity(
          userId: 'u1',
          fullName: 'Peer',
          stats: const VffProfileStatsEntity(),
          joinedProjects: [
            VffJoinedProjectEntity(
              projectId: 'p1',
              name: 'Trip',
              joinState: joinState,
              memberCount: 3,
            ),
          ],
        ),
      ).joinedProjects!.single;
    }

    test('AlreadyMember → Joined chip', () {
      expect(
        row(VffProjectJoinState.alreadyMember).action,
        UserVffJoinedProjectAction.joined,
      );
    });

    test('RequestToJoin → Request to Join chip', () {
      expect(
        row(VffProjectJoinState.requestToJoin).action,
        UserVffJoinedProjectAction.requestToJoin,
      );
    });

    test('RequestSent → Request Sent chip', () {
      expect(
        row(VffProjectJoinState.requestSent).action,
        UserVffJoinedProjectAction.requestSentChip,
      );
    });

    test('Join → Join chip', () {
      expect(
        row(VffProjectJoinState.join).action,
        UserVffJoinedProjectAction.join,
      );
    });
  });

  test('mapJoinedProject reads joinState from JSON', () {
    final entity = VffJsonParsing.mapJoinedProject({
      'projectId': 'abc',
      'name': 'Paris',
      'joinState': 'AlreadyMember',
      'memberCount': 8,
    });

    expect(entity.joinState, VffProjectJoinState.alreadyMember);
    expect(entity.projectId, 'abc');
  });
}
