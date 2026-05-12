import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:vestie/app/router/app_routes.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/leader/features/create_project/presentation/cubit/create_project_cubit.dart';
import 'package:vestie/leader/features/create_project/presentation/widgets/create_project_amount_sheet_content.dart';

/// Deep-link / route entry for amount step — same UI as the home bottom sheet.
class CreateProjectAmountScreen extends StatefulWidget {
  const CreateProjectAmountScreen({super.key});

  @override
  State<CreateProjectAmountScreen> createState() =>
      _CreateProjectAmountScreenState();
}

class _CreateProjectAmountScreenState extends State<CreateProjectAmountScreen> {
  @override
  void initState() {
    super.initState();
    context.read<CreateProjectCubit>().reset();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: CreateProjectAmountSheetContent(
          onFinished: (committed) {
            final cubit = context.read<CreateProjectCubit>();
            if (!committed) {
              cubit.reset();
              context.pop();
            } else {
              context.push(AppRoutes.createProjectDetails);
            }
          },
        ),
      ),
    );
  }
}
