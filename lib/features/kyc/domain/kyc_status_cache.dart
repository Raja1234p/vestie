import 'entities/kyc_status_entity.dart';

class KycStatusCache {
  KycStatusCache._();

  static KycStatusEntity? _cached;

  static KycStatusEntity? get value => _cached;

  static void update(KycStatusEntity status) => _cached = status;

  static void clear() => _cached = null;
}
