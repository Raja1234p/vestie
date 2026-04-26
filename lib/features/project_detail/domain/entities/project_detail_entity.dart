import '../../../home/domain/entities/project.dart';
import '../../../home/domain/entities/project_category_extensions.dart';
import 'member_entity.dart';
import 'borrow_request_entity.dart';

/// Full project detail entity extending the base Project card data.
class ProjectDetailEntity {
  final String id;
  final String name;
  final ProjectCategory category;
  final ProjectStatus status;
  final double goalAmount;
  final double currentAmount;
  final String endsIn;
  final String announcement;
  final List<MemberEntity> members;
  final List<BorrowRequestEntity> borrowRequests;
  final bool isLeader;

  const ProjectDetailEntity({
    required this.id,
    required this.name,
    required this.category,
    required this.status,
    required this.goalAmount,
    required this.currentAmount,
    required this.endsIn,
    required this.announcement,
    required this.members,
    required this.borrowRequests,
    this.isLeader = false,
  });

  double get progress =>
      goalAmount > 0 ? (currentAmount / goalAmount).clamp(0.0, 1.0) : 0.0;

  String get categoryLabel {
    return category.detailLabel;
  }
}
