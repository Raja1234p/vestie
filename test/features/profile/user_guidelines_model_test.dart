import 'package:flutter_test/flutter_test.dart';
import 'package:vestie/features/profile/data/models/user_guidelines_model.dart';

void main() {
  test('UserGuidelinesModel.fromJson maps pageTitle and guidelines', () {
    final model = UserGuidelinesModel.fromJson({
      'pageTitle': 'Vestie User Guidelines',
      'guidelines': [
        {
          'title': 'Your Risk',
          'description': 'Users join pots and contribute at their own risk.',
        },
        {
          'title': 'No Guarantees',
          'description':
              'Vestie does not guarantee the safety or return of any funds.',
        },
      ],
    });

    expect(model.pageTitle, 'Vestie User Guidelines');
    expect(model.guidelines, hasLength(2));
    expect(model.guidelines.first.title, 'Your Risk');
    expect(
      model.guidelines.first.description,
      'Users join pots and contribute at their own risk.',
    );
  });

  test('UserGuidelinesModel.fromJson skips empty guideline entries', () {
    final model = UserGuidelinesModel.fromJson({
      'pageTitle': 'Vestie User Guidelines',
      'guidelines': [
        {'title': '', 'description': ''},
        {'title': 'Disputes', 'description': 'Not responsible.'},
      ],
    });

    expect(model.guidelines, hasLength(1));
    expect(model.guidelines.single.title, 'Disputes');
  });
}
