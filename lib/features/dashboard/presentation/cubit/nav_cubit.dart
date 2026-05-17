import 'package:flutter_bloc/flutter_bloc.dart';

/// Tracks the active bottom-navigation tab index.
/// Cubit (not Bloc) — pure UI state with no async work.
class NavCubit extends Cubit<int> {
  NavCubit({int initialIndex = 0}) : super(initialIndex);

  void selectTab(int index) {
    if (state != index) emit(index);
  }
}
