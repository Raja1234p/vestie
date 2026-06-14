import '../cubit/my_borrow_request_cubit.dart';

/// Which My Borrow screen layout is shown (or loading toward).
enum MyBorrowContentKind {
  loading,
  approved,
  pending,
  historyOnly,
  empty,
}

MyBorrowContentKind resolveMyBorrowContentKind(MyBorrowRequestState state) {
  if (state.loading) return MyBorrowContentKind.loading;
  if (state.hasRepayableBorrow) return MyBorrowContentKind.approved;
  if (state.hasPending) return MyBorrowContentKind.pending;
  if (state.history.isNotEmpty) return MyBorrowContentKind.historyOnly;
  return MyBorrowContentKind.empty;
}
