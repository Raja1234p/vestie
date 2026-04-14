import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../core/constants/app_strings.dart';
import '../core/theme/app_theme.dart';
import '../features/create_project/presentation/cubit/create_project_cubit.dart';
import 'router/app_router.dart';

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MultiBlocProvider(
          providers: [
            // Wizard cubit lives at app-level so it persists across pushed routes
            BlocProvider<CreateProjectCubit>(
              create: (_) => CreateProjectCubit(),
            ),
          ],
          child: MaterialApp.router(
            title: AppStrings.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            routerConfig: AppRouter.router,
          ),
        );
      },
    );
  }
}
