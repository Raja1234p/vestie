import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/widgets/common/app_failure_dialog.dart';
import '../../../../core/widgets/common/app_loading_dialog.dart';
import '../bloc/login_bloc.dart';
import '../bloc/login_event.dart';
import '../bloc/login_state.dart';
import '../cubit/login_form_cubit.dart';
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
      child: MultiBlocListener(
        listeners: [
          BlocListener<LoginBloc, LoginState>(
            listenWhen: (prev, curr) => curr is LoginGoogleLoading,
            listener: (context, _) {
              AppLoadingDialog.show(context);
            },
          ),
          BlocListener<LoginBloc, LoginState>(
            listenWhen: (prev, curr) =>
                prev is LoginGoogleLoading && curr is! LoginGoogleLoading,
            listener: (context, _) {
              final nav = Navigator.of(context, rootNavigator: true);
              if (nav.canPop()) nav.pop();
            },
          ),
          BlocListener<LoginBloc, LoginState>(
            listenWhen: (prev, curr) =>
                curr is LoginSuccess ||
                curr is LoginGoogleSuccess ||
                curr is LoginError,
            listener: (context, state) {
              if (state is LoginSuccess) {
                AppLogger.info('Login success: ${state.user.email}');
                if (state.isDisclaimerAccepted) {
                  context.go(AppRoutes.dashboard);
                } else {
                  context.go(AppRoutes.agreement);
                }
              } else if (state is LoginGoogleSuccess) {
                if (state.isDisclaimerAccepted) {
                  context.go(AppRoutes.dashboard);
                } else {
                  context.go(AppRoutes.agreement);
                }
              } else if (state is LoginError) {
                AppFailureDialog.show(
                  context,
                  title: state.title,
                  message: state.message,
                );
                context.read<LoginBloc>().add(const LoginReset());
              }
            },
          ),
        ],
        child: const AuthBackground(child: LoginForm()),
      ),
    );
  }
}
