import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';

class ModerationState extends Equatable {
  final bool isLoading;
  final Failure? failure;
  final bool isSuccess;

  const ModerationState({
    this.isLoading = false,
    this.failure,
    this.isSuccess = false,
  });

  ModerationState copyWith({
    bool? isLoading,
    Failure? failure,
    bool? isSuccess,
    bool clearFailure = false,
  }) {
    return ModerationState(
      isLoading: isLoading ?? this.isLoading,
      failure: clearFailure ? null : (failure ?? this.failure),
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }

  @override
  List<Object?> get props => [isLoading, failure, isSuccess];
}
