part of 'voting_window_cubit.dart';

class VotingWindowState extends Equatable {
  final String digits;
  final String? errorText;
  final bool loading;

  const VotingWindowState({
    this.digits = '',
    this.errorText,
    this.loading = false,
  });

  bool get canSubmit => digits.isNotEmpty && !loading;

  VotingWindowState copyWith({
    String? digits,
    String? errorText,
    bool? loading,
    bool clearErrorText = false,
  }) {
    return VotingWindowState(
      digits: digits ?? this.digits,
      errorText: clearErrorText ? null : (errorText ?? this.errorText),
      loading: loading ?? this.loading,
    );
  }

  @override
  List<Object?> get props => [digits, errorText, loading];
}
