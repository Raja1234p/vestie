import 'package:flutter/material.dart';

import '../models/create_project_fund_draft.dart';
import 'create_project_fund_member_setup_screen.dart';

/// Image storyboard entry: Vacation Fund setup.
class CreateProjectVacationSetupScreen extends StatelessWidget {
  const CreateProjectVacationSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const CreateProjectFundMemberSetupScreen(
      kind: CreateProjectFundKind.vacation,
    );
  }
}
