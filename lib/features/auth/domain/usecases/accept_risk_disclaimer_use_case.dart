import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/auth_repository.dart';

class AcceptRiskDisclaimerUseCase {
  final AuthRepository _repository;

  AcceptRiskDisclaimerUseCase(this._repository);

  Future<Either<Failure, String>> call({
    required String version,
    required String ipAddress,
  }) {
    return _repository.acceptRiskDisclaimer(
      version: version,
      ipAddress: ipAddress,
    );
  }
}
