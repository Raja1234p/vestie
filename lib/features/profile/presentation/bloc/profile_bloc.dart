import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_my_profile_usecase.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetMyProfileUseCase getMyProfileUseCase;

  ProfileBloc({required this.getMyProfileUseCase}) : super(ProfileInitial()) {
    on<LoadProfileEvent>(_onLoadProfile);
  }

  Future<void> _onLoadProfile(
    LoadProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());

    final result = await getMyProfileUseCase();

    result.fold(
      (failure) =>
          emit(ProfileError(message: failure.message, title: failure.title)),
      (profile) => emit(ProfileLoaded(profile: profile)),
    );
  }
}
