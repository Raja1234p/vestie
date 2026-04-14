import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/app_snackbar.dart';
import '../bloc/reset_password_bloc.dart';
import '../bloc/reset_password_event.dart';
import '../bloc/reset_password_state.dart';
import '../cubit/reset_password_form_cubit.dart';
import '../widgets/auth_background.dart';
import '../widgets/reset_password_form.dart';

/// Shell — provides ResetPasswordBloc + ResetPasswordFormCubit.
class ResetPasswordScreen extends StatelessWidget {
  const ResetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ResetPasswordBloc()),
        BlocProvider(create: (_) => ResetPasswordFormCubit()),
      ],
      child: BlocListener<ResetPasswordBloc, ResetPasswordState>(
        listener: (context, state) {
          if (state is ResetPasswordSuccess) {
            AppSnackBar.showSuccess(context, AppStrings.resetSuccessMsg);
            context.go(AppRoutes.login);
          } else if (state is ResetPasswordError) {
            AppSnackBar.showError(context, state.message);
            context.read<ResetPasswordBloc>().add(const ResetPasswordReset());
          }
        },
        child: const AuthBackground(child: ResetPasswordForm()),
      ),
    );
  }
}
