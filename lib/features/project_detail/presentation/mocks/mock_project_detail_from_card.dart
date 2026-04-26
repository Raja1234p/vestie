import '../../../../core/constants/app_strings.dart';
import '../../../home/domain/entities/project.dart';
import '../../domain/entities/borrow_request_entity.dart';
import '../../domain/entities/member_entity.dart';
import '../../domain/entities/project_detail_entity.dart';

/// Builds [ProjectDetailEntity] for mock navigation (home / discover) until
/// a repository provides real detail payloads.
ProjectDetailEntity mockProjectDetailFromCard(
  Project p, {
  required bool isLeaderView,
}) {
  return ProjectDetailEntity(
    id: p.id,
    name: p.name,
    category: p.category,
    status: p.status,
    goalAmount: p.goalAmount ?? 5000,
    currentAmount: p.currentAmount ?? 2700,
    endsIn: p.endsIn ?? '2 months',
    announcement: AppStrings.announcementPlaceholder,
    members: const [
      MemberEntity(
        id: '1',
        initials: 'EL',
        name: 'Emma L.',
        role: MemberRole.leader,
        contributedAmount: 45,
      ),
      MemberEntity(
        id: '2',
        initials: 'OR',
        name: 'Olivia R.',
        role: MemberRole.coLeader,
        contributedAmount: 65,
      ),
      MemberEntity(
        id: '3',
        initials: 'LN',
        name: 'Lien N.',
        role: MemberRole.member,
        contributedAmount: 19,
      ),
      MemberEntity(
        id: '4',
        initials: 'SH',
        name: 'Sarah M.',
        role: MemberRole.member,
        contributedAmount: -24,
        overdueAmount: 200,
      ),
    ],
    borrowRequests: const [
      BorrowRequestEntity(
        id: 'b1',
        initials: 'OR',
        memberName: 'Olivia R.',
        loanType: AppStrings.educationLoan,
        requestedAmount: 2500,
        upvotes: 78,
        downvotes: 6,
      ),
      BorrowRequestEntity(
        id: 'b2',
        initials: 'OR',
        memberName: 'Olivia R.',
        loanType: AppStrings.educationLoan,
        requestedAmount: 2500,
        upvotes: 78,
        downvotes: 6,
      ),
      BorrowRequestEntity(
        id: 'b3',
        initials: 'OR',
        memberName: 'Olivia R.',
        loanType: AppStrings.educationLoan,
        requestedAmount: 2500,
        upvotes: 78,
        downvotes: 6,
      ),
    ],
    isLeader: isLeaderView,
  );
}
