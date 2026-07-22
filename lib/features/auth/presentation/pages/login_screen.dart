import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/router/project_invite_navigation.dart';
import '../../../../core/auth/app_auth_session.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/widgets/common/app_failure_dialog.dart';
import '../../../../core/widgets/common/app_toast.dart';
import '../bloc/login_bloc.dart';
import '../bloc/login_event.dart';
import '../bloc/login_state.dart';
import '../cubit/login_form_cubit.dart';
import '../models/auth_route_extras.dart';
import '../widgets/auth_background.dart';
import '../widgets/login_form.dart';

/// Shell widget — provides LoginBloc + LoginFormCubit, handles navigation.
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => LoginBloc()),
        BlocProvider(create: (_) => LoginFormCubit()),
      ],
      child: BlocListener<LoginBloc, LoginState>(
        listenWhen: (prev, curr) =>
            curr is LoginSuccess ||
            curr is LoginGoogleSuccess ||
            curr is LoginAppleSuccess ||
            curr is LoginEmailNotVerified ||
            curr is LoginError,
        listener: (context, state) async {
          if (state is LoginSuccess) {
            AppLogger.info('Login success: ${state.user.email}');
            await AppAuthSession.instance.syncFromStorage();
            if (!context.mounted) return;
            await ProjectInviteNavigation.goAfterAuth(
              context,
              disclaimerAccepted: state.isDisclaimerAccepted,
            );
          } else if (state is LoginGoogleSuccess ||
              state is LoginAppleSuccess) {
            final disclaimerAccepted = state is LoginGoogleSuccess
                ? state.isDisclaimerAccepted
                : (state as LoginAppleSuccess).isDisclaimerAccepted;
            await AppAuthSession.instance.syncFromStorage();
            if (!context.mounted) return;
            await ProjectInviteNavigation.goAfterAuth(
              context,
              disclaimerAccepted: disclaimerAccepted,
            );
          } else if (state is LoginEmailNotVerified) {
            // Same OTP → agreement path as registration ([VerifyFlow.registration]).
            AppToast.showSuccess(
              context,
              AppStrings.loginEmailNotVerifiedToast,
            );
            await context.push(
              AppRoutes.verify,
              extra: VerifyScreenExtra(email: state.email),
            );
            if (!context.mounted) return;
            context.read<LoginBloc>().add(const LoginReset());
          } else if (state is LoginError) {
            AppFailureDialog.show(
              context,
              title: state.title,
              message: state.message,
            );
            context.read<LoginBloc>().add(const LoginReset());
          }
        },
        child: const AuthBackground(child: LoginForm()),
      ),
    );
  }
}
