import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vestie/app/router/route_args/borrow_repay_flow_args.dart';
import 'package:vestie/app/router/route_args/project_detail_flow_args.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/error/failure_mapper.dart';
import 'package:vestie/features/project_detail/domain/entities/borrow_request_entity.dart';
import 'package:vestie/user/features/borrow/domain/entities/borrow_repay_entities.dart';
import 'package:vestie/user/features/borrow/domain/usecases/cancel_borrow_request_use_case.dart';
import 'package:vestie/user/features/borrow/domain/usecases/get_active_repay_summary_use_case.dart';
import 'package:vestie/user/features/borrow/domain/usecases/get_borrow_repay_summary_use_case.dart';
import 'package:vestie/user/features/borrow/domain/usecases/get_my_borrow_screen_use_case.dart';
import 'package:vestie/user/features/borrow/presentation/mappers/borrow_repay_ui_mapper.dart';
import 'package:vestie/user/features/borrow/presentation/models/my_borrow_approved_ui_data.dart';
import 'package:vestie/user/features/borrow/presentation/navigation/borrow_project_detail_sync.dart';

class MyBorrowRequestState {
  final bool loading;
  final bool cancelling;
  final bool startingRepay;
  final BorrowRequestEntity? activeRequest;
  final List<MyBorrowHistoryEntry> history;
  final bool historyLoadingMore;
  final int historyCurrentPage;
  final int historyTotalCount;
  final BorrowRepaySummaryEntity? repaySummary;
  final String? errorMessage;

  const MyBorrowRequestState({
    this.loading = false,
    this.cancelling = false,
    this.startingRepay = false,
    this.activeRequest,
    this.history = const [],
    this.historyLoadingMore = false,
    this.historyCurrentPage = 0,
    this.historyTotalCount = 0,
    this.repaySummary,
    this.errorMessage,
  });

  bool get hasPending => activeRequest != null;

  bool get hasRepayableBorrow => repaySummary != null;

  bool get historyHasMore => history.length < historyTotalCount;

  bool get loadFailed =>
      errorMessage != null && !loading && !hasPending && !hasRepayableBorrow;

  MyBorrowApprovedUiData? get repayableBorrowUi {
    final summary = repaySummary;
    if (summary == null) return null;
    return BorrowRepayUiMapper.toApprovedUiData(summary);
  }

