part of 'voting_window_cubit.dart';

class VotingWindowState extends Equatable {
  final String digits;

  /// Inline validation (e.g. empty / out of range days).
  final String? errorText;

  /// API failure — surfaced via [AppToast] in the screen listener.
  final String? apiErrorMessage;
  final bool loading;

  const VotingWindowState({
    this.digits = '',
    this.errorText,
    this.apiErrorMessage,
    this.loading = false,
  });

  bool get canSubmit => digits.isNotEmpty && !loading;

  VotingWindowState copyWith({
    String? digits,
    String? errorText,
    String? apiErrorMessage,
    bool? loading,
    bool clearErrorText = false,
    bool clearApiErrorMessage = false,
  }) {
    return VotingWindowState(
      digits: digits ?? this.digits,
      errorText: clearErrorText ? null : (errorText ?? this.errorText),
      apiErrorMessage: clearApiErrorMessage
          ? null
          : (apiErrorMessage ?? this.apiErrorMessage),
      loading: loading ?? this.loading,
    );
  }

  @override
  List<Object?> get props => [digits, errorText, apiErrorMessage, loading];
}
