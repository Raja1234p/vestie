import 'package:flutter_bloc/flutter_bloc.dart';

/// Tracks the active bottom-navigation tab index.
/// Cubit (not Bloc) — pure UI state with no async work.
class NavCubit extends Cubit<int> {
  NavCubit() : super(0);

  void selectTab(int index) {
    if (state != index) emit(index);
  }
}
