class UserProfile {
  final String firstName;
  final String lastName;
  final String username;
  final String email;
  final String? photoUrl;

  const UserProfile({
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.email,
    this.photoUrl,
  });

  String get fullName => '$firstName $lastName'.trim();

  UserProfile copyWith({
    String? firstName,
    String? lastName,
    String? username,
    String? email,
    String? photoUrl,
  }) {
    return UserProfile(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      username: username ?? this.username,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }
}
