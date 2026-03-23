import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_cubit.dart';
import 'core/di/injection.dart';
import 'core/router/app_router.dart';
import 'features/lists/presentation/bloc/lists_cubit.dart';
import 'features/settings/presentation/bloc/settings_cubit.dart';
import 'features/settings/data/preferences_repository.dart';

import 'core/notifications/notification_service.dart';
import 'features/fluxfoxus_bridge/data/fluxfocus_bridge_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  await getIt<NotificationService>().init();
  await getIt<FluxFocusBridgeService>().init();
  
  runApp(const FluxDoneApp());
}


class FluxDoneApp extends StatelessWidget {
  const FluxDoneApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ThemeCubit(getIt<PreferencesRepository>())),
        BlocProvider(create: (_) => getIt<SettingsCubit>()),
        BlocProvider(create: (_) => getIt<ListsCubit>()..loadAll()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp.router(
            title: 'FluxDone',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeMode,
            debugShowCheckedModeBanner: false,
            routerConfig: appRouter,
          );
        },
      ),
    );
  }
}


