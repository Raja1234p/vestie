import 'package:equatable/equatable.dart';

/// Core user entity — pure domain, no JSON/API dependency.
class User extends Equatable {
  final String id;
  final String name;
  final String email;
  final bool isVerified;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.isVerified = false,
  });

  @override
  List<Object?> get props => [id, name, email, isVerified];
}
