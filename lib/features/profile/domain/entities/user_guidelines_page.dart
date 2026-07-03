import 'package:equatable/equatable.dart';

import 'user_guideline.dart';

/// `GET /content/user-guidelines` response.
class UserGuidelinesPage extends Equatable {
  const UserGuidelinesPage({
    required this.pageTitle,
    required this.guidelines,
  });

  final String pageTitle;
  final List<UserGuideline> guidelines;

  @override
  List<Object?> get props => [pageTitle, guidelines];
}
