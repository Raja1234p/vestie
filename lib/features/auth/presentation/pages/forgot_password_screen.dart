import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/app_snackbar.dart';
import '../../../../core/widgets/common/app_failure_dialog.dart';
import '../bloc/forgot_password_bloc.dart';
import '../bloc/forgot_password_event.dart';
import '../bloc/forgot_password_state.dart';
import '../cubit/forgot_password_form_cubit.dart';
import '../widgets/auth_background.dart';
import '../widgets/forgot_password_form.dart';

/// Shell — provides ForgotPasswordBloc + ForgotPasswordFormCubit.
/// On success → pushes to /reset-password (set new password screen).
class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ForgotPasswordBloc()),
        BlocProvider(create: (_) => ForgotPasswordFormCubit()),
      ],
      child: BlocListener<ForgotPasswordBloc, ForgotPasswordState>(
        listener: (context, state) {
          if (state is ForgotPasswordSuccess) {
            AppSnackBar.showSuccess(context, AppStrings.forgotSuccessMsg);
            context.push(AppRoutes.resetPassword, extra: state.email);
          } else if (state is ForgotPasswordError) {
            AppFailureDialog.show(
              context,
              title: state.title,
              message: state.message,
            );
            context
                .read<ForgotPasswordBloc>()
                .add(const ForgotPasswordReset());
          }
        },
        child: const AuthBackground(child: ForgotPasswordForm()),
      ),
    );
  }
}
