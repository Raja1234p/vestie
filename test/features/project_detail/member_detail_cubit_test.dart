import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vestie/core/error/failures.dart';
import 'package:vestie/core/domain/entities/pagination_info.dart';
import 'package:vestie/features/project_detail/domain/entities/member_activity_entity.dart';
import 'package:vestie/features/project_detail/domain/entities/member_entity.dart';
import 'package:vestie/features/project_detail/domain/usecases/get_member_activity_usecase.dart';
import 'package:vestie/features/project_detail/domain/usecases/project_actions_usecases.dart';
import 'package:vestie/features/project_detail/presentation/cubit/member_detail_cubit.dart';
import 'package:vestie/user/features/vff/domain/entities/vff_inbox_entity.dart';
import 'package:vestie/user/features/vff/domain/usecases/vff_usecases.dart';

class _MockGetMemberActivityUseCase extends Mock
    implements GetMemberActivityUseCase {}

class _MockUpdateCoLeaderRoleUseCase extends Mock
    implements UpdateCoLeaderRoleUseCase {}

class _MockRemoveMemberUseCase extends Mock implements RemoveMemberUseCase {}

class _MockSendVffRequestUseCase extends Mock implements SendVffRequestUseCase {}

class _MockRemoveVffConnectionUseCase extends Mock
    implements RemoveVffConnectionUseCase {}

void main() {
  late _MockGetMemberActivityUseCase getActivity;
  late _MockUpdateCoLeaderRoleUseCase updateCoLeader;
  late _MockRemoveMemberUseCase removeMember;
  late _MockSendVffRequestUseCase sendVff;
  late _MockRemoveVffConnectionUseCase removeVff;

  const member = MemberEntity(
    id: 'user-1',
    userId: 'user-1',
    membershipId: 'mem-1',
    initials: 'AB',
    name: 'Alex',
    role: MemberRole.member,
    contributedAmount: 0,
  );

  const emptyPagination = PaginationInfo(
    page: 1,
    pageSize: 20,
    totalCount: 0,
    totalPages: 0,
  );

  const activity = MemberActivityEntity(
    member: member,
    totalContributed: 100,
    contributionCount: 2,
    totalBorrowed: 0,
    transactions: [],
    transactionsPagination: emptyPagination,
  );

  setUp(() {
    getActivity = _MockGetMemberActivityUseCase();
    updateCoLeader = _MockUpdateCoLeaderRoleUseCase();
    removeMember = _MockRemoveMemberUseCase();
    sendVff = _MockSendVffRequestUseCase();
    removeVff = _MockRemoveVffConnectionUseCase();
  });

  MemberDetailCubit createCubit() => MemberDetailCubit(
    getMemberActivityUseCase: getActivity,
    updateCoLeaderRoleUseCase: updateCoLeader,
    removeMemberUseCase: removeMember,
    sendVffRequestUseCase: sendVff,
    removeVffConnectionUseCase: removeVff,
  );

  group('MemberDetailCubit dialog actions', () {
    test('assignCoLeader returns true and syncs without footer loading', () async {
      when(
        () => updateCoLeader(
          projectId: any(named: 'projectId'),
          userId: any(named: 'userId'),
          assign: true,
        ),
      ).thenAnswer((_) async => const Right(null));

      final cubit = createCubit();
      addTearDown(cubit.close);

      final ok = await cubit.assignCoLeader(
        projectId: 'proj-1',
        userId: 'user-1',
      );

      expect(ok, isTrue);
      expect(cubit.state.isActionLoading, isFalse);
      expect(cubit.state.projectMembersChanged, isTrue);
      expect(cubit.state.completedAction, isNull);
    });

    test('assignCoLeader returns false and emits failure on API error', () async {
      when(
        () => updateCoLeader(
          projectId: any(named: 'projectId'),
          userId: any(named: 'userId'),
          assign: any(named: 'assign'),
        ),
      ).thenAnswer((_) async => const Left(ServerFailure('Failed')));

      final cubit = createCubit();
      addTearDown(cubit.close);

      final ok = await cubit.assignCoLeader(
        projectId: 'proj-1',
        userId: 'user-1',
      );

      expect(ok, isFalse);
      expect(cubit.state.isActionLoading, isFalse);
      expect(cubit.state.failure, isA<ServerFailure>());
    });

    test('removeMember returns true without completedAction', () async {
      when(
        () => removeMember(
          projectId: any(named: 'projectId'),
          userId: any(named: 'userId'),
        ),
      ).thenAnswer((_) async => const Right(null));

      final cubit = createCubit();
      addTearDown(cubit.close);

      final ok = await cubit.removeMember(
        projectId: 'proj-1',
        userId: 'user-1',
      );

      expect(ok, isTrue);
      expect(cubit.state.isActionLoading, isFalse);
      expect(cubit.state.projectMembersChanged, isTrue);
      expect(cubit.state.completedAction, isNull);
    });

    test('removeCoLeader returns false on API error', () async {
      when(
        () => updateCoLeader(
          projectId: any(named: 'projectId'),
          userId: any(named: 'userId'),
          assign: false,
        ),
      ).thenAnswer((_) async => const Left(NetworkFailure()));

      final cubit = createCubit();
      addTearDown(cubit.close);

      final ok = await cubit.removeCoLeader(
        projectId: 'proj-1',
        userId: 'user-1',
      );

      expect(ok, isFalse);
      expect(cubit.state.failure, isA<NetworkFailure>());
    });

    test('removeVffConnection returns true after load', () async {
      when(
        () => getActivity(
          projectId: any(named: 'projectId'),
          userId: any(named: 'userId'),
          projectName: any(named: 'projectName'),
        ),
      ).thenAnswer((_) async => const Right(activity));
      when(() => removeVff(any())).thenAnswer(
        (_) async => const Right(
          VffRemoveConnectionResultEntity(success: true, message: 'Removed'),
        ),
      );

      final cubit = createCubit();
      addTearDown(cubit.close);
      await cubit.load(
        projectId: 'proj-1',
        userId: 'user-1',
        projectName: 'Trip',
      );

      final ok = await cubit.removeVffConnection();

      expect(ok, isTrue);
      expect(cubit.state.isRemoveVffLoading, isFalse);
      expect(cubit.state.projectMembersChanged, isTrue);
    });
  });
}
