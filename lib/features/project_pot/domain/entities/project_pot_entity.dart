import 'package:equatable/equatable.dart';

class ProjectPotEntity extends Equatable {
  final double potAmount;
  final int contributorCount;
  final List<String> vffMemberUserIds;

  const ProjectPotEntity({
    required this.potAmount,
    required this.contributorCount,
    this.vffMemberUserIds = const [],
  });

  @override
  List<Object?> get props => [potAmount, contributorCount, vffMemberUserIds];
}
