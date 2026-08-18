import '../../../../core/constants/app_strings.dart';
import '../../../../core/error/failures.dart';
import '../models/closure_voting_response_model.dart';

/// Maps closure-voting API failures to user-facing copy when the server omits detail.
///
/// [map] is used for **open / cast / getActive** and must stay independent of
/// Continue-contribution copy. [mapCancel] is **cancel only**.
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
    if (failure is ServerFailure) {
      return ServerFailure(_serverMessage(failure), failure.title);
    }
    return failure;
  }

  /// Cancel / Continue contribution only — never used by open or cast.
  static Failure mapCancel(Failure failure) {
    final blob = _blob(failure);

    if (_isCode(blob, ClosureVoteApiValues.cancelCodeParticipationThreshold) ||
        _isContinueContributionThreshold(blob)) {
      return ServerFailure(
        AppStrings.errorContinueContributionThreshold,
        failure.title,
      );
    }
    if (_isCode(blob, ClosureVoteApiValues.cancelCodeWindowClosed) ||
        (blob.contains('voting window') && blob.contains('closed'))) {
      return ServerFailure(
        AppStrings.errorContinueContributionWindowClosed,
        failure.title,
      );
    }
    if (_isCode(blob, ClosureVoteApiValues.cancelCodeAlreadyFinalized) ||
        (blob.contains('already') && blob.contains('finalized'))) {
      return ServerFailure(
        AppStrings.errorContinueContributionAlreadyFinalized,
        failure.title,
      );
    }
    if (_isCode(blob, ClosureVoteApiValues.cancelCodeNoOpenVote) ||
        blob.contains('no open vote')) {
      return ServerFailure(
        AppStrings.errorClosureVoteNoOpenVote,
        failure.title,
      );
    }
    if (failure is ForbiddenFailure ||
        _isCode(blob, ClosureVoteApiValues.cancelCodeForbidden)) {
      return ForbiddenFailure(
        AppStrings.errorForbidden,
        failure.title ?? AppStrings.errorDialogTitle,
      );
    }
    return map(failure);
  }

  static String _blob(Failure failure) {
    return '${failure.title ?? ''} ${failure.message}'.trim().toLowerCase();
  }

  static bool _isCode(String blob, String code) {
    return blob.contains(code.trim().toLowerCase());
  }

  static bool _isContinueContributionThreshold(String blob) {
    return blob.contains('50%') &&
        (blob.contains('joined') || blob.contains('continue contribution'));
  }

  static String _serverMessage(ServerFailure failure) {
    return failure.message.trim().isNotEmpty
        ? failure.message
        : AppStrings.errorGeneric;
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
