import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/user.dart';
import 'login_event.dart';
import 'login_state.dart';

/// Handles login API flow.
/// Receives only pre-validated data from the UI layer.
/// TODO: Inject AuthRepository when data layer is ready.
class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc() : super(const LoginInitial()) {
    on<LoginSubmitted>(_onLoginSubmitted);
    on<LoginReset>((_, emit) => emit(const LoginInitial()));
  }

  Future<void> _onLoginSubmitted(
    LoginSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    emit(const LoginLoading());
    await Future.delayed(const Duration(milliseconds: 1200));
    // TODO: Replace with AuthRepository.login(email, password)
    const user = User(id: '1', name: 'Vestie User', email: 'user@vestie.app');
    emit(const LoginSuccess(user: user));
  }
}
