import 'package:flutter_bloc/flutter_bloc.dart';
import 'register_event.dart';
import 'register_state.dart';

/// Handles registration API flow.
/// Receives only pre-validated data from the UI layer.
/// TODO: Inject AuthRepository when data layer is ready.
class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  RegisterBloc() : super(const RegisterInitial()) {
    on<RegisterSubmitted>(_onRegisterSubmitted);
    on<RegisterReset>((_, emit) => emit(const RegisterInitial()));
  }

  Future<void> _onRegisterSubmitted(
    RegisterSubmitted event,
    Emitter<RegisterState> emit,
  ) async {
    emit(const RegisterLoading());
    await Future.delayed(const Duration(milliseconds: 1200));
    // TODO: Replace with AuthRepository.register(name, email, password)
    emit(RegisterSuccess(email: event.email));
  }
}
