/// OTP verify screen: after register vs after forgot-password email.
enum VerifyFlow {
  registration,
  forgotPassword,
}

/// Passed to [AppRoutes.verify] (preferred over a raw email [String]).
class VerifyScreenExtra {
  const VerifyScreenExtra({
    required this.email,
    this.flow = VerifyFlow.registration,
  });

  final String email;
  final VerifyFlow flow;
}

/// Email + OTP from verify step → set-new-password screen (no OTP field on form).
class ResetPasswordExtra {
  const ResetPasswordExtra({
    required this.email,
    required this.code,
  });

  final String email;
  final String code;
}
