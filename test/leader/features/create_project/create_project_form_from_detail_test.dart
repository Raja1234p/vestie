import 'package:flutter_test/flutter_test.dart';
import 'package:vestie/features/project_detail/domain/entities/project_detail_entity.dart';
import 'package:vestie/leader/features/create_project/domain/create_project_form.dart';
import 'package:vestie/leader/features/create_project/domain/create_project_form_from_detail.dart';
import 'package:vestie/user/features/home/domain/entities/project.dart';

void main() {
  test('maps vacation project detail into edit form', () {
    const project = ProjectDetailEntity(
      id: 'p1',
      name: 'Summer Trip',
      category: ProjectCategory.vacations,
      status: ProjectStatus.ongoing,
      goalAmount: 5000,
      currentAmount: 1200,
      endsIn: '2026-08-15T23:59:59.999Z',
      announcement: 'Beach fund',
      members: [],
      borrowRequests: [],
      borrowingEnabled: true,
      repaymentWindowDays: 14,
      penaltyPercentage: 10,
      joinApprovalRequired: false,
    );

    final form = CreateProjectFormFromDetail.map(project);

    expect(form.editingProjectId, 'p1');
    expect(form.amountDigits, '5000');
    expect(form.projectName, 'Summer Trip');
    expect(form.description, 'Beach fund');
    expect(form.category, NewProjectCategory.vacation);
    expect(form.flowType, ProjectCreationFlowType.fundsBorrowing);
    expect(form.visibility, ProjectVisibility.public);
    expect(form.borrowingEnabled, isTrue);
    expect(form.repaymentWindow, '14');
    expect(form.penalty, '10');
    expect(form.deadline?.year, 2026);
    expect(form.deadline?.month, 8);
    expect(form.deadline?.day, 15);
  });

  test('maps investment project with private visibility', () {
    const project = ProjectDetailEntity(
      id: 'inv1',
      name: 'Growth Pool',
      category: ProjectCategory.investment,
      status: ProjectStatus.ongoing,
      goalAmount: 10000,
      currentAmount: 0,
      endsIn: '',
      announcement: 'ROI fund',
      members: [],
      borrowRequests: [],
      joinApprovalRequired: true,
      roiPercentage: 8,
    );

    final form = CreateProjectFormFromDetail.map(project);

    expect(form.category, NewProjectCategory.investment);
    expect(form.flowType, ProjectCreationFlowType.investmentOptionalRoi);
    expect(form.visibility, ProjectVisibility.private);
    expect(form.roi, '8');
    expect(form.deadline, isNull);
  });
}
