import 'package:flutter_bloc/flutter_bloc.dart';

/// Manages checkbox acceptance state on the Agreement screen.
class AgreementCubit extends Cubit<bool> {
  AgreementCubit() : super(false);

  void toggle() => emit(!state);
}
