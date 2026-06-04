import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:device_preview/device_preview.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../core/constants/app_strings.dart';
import '../core/theme/app_theme.dart';
import 'package:vestie/leader/features/create_project/presentation/cubit/create_project_cubit.dart';
import '../core/di/service_locator.dart';
import '../features/wallet/presentation/cubit/wallet_cubit.dart';
import '../features/wallet/presentation/cubit/wallet_transaction_cubit.dart';
import '../core/services/project_invite_deep_link_service.dart';
import 'router/app_router.dart';

class MainApp extends StatefulWidget {
  const MainApp({
    super.key,
    this.enableDevicePreview = false,
  });

  final bool enableDevicePreview;

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ProjectInviteDeepLinkService.instance.start(AppRouter.router);
    });
  }

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
            BlocProvider<WalletCubit>(
              create: (_) => WalletCubit(
                getWalletUseCase: ServiceLocator.instance.getWalletUseCase,
              ),
            ),
          ],
          child: MaterialApp.router(
            title: AppStrings.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            routerConfig: AppRouter.router,
            locale: widget.enableDevicePreview
                ? DevicePreview.locale(context)
                : null,
            builder: (context, child) {
              final app = child ?? const SizedBox.shrink();
              final wrapped = widget.enableDevicePreview
                  ? DevicePreview.appBuilder(context, app)
                  : app;
              return FToastBuilder()(context, wrapped);
            },
          ),
        );
      },
    );
  }
}
