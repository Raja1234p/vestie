/// Args for `/create-project/success` — keeps API project name for detail header.
class CreateProjectSuccessRouteArgs {
  final String projectId;
  final String? projectName;
  final bool isInvestment;
  final bool isEditFlow;

  const CreateProjectSuccessRouteArgs({
    required this.projectId,
    this.projectName,
    this.isInvestment = false,
    this.isEditFlow = false,
  });
}
