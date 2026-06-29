import '../../../../core/constants/app_strings.dart';
import '../../../../core/error/failures.dart';

/// Maps closure-voting API failures to user-facing copy when the server omits detail.
abstract final class ClosureVotingFailureMapper {
  static Failure map(Failure failure) {
    if (failure is ForbiddenFailure) {
      return ForbiddenFailure(
        _forbiddenMessage(failure),
        failure.title ?? AppStrings.errorDialogTitle,
      );
    }
    if (failure is ValidationFailure) {
      return ValidationFailure(
        _validationMessage(failure),
        failure.title,
        failure.errors,
      );
    }
    return failure;
  }

  static String _forbiddenMessage(ForbiddenFailure failure) {
    final server = failure.message.trim().toLowerCase();
    if (server.contains('group lead') ||
        server.contains('group leader') ||
        server.contains('cannot vote')) {
      return AppStrings.errorClosureVoteGroupLeaderCannotVote;
    }
    final mapped = failure.message.trim();
    return mapped.isNotEmpty ? mapped : AppStrings.errorForbidden;
  }

  static String _validationMessage(ValidationFailure failure) {
    final server = failure.message.trim().toLowerCase();
    if (server.contains('deadline') && server.contains('pass')) {
      return AppStrings.errorClosureVoteDeadlinePassed;
    }
    if (server.contains('no open vote') || server.contains('no active vote')) {
      return AppStrings.errorClosureVoteNoOpenVote;
    }
    final fieldErrors = failure.errors;
    if (fieldErrors != null && fieldErrors.isNotEmpty) {
      return fieldErrors.values.expand((list) => list).join('\n');
    }
    final mapped = failure.message.trim();
    return mapped.isNotEmpty ? mapped : AppStrings.errorGeneric;
  }
}
