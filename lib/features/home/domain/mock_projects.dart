import 'entities/project.dart';

/// Stub data — replace with repository call when API is ready.
class MockProjects {
  MockProjects._();

  static const List<Project> myProjects = [
    Project(
      id: 'p1',
      name: 'Europe Trip 2025',
      category: ProjectCategory.vacations,
      status: ProjectStatus.ongoing,
      relation: ProjectRelation.owned,
      goalAmount: 5000,
      currentAmount: 2700,
      endsIn: '2 months',
    ),
    Project(
      id: 'p2',
      name: 'Investment Fund',
      category: ProjectCategory.investment,
      status: ProjectStatus.completed,
      relation: ProjectRelation.owned,
      currentAmount: 7600,
    ),
    Project(
      id: 'p3',
      name: 'Emergency Fund',
      category: ProjectCategory.emergency,
      status: ProjectStatus.completed,
      relation: ProjectRelation.owned,
      currentAmount: 5000,
    ),
  ];

  static const List<Project> joinedProjects = [
    Project(
      id: 'p4',
      name: 'Europe Trip 2025',
      category: ProjectCategory.vacations,
      status: ProjectStatus.ongoing,
      relation: ProjectRelation.joined,
      goalAmount: 5000,
      currentAmount: 2700,
      endsIn: '2 months',
      description: 'e.g. Summer vacation across France and Italy',
    ),
    Project(
      id: 'p5',
      name: 'Group Investment',
      category: ProjectCategory.investment,
      status: ProjectStatus.completed,
      relation: ProjectRelation.joined,
      currentAmount: 5000,
    ),
  ];

  static const List<Project> discoverProjects = [
    Project(
      id: 'd1',
      name: 'Europe Trip 2025',
      category: ProjectCategory.vacations,
      status: ProjectStatus.ongoing,
      relation: ProjectRelation.joined,
      goalAmount: 5000,
      currentAmount: 2700,
      endsIn: '2 months',
      description: 'e.g. Summer vacation across France and Italy',
    ),
    Project(
      id: 'd2',
      name: 'Investment Fund',
      category: ProjectCategory.investment,
      status: ProjectStatus.ongoing,
      relation: ProjectRelation.joined,
      goalAmount: 5000,
      currentAmount: 2700,
      endsIn: '2 months',
      description: 'e.g. for financial freedom (after goal pot will be close and there will only be return)',
      requestPending: true,
    ),
    Project(
      id: 'd3',
      name: 'Investment Fund',
      category: ProjectCategory.investment,
      status: ProjectStatus.ongoing,
      relation: ProjectRelation.joined,
      goalAmount: 5000,
      currentAmount: 2700,
      endsIn: '2 months',
      description: 'e.g. for financial freedom (after goal pot will be close and there will only be return)',
    ),
    Project(
      id: 'd4',
      name: 'Europe Trip 2025',
      category: ProjectCategory.vacations,
      status: ProjectStatus.ongoing,
      relation: ProjectRelation.joined,
      goalAmount: 5000,
      currentAmount: 2700,
      endsIn: '2 months',
      description: 'e.g. Summer vacation across France and Italy',
    ),
  ];
}
