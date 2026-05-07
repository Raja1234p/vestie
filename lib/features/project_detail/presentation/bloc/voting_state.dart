import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';

class VotingState extends Equatable {
  final bool isLoading;
  final Failure? failure;
  final bool isSuccess;

  const VotingState({
    this.isLoading = false,
    this.failure,
    this.isSuccess = false,
  });

  VotingState copyWith({
    bool? isLoading,
    Failure? failure,
    bool? isSuccess,
    bool clearFailure = false,
  }) {
    return VotingState(
      isLoading: isLoading ?? this.isLoading,
      failure: clearFailure ? null : (failure ?? this.failure),
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }

  @override
  List<Object?> get props => [isLoading, failure, isSuccess];
}
