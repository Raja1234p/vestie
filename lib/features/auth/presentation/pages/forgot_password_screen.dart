import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/widgets/common/app_failure_dialog.dart';
import '../bloc/forgot_password_bloc.dart';
import '../bloc/forgot_password_event.dart';
import '../bloc/forgot_password_state.dart';
import '../cubit/forgot_password_form_cubit.dart';
import '../widgets/auth_background.dart';
import '../widgets/forgot_password_form.dart';
import '../models/auth_route_extras.dart';

/// Shell — provides ForgotPasswordBloc + ForgotPasswordFormCubit.
/// On success → same OTP screen as register ([AppRoutes.verify], forgot flow).
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
        listener: (context, state) async {
          if (state is ForgotPasswordSuccess) {
            await context.push(
              AppRoutes.verify,
              extra: VerifyScreenExtra(
                email: state.email,
                flow: VerifyFlow.forgotPassword,
              ),
            );
            if (!context.mounted) return;
            context.read<ForgotPasswordBloc>().add(const ForgotPasswordReset());
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
