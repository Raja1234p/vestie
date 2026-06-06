import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

abstract class PaginationEvent extends Equatable {
  const PaginationEvent();
  @override
  List<Object?> get props => [];
}

class RefreshListEvent extends PaginationEvent {}

class LoadMoreListEvent extends PaginationEvent {}

class PaginationState<T> extends Equatable {
  final List<T> items;
  final bool isLoading;
  final bool isFetchingMore;
  final bool hasReachedMax;
  final String? errorMessage;

  const PaginationState({
    this.items = const [],
    this.isLoading = false,
    this.isFetchingMore = false,
    this.hasReachedMax = false,
    this.errorMessage,
  });

  PaginationState<T> copyWith({
    List<T>? items,
    bool? isLoading,
    bool? isFetchingMore,
    bool? hasReachedMax,
    String? errorMessage,
    bool clearError = false,
  }) {
    return PaginationState<T>(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      isFetchingMore: isFetchingMore ?? this.isFetchingMore,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
    items,
    isLoading,
    isFetchingMore,
    hasReachedMax,
    errorMessage,
  ];
}

abstract class BasePaginationBloc<T>
    extends Bloc<PaginationEvent, PaginationState<T>> {
  int _currentPage = 1;

  BasePaginationBloc() : super(PaginationState<T>()) {
    on<RefreshListEvent>(_onRefresh);
    on<LoadMoreListEvent>(_onLoadMore);
  }

  Future<void> _onRefresh(
    RefreshListEvent event,
    Emitter<PaginationState<T>> emit,
  ) async {
    _currentPage = 1;
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final result = await fetchItems(page: _currentPage);
      emit(
        state.copyWith(
          isLoading: false,
          items: result,
          hasReachedMax: result
              .isEmpty, // Simplified, override if backend provides totalPages
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  Future<void> _onLoadMore(
    LoadMoreListEvent event,
    Emitter<PaginationState<T>> emit,
  ) async {
    if (state.hasReachedMax || state.isFetchingMore || state.isLoading) return;

    _currentPage++;
    emit(state.copyWith(isFetchingMore: true, clearError: true));
    try {
      final result = await fetchItems(page: _currentPage);
      if (result.isEmpty) {
        emit(state.copyWith(isFetchingMore: false, hasReachedMax: true));
      } else {
        emit(
          state.copyWith(
            isFetchingMore: false,
            items: List.of(state.items)..addAll(result),
          ),
        );
      }
    } catch (e) {
      _currentPage--;
      emit(state.copyWith(isFetchingMore: false, errorMessage: e.toString()));
    }
  }

  // To be implemented by subclasses
  Future<List<T>> fetchItems({required int page});
}
