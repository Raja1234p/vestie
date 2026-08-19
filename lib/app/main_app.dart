import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../core/constants/app_strings.dart';
import '../core/showcase/app_showcase.dart';
import '../core/theme/app_theme.dart';
import 'package:vestie/leader/features/create_project/presentation/cubit/create_project_cubit.dart';
import 'package:vestie/leader/features/create_project/presentation/cubit/create_project_update_cubit.dart';
import '../core/di/service_locator.dart';
import '../features/notifications/presentation/cubit/notification_unread_cubit.dart';
import '../features/wallet/presentation/cubit/wallet_cubit.dart';
import '../features/wallet/presentation/cubit/wallet_transaction_cubit.dart';
import '../core/services/project_invite_deep_link_service.dart';
import '../core/services/notifications/push_notification_router.dart';
import 'router/app_router.dart';

class MainApp extends StatefulWidget {
  const MainApp({
    super.key,
    this.previewLocale,
    this.previewAppBuilder,
  });

  /// Set from [main_dev.dart] only — keeps [device_preview] out of this file.
  final Locale? previewLocale;
  final Widget Function(BuildContext context, Widget? child)? previewAppBuilder;

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  void initState() {
    super.initState();
    AppShowcase.register();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (kDebugMode) {
        debugPrint('MainApp: first frame — starting deep link listener');
      }
      ProjectInviteDeepLinkService.instance.start(AppRouter.router);
      PushNotificationRouter.attach(AppRouter.router);
    });
  }

  @override
  void dispose() {
    AppShowcase.unregister();
    super.dispose();
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
            BlocProvider<CreateProjectUpdateCubit>(
              create: (_) => CreateProjectUpdateCubit(),
            ),
            BlocProvider<WalletTransactionCubit>(
              create: (_) => WalletTransactionCubit(),
            ),
            BlocProvider<WalletCubit>(
              create: (_) => WalletCubit(
                getWalletUseCase: ServiceLocator.instance.getWalletUseCase,
              ),
            ),
            BlocProvider<NotificationUnreadCubit>(
              create: (_) => NotificationUnreadCubit(
                listNotificationsUseCase:
                    ServiceLocator.instance.listNotificationsUseCase,
              ),
            ),
          ],
          child: MaterialApp.router(
            title: AppStrings.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            routerConfig: AppRouter.router,
            locale: widget.previewLocale,
            builder: (context, child) {
              final app = child ?? const SizedBox.shrink();
              final wrapped = widget.previewAppBuilder != null
                  ? widget.previewAppBuilder!(context, app)
                  : app;
              return FToastBuilder()(context, wrapped);
            },
          ),
        );
      },
    );
  }
}
