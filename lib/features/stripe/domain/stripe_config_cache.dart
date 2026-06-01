import 'entities/stripe_config_entity.dart';

class StripeConfigCache {
  StripeConfigCache._();

  static StripeConfigEntity? _cached;

  static StripeConfigEntity? get value => _cached;

  static void update(StripeConfigEntity config) => _cached = config;

  static void clear() => _cached = null;
}
