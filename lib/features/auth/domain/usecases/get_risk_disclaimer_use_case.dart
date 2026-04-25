import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/risk_disclaimer.dart';
import '../repositories/auth_repository.dart';

class GetRiskDisclaimerUseCase {
  final AuthRepository _repository;

  GetRiskDisclaimerUseCase(this._repository);

  Future<Either<Failure, RiskDisclaimer>> call() {
    return _repository.getRiskDisclaimer();
  }
}
