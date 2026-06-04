/// Whether API visibility represents a public group (instant join without approval).
bool isPublicProjectVisibility(String visibility) {
  final v = visibility.toLowerCase().trim();
  if (v == 'private' || v == '2') return false;
  return true;
}
