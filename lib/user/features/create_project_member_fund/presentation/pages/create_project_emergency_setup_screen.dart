import 'package:flutter/material.dart';

import '../models/create_project_fund_draft.dart';
import 'create_project_fund_member_setup_screen.dart';

/// Image storyboard entry: Emergency Fund setup.
class CreateProjectEmergencySetupScreen extends StatelessWidget {
  const CreateProjectEmergencySetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const CreateProjectFundMemberSetupScreen(
      kind: CreateProjectFundKind.emergency,
    );
  }
}
