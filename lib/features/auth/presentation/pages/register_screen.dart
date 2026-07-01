import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/router/project_invite_navigation.dart';
import '../../../../core/auth/app_auth_session.dart';
import '../models/auth_route_extras.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/common/app_failure_dialog.dart';
import '../../../../core/widgets/common/app_toast.dart';
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
      child: BlocListener<RegisterBloc, RegisterState>(
        listenWhen: (prev, curr) =>
            curr is RegisterSuccess ||
            curr is RegisterGoogleSuccess ||
            curr is RegisterAppleSuccess ||
            curr is RegisterError,
        listener: (context, state) async {
          if (state is RegisterSuccess) {
            AppToast.showSuccess(
              context,
              AppStrings.registerSuccessToast,
            );
            await context.push(
              AppRoutes.verify,
              extra: VerifyScreenExtra(email: state.user.email),
            );
            if (!context.mounted) return;
            context.read<RegisterBloc>().add(const RegisterReset());
          } else if (state is RegisterGoogleSuccess ||
              state is RegisterAppleSuccess) {
            final disclaimerAccepted = state is RegisterGoogleSuccess
                ? state.isDisclaimerAccepted
                : (state as RegisterAppleSuccess).isDisclaimerAccepted;
            await AppAuthSession.instance.syncFromStorage();
            if (!context.mounted) return;
            await ProjectInviteNavigation.goAfterAuth(
              context,
              disclaimerAccepted: disclaimerAccepted,
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
        child: const AuthBackground(child: RegisterForm()),
      ),
    );
  }
}
