import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_cubit.dart';
import 'core/di/injection.dart';
import 'core/router/app_router.dart';
import 'features/lists/presentation/bloc/lists_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  final prefs = getIt<SharedPreferences>();

  runApp(FluxDoneApp(prefs: prefs));
}

class FluxDoneApp extends StatelessWidget {
  final SharedPreferences prefs;
  const FluxDoneApp({super.key, required this.prefs});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ThemeCubit(prefs)),
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

