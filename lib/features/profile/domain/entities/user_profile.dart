class UserProfile {
  final String fullName;
  final String username;
  final String email;
  final String? avatarPath; // local file path after image pick

  const UserProfile({
    required this.fullName,
    required this.username,
    required this.email,
    this.avatarPath,
  });

  UserProfile copyWith({
    String? fullName,
    String? username,
    String? email,
    String? avatarPath,
  }) {
    return UserProfile(
      fullName: fullName ?? this.fullName,
      username: username ?? this.username,
      email: email ?? this.email,
      avatarPath: avatarPath ?? this.avatarPath,
    );
  }
}
