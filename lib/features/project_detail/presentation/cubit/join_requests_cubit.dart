import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/domain/entities/paginated_result.dart';
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
  final bool loadingMore;
  final int currentPage;
  final int totalCount;

  const JoinRequestsLoaded({
    required this.requests,
    this.loadingMore = false,
    this.currentPage = 0,
    this.totalCount = 0,
  });

  bool get hasMore => requests.length < totalCount;

  JoinRequestsLoaded copyWith({
    List<PendingJoinRequestEntity>? requests,
    bool? loadingMore,
    int? currentPage,
    int? totalCount,
  }) {
    return JoinRequestsLoaded(
      requests: requests ?? this.requests,
      loadingMore: loadingMore ?? this.loadingMore,
      currentPage: currentPage ?? this.currentPage,
      totalCount: totalCount ?? this.totalCount,
    );
  }

  @override
  List<Object?> get props => [requests, loadingMore, currentPage, totalCount];
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

  String? _projectId;
  List<MemberEntity> _membersForMerge = const [];

  JoinRequestsCubit({
    required ListPendingJoinRequestsUseCase listPending,
    required ProjectDetailRepository detailRepository,
  }) : _listPending = listPending,
       _detailRepository = detailRepository,
       super(JoinRequestsInitial());

  Future<void> load(String projectId) async {
    _projectId = projectId;
    emit(JoinRequestsLoading());

    final detailMembers = await _detailRepository.getProjectDetail(
      projectId: projectId,
    );
    _membersForMerge = detailMembers.fold(
      (_) => <MemberEntity>[],
      (project) => project.members,
    );

    final result = await _listPending(projectId, page: 1);
    result.fold(
      (failure) => emit(JoinRequestsError(message: _messageFor(failure))),
      (page) => emit(_loadedFromPage(page, replace: true)),
    );
  }

  Future<void> loadMore() async {
    final projectId = _projectId;
    if (projectId == null) return;
    final curr = state;
    if (curr is! JoinRequestsLoaded) return;
    if (curr.loadingMore || !curr.hasMore) return;

    emit(curr.copyWith(loadingMore: true));
    final nextPage = curr.currentPage + 1;
    final result = await _listPending(projectId, page: nextPage);
    result.fold(
      (failure) {
        if (state is JoinRequestsLoaded) {
          emit((state as JoinRequestsLoaded).copyWith(loadingMore: false));
        }
      },
      (page) {
        final currLoaded = state;
        if (currLoaded is! JoinRequestsLoaded) return;
        final enriched = page.items
            .map((p) => _enrich(p, _membersForMerge))
            .toList(growable: false);
        emit(
          JoinRequestsLoaded(
            requests: [...currLoaded.requests, ...enriched],
            currentPage: page.page,
            totalCount: page.totalCount,
          ),
        );
      },
    );
  }

  JoinRequestsLoaded _loadedFromPage(
    PaginatedResult<PendingJoinRequestEntity> page, {
    required bool replace,
  }) {
    final enriched = page.items
        .map((p) => _enrich(p, _membersForMerge))
        .toList(growable: false);
    final curr = state;
    final previous = curr is JoinRequestsLoaded ? curr.requests : const <PendingJoinRequestEntity>[];
    return JoinRequestsLoaded(
      requests: replace || curr is! JoinRequestsLoaded
          ? enriched
          : [...previous, ...enriched],
      currentPage: page.page,
      totalCount: page.totalCount,
    );
  }

  static PendingJoinRequestEntity _enrich(
    PendingJoinRequestEntity pending,
    List<MemberEntity> members,
  ) {
    for (final m in members) {
      final matchByMembership =
          pending.membershipId.isNotEmpty &&
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
