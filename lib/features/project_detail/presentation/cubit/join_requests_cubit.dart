import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/member_entity.dart';
import '../../domain/entities/pending_join_request_entity.dart';
import '../../domain/repositories/project_detail_repository.dart';
import '../../domain/usecases/list_pending_join_requests_usecase.dart';

// ── States ────────────────────────────────────────────────────────────────────

abstract class JoinRequestsState extends Equatable {
  const JoinRequestsState();

  @override
  List<Object?> get props => [];
}

class JoinRequestsInitial extends JoinRequestsState {}

class JoinRequestsLoading extends JoinRequestsState {}

class JoinRequestsLoaded extends JoinRequestsState {
  final List<PendingJoinRequestEntity> requests;

  const JoinRequestsLoaded({required this.requests});

  @override
  List<Object?> get props => [requests];
}

class JoinRequestsError extends JoinRequestsState {
  final String message;

  const JoinRequestsError({required this.message});

  @override
  List<Object?> get props => [message];
}

// ── Cubit ─────────────────────────────────────────────────────────────────────

class JoinRequestsCubit extends Cubit<JoinRequestsState> {
  final ListPendingJoinRequestsUseCase _listPending;
  final ProjectDetailRepository _detailRepository;

  JoinRequestsCubit({
    required ListPendingJoinRequestsUseCase listPending,
    required ProjectDetailRepository detailRepository,
  })  : _listPending = listPending,
        _detailRepository = detailRepository,
        super(JoinRequestsInitial());

  Future<void> load(String projectId) async {
    emit(JoinRequestsLoading());

    final detailMembers = await _detailRepository.getProjectDetail(
      projectId: projectId,
    );
    final membersForMerge = detailMembers.fold(
      (_) => <MemberEntity>[],
      (project) => project.members,
    );

    final result = await _listPending(projectId);
    result.fold(
      (failure) => emit(JoinRequestsError(message: _messageFor(failure))),
      (pending) {
        final enriched = pending
            .map((p) => _enrich(p, membersForMerge))
            .toList(growable: false);
        emit(JoinRequestsLoaded(requests: enriched));
      },
    );
  }

  static PendingJoinRequestEntity _enrich(
    PendingJoinRequestEntity pending,
    List<MemberEntity> members,
  ) {
    for (final m in members) {
      final matchByMembership = pending.membershipId.isNotEmpty &&
          m.membershipId == pending.membershipId;
      final matchByUser =
          pending.userId.isNotEmpty && m.userId == pending.userId;
      if (matchByMembership || matchByUser) {
        return PendingJoinRequestEntity(
          membershipId: pending.membershipId.isNotEmpty
              ? pending.membershipId
              : m.membershipId,
          userId: pending.userId.isNotEmpty ? pending.userId : m.userId,
          status: pending.status,
          displayName: m.name,
          username: m.username,
          initials: m.initials,
          photoUrl: m.photoUrl ?? pending.photoUrl,
        );
      }
    }
    return pending;
  }

  static String _messageFor(Failure failure) {
    if (failure is NetworkFailure) return AppStrings.errorNetwork;
    if (failure is ForbiddenFailure) return AppStrings.errorForbidden;
    if (failure.message.toLowerCase().contains('not found')) {
      return AppStrings.projectNotFound;
    }
    return failure.message;
  }
}
