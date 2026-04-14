import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/app_snackbar.dart';
import '../../../../app/router/app_routes.dart';
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
        listener: (context, state) {
          if (state is RegisterSuccess) {
            context.go(AppRoutes.verify, extra: state.email);
          } else if (state is RegisterError) {
            AppSnackBar.showError(context, state.message);
            context.read<RegisterBloc>().add(const RegisterReset());
          }
        },
        child: const AuthBackground(child: RegisterForm()),
      ),
    );
  }
}
