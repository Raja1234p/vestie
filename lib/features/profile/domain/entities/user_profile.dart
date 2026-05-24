class UserProfile {
  final String fullName;
  final String username;
  final String email;
  final String? photoUrl;

  const UserProfile({
    required this.fullName,
    required this.username,
    required this.email,
    this.photoUrl,
  });

  UserProfile copyWith({
    String? fullName,
    String? username,
    String? email,
    String? photoUrl,
  }) {
    return UserProfile(
      fullName: fullName ?? this.fullName,
      username: username ?? this.username,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }
}
