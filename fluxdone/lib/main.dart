import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_tokens.dart';
import 'core/theme/theme_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  
  runApp(FluxDoneApp(prefs: prefs));
}

class FluxDoneApp extends StatelessWidget {
  final SharedPreferences prefs;
  const FluxDoneApp({super.key, required this.prefs});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ThemeCubit(prefs),
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp(
            title: 'FluxDone',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeMode,
            debugShowCheckedModeBanner: false,
            home: const ThemeTestScreen(),
          );
        },
      ),
    );
  }
}

class ThemeTestScreen extends StatelessWidget {
  const ThemeTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Theme Configuration Test'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.read<ThemeCubit>().toggleTheme(context),
        child: const Icon(Icons.brightness_6),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Text(
            'Tokens are injected successfully.',
            style: TextStyle(color: context.tokens.textPrimary, fontSize: 18),
          ),
          const SizedBox(height: 16),
          _ColorBox('Primary', context.tokens.primary),
          _ColorBox('Background', context.tokens.background),
          _ColorBox('Surface', context.tokens.surface),
          _ColorBox('Number Theory', context.tokens.numberTheory),
          _ColorBox('Geometry', context.tokens.geometry),
        ],
      ),
    );
  }
}

class _ColorBox extends StatelessWidget {
  final String name;
  final Color color;
  const _ColorBox(this.name, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      color: color,
      child: Text(
        name,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }
}
