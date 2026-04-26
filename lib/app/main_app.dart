import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:device_preview/device_preview.dart';
import '../core/constants/app_strings.dart';
import '../core/theme/app_theme.dart';
import '../features/create_project/presentation/cubit/create_project_cubit.dart';
import '../features/wallet/presentation/cubit/wallet_transaction_cubit.dart';
import 'router/app_router.dart';

class MainApp extends StatelessWidget {
  const MainApp({
    super.key,
    this.enableDevicePreview = false,
  });

  final bool enableDevicePreview;

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
            BlocProvider<WalletTransactionCubit>(
              create: (_) => WalletTransactionCubit(),
            ),
          ],
          child: MaterialApp.router(
            title: AppStrings.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            routerConfig: AppRouter.router,
            locale: enableDevicePreview
                ? DevicePreview.locale(context)
                : null,
            builder: enableDevicePreview
                ? DevicePreview.appBuilder
                : null,
          ),
        );
      },
    );
  }
}
