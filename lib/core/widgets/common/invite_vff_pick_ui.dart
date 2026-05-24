/// Row in the invite-members VFF picker grid.
class InviteVffPickUi {
  final String id;
  final String name;
  final String initials;
  final String? photoUrl;

  const InviteVffPickUi({
    required this.id,
    required this.name,
    required this.initials,
    this.photoUrl,
  });

  /// Display name (first token) for compact grid labels.
  String get displayName {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return name;
    return trimmed.split(RegExp(r'\s+')).first;
  }
}
