import 'package:flutter_test/flutter_test.dart';
import 'package:vestie/user/features/borrow/data/models/borrow_request_list_item_model.dart';

void main() {
  group('BorrowRequestListItemModel', () {
    test('fromJson maps list item fields', () {
      final model = BorrowRequestListItemModel.fromJson({
        'id': 'req-1',
        'memberId': 'member-1',
        'memberName': 'Olivia R.',
        'memberUsername': 'olivia',
        'memberPhotoUrl': 'https://example.com/photo.jpg',
        'reason': 'Education Loan',
        'requestedAmount': 2500,
        'upvoteCount': 78,
        'downvoteCount': 6,
        'callerVote': 'Agree',
        'status': 'Pending',
        'callerCanDecide': false,
        'requesterRole': 'Member',
        'requiredDecisionBy': 'GroupLeader',
      });

      expect(model.id, 'req-1');
      expect(model.memberId, 'member-1');
      expect(model.reason, 'Education Loan');
      expect(model.upvoteCount, 78);
      expect(model.callerVote, 'Agree');
      expect(model.callerCanDecide, isFalse);

      final entity = model.toEntity();
      expect(entity.id, 'req-1');
      expect(entity.memberId, 'member-1');
      expect(entity.initials, 'OR');
      expect(entity.loanType, 'Education Loan');
      expect(entity.upvotes, 78);
      expect(entity.hasAgreed, isTrue);
      expect(entity.isPending, isTrue);
    });

    test('list response parses borrowRequests array with pagination', () {
      final response = BorrowRequestListResponseModel.fromJson({
        'borrowRequests': [
          {
            'id': 'req-1',
            'memberId': 'm1',
            'memberName': 'Jane Doe',
            'memberUsername': 'jane',
            'reason': 'Travel',
            'requestedAmount': 100,
            'upvoteCount': 1,
            'downvoteCount': 0,
            'status': 'Pending',
            'callerCanDecide': true,
          },
        ],
        'pagination': {
          'page': 1,
          'pageSize': 20,
          'totalCount': 1,
          'totalPages': 1,
        },
      });

      expect(response.totalCount, 1);
      expect(response.pagination.totalPages, 1);
      expect(response.borrowRequests, hasLength(1));
      expect(response.borrowRequests.first.memberName, 'Jane Doe');
    });
  });
}
