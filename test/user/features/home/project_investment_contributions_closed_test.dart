import 'package:flutter_test/flutter_test.dart';
import 'package:vestie/user/features/home/domain/entities/project.dart';

Project _investment({String? displayStatus}) => Project(
  id: 'p1',
  name: 'Growth Fund',
  category: ProjectCategory.investment,
  status: ProjectStatus.ongoing,
  relation: ProjectRelation.joined,
  goalAmount: 7000,
  currentAmount: 5000,
  displayStatus: displayStatus,
);

void main() {
  group('Project.investmentContributionsAreClosed', () {
    test('false while contributions are open', () {
      expect(
        _investment(displayStatus: 'On Going').investmentContributionsAreClosed,
        isFalse,
      );
    });

    test('true when displayStatus is Funded', () {
      expect(
        _investment(displayStatus: 'Funded').investmentContributionsAreClosed,
        isTrue,
      );
    });

    test('false for vacation even when funded label appears', () {
      final vacation = Project(
        id: 'v1',
        name: 'Trip',
        category: ProjectCategory.vacations,
        status: ProjectStatus.ongoing,
        relation: ProjectRelation.owned,
        displayStatus: 'Funded',
      );
      expect(vacation.investmentContributionsAreClosed, isFalse);
    });
  });
}