  MyBorrowRequestState copyWith({
    bool? loading,
    bool? cancelling,
    bool? startingRepay,
    BorrowRequestEntity? activeRequest,
    bool clearActiveRequest = false,
    List<MyBorrowHistoryEntry>? history,
    bool? historyLoadingMore,
    int? historyCurrentPage,
    int? historyTotalCount,
    BorrowRepaySummaryEntity? repaySummary,
    bool clearRepaySummary = false,
    String? errorMessage,
    bool clearError = false,
  }) {
    return MyBorrowRequestState(
      loading: loading ?? this.loading,
      cancelling: cancelling ?? this.cancelling,
      startingRepay: startingRepay ?? this.startingRepay,
      activeRequest: clearActiveRequest
          ? null
          : (activeRequest ?? this.activeRequest),
      history: history ?? this.history,
      historyLoadingMore: historyLoadingMore ?? this.historyLoadingMore,
      historyCurrentPage: historyCurrentPage ?? this.historyCurrentPage,
      historyTotalCount: historyTotalCount ?? this.historyTotalCount,
      repaySummary: clearRepaySummary
          ? null
          : (repaySummary ?? this.repaySummary),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class MyBorrowRequestCubit extends Cubit<MyBorrowRequestState> {
  final String projectId;
  final GetMyBorrowScreenUseCase _getMyBorrowScreenUseCase;
  final GetActiveRepaySummaryUseCase _getActiveRepaySummaryUseCase;
  final GetBorrowRepaySummaryUseCase _getBorrowRepaySummaryUseCase;
  final CancelBorrowRequestUseCase _cancelBorrowRequestUseCase;

  MyBorrowRequestCubit({
    required this.projectId,
    required GetMyBorrowScreenUseCase getMyBorrowScreenUseCase,
    required GetActiveRepaySummaryUseCase getActiveRepaySummaryUseCase,
    required GetBorrowRepaySummaryUseCase getBorrowRepaySummaryUseCase,
    required CancelBorrowRequestUseCase cancelBorrowRequestUseCase,
  }) : _getMyBorrowScreenUseCase = getMyBorrowScreenUseCase,
       _getActiveRepaySummaryUseCase = getActiveRepaySummaryUseCase,
       _getBorrowRepaySummaryUseCase = getBorrowRepaySummaryUseCase,
       _cancelBorrowRequestUseCase = cancelBorrowRequestUseCase,
       super(const MyBorrowRequestState(loading: true)) {
    load();
  }

  Future<void> load() async {
    emit(state.copyWith(loading: true, clearError: true));

    final screenResult = await _getMyBorrowScreenUseCase(projectId: projectId);
    if (isClosed) return;

    await screenResult.fold(
      (failure) async {
        emit(
          state.copyWith(
            loading: false,
            errorMessage: FailureMapper.userMessage(failure),
          ),
        );
      },
      (screen) async {
        final current = screen.activeRequest;
        final pending = current != null && current.isPending ? current : null;

        BorrowRepaySummaryEntity? repaySummary;
        if (pending == null) {
          final repayableId = resolveRepayableRequestId(
            current: current,
            history: screen.history,
          );
          repaySummary = await _loadRepaySummary(
            repayableRequestId: repayableId,
          );
        }

        if (isClosed) return;
        emit(
          MyBorrowRequestState(
            loading: false,
            activeRequest: pending,
            history: screen.history,
            historyCurrentPage: screen.historyPagination.page,
            historyTotalCount: screen.historyPagination.totalCount,
            repaySummary: repaySummary,
          ),
        );
      },
    );
  }

  /// When `currentRequest` is null, approved/disbursed rows live in `history`.
  static String? resolveRepayableRequestId({
    BorrowRequestEntity? current,
    required List<MyBorrowHistoryEntry> history,
  }) {
    if (current != null && current.isRepayableBorrow && current.id.isNotEmpty) {
      return current.id;
    }
    for (final entry in history) {
      if (entry.isRepayable && entry.id.isNotEmpty) return entry.id;
    }
    return null;
  }

  Future<BorrowRepaySummaryEntity?> _loadRepaySummary({
    String? repayableRequestId,
  }) async {
    final requestId = repayableRequestId?.trim();
    if (requestId != null && requestId.isNotEmpty) {
      final byId = await _fetchRepaySummaryIfRepayable(
        borrowRequestId: requestId,
      );
      if (byId != null) return byId;
    }

    final activeResult = await _getActiveRepaySummaryUseCase(
      projectId: projectId,
    );
    if (isClosed) return null;

    return activeResult.fold((_) => null, (value) => value);
  }

  Future<BorrowRepaySummaryEntity?> _fetchRepaySummaryIfRepayable({
    required String borrowRequestId,
  }) async {
    final byIdResult = await _getBorrowRepaySummaryUseCase(
      projectId: projectId,
      borrowRequestId: borrowRequestId,
    );
    if (isClosed) return null;

    return byIdResult.fold(
      (_) => null,
      (value) => value.canRepay ? value : null,
    );
  }

  Future<BorrowRepayPaymentOptionsRouteArgs?> prepareRepayFlow({
    required String projectName,
  }) async {
    final summary = state.repaySummary;
    if (summary == null || state.startingRepay) return null;

    emit(state.copyWith(startingRepay: true, clearError: true));

    final result = await _getBorrowRepaySummaryUseCase(
      projectId: projectId,
      borrowRequestId: summary.borrowRequestId,
    );

    if (isClosed) return null;

    return result.fold(
      (failure) {
        emit(
          state.copyWith(
            startingRepay: false,
            errorMessage: FailureMapper.userMessage(failure),
          ),
        );
        return null;
      },
      (fresh) {
        if (!fresh.canRepay) {
          emit(
            state.copyWith(
              startingRepay: false,
              errorMessage: AppStrings.borrowCannotRepayYet,
            ),
          );
          return null;
        }

        return BorrowRepayPaymentOptionsRouteArgs(
          projectId: projectId,
          projectName: projectName.isNotEmpty ? projectName : fresh.projectName,
          borrowRequestId: summary.borrowRequestId,
        );
      },
    );
  }

  void clearStartingRepay() {
    if (state.startingRepay) {
      emit(state.copyWith(startingRepay: false));
    }
  }

  Future<void> loadMoreHistory() async {
    if (state.loading || state.historyLoadingMore || !state.historyHasMore) {
      return;
    }

    emit(state.copyWith(historyLoadingMore: true, clearError: true));
    final nextPage = state.historyCurrentPage + 1;
    final result = await _getMyBorrowScreenUseCase(
      projectId: projectId,
      historyPage: nextPage,
    );
    if (isClosed) return;

    result.fold(
      (failure) => emit(
        state.copyWith(
          historyLoadingMore: false,
          errorMessage: FailureMapper.userMessage(failure),
        ),
      ),
      (screen) => emit(
        state.copyWith(
          history: [...state.history, ...screen.history],
          historyCurrentPage: screen.historyPagination.page,
          historyTotalCount: screen.historyPagination.totalCount,
          historyLoadingMore: false,
          clearError: true,
        ),
      ),
    );
  }

  Future<bool> cancelActiveRequest() async {
    final requestId = state.activeRequest?.id;
    if (requestId == null || requestId.isEmpty || state.cancelling) {
      return false;
    }

    emit(state.copyWith(cancelling: true, clearError: true));

    final result = await _cancelBorrowRequestUseCase(
      projectId: projectId,
      borrowRequestId: requestId,
    );

    if (isClosed) return false;

    return result.fold<Future<bool>>(
      (failure) async {
        emit(
          state.copyWith(
            cancelling: false,
            errorMessage: FailureMapper.userMessage(failure),
          ),
        );
        return false;
      },
      (_) async {
        await BorrowProjectDetailSync.reloadBeforeSuccess(projectId);
        if (isClosed) return false;
        emit(
          state.copyWith(
            cancelling: false,
            clearActiveRequest: true,
          ),
        );
        return true;
      },
    );
  }
}
