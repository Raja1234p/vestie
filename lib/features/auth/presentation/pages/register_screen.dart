import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/router/project_invite_navigation.dart';
import '../../../../core/auth/app_auth_session.dart';
import '../models/auth_route_extras.dart';
import '../../../../core/widgets/common/app_failure_dialog.dart';
import '../../../../core/widgets/common/app_loading_dialog.dart';
import '../bloc/register_bloc.dart';
import '../bloc/register_event.dart';
import '../bloc/register_state.dart';
import '../cubit/register_form_cubit.dart';
import '../widgets/auth_background.dart';
import '../widgets/register_form.dart';

/// Shell widget — provides RegisterBloc + RegisterFormCubit, handles navigation.
class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => RegisterBloc()),
        BlocProvider(create: (_) => RegisterFormCubit()),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<RegisterBloc, RegisterState>(
            listenWhen: (prev, curr) => curr is RegisterGoogleLoading,
            listener: (context, _) {
              AppLoadingDialog.show(context);
            },
          ),
          BlocListener<RegisterBloc, RegisterState>(
            listenWhen: (prev, curr) =>
                prev is RegisterGoogleLoading && curr is! RegisterGoogleLoading,
            listener: (context, _) {
              final nav = Navigator.of(context, rootNavigator: true);
              if (nav.canPop()) nav.pop();
            },
          ),
          BlocListener<RegisterBloc, RegisterState>(
            listenWhen: (prev, curr) =>
                curr is RegisterSuccess ||
                curr is RegisterGoogleSuccess ||
                curr is RegisterError,
            listener: (context, state) async {
              if (state is RegisterSuccess) {
                await context.push(
                  AppRoutes.verify,
                  extra: VerifyScreenExtra(email: state.user.email),
                );
                if (!context.mounted) return;
                context.read<RegisterBloc>().add(const RegisterReset());
              } else if (state is RegisterGoogleSuccess) {
                await AppAuthSession.instance.refresh();
                if (!context.mounted) return;
                await ProjectInviteNavigation.goAfterAuth(
                  context,
                  disclaimerAccepted: state.isDisclaimerAccepted,
                );
              } else if (state is RegisterError) {
                AppFailureDialog.show(
                  context,
                  title: state.title,
                  message: state.message,
                );
                context.read<RegisterBloc>().add(const RegisterReset());
              }
            },
          ),
        ],
        child: const AuthBackground(child: RegisterForm()),
      ),
    );
  }
}
