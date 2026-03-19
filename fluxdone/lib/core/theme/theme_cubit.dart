import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  static const String _themeKey = 'app_theme_mode';
  final SharedPreferences prefs;

  ThemeCubit(this.prefs) : super(_loadTheme(prefs));

  static ThemeMode _loadTheme(SharedPreferences prefs) {
    final isDark = prefs.getBool(_themeKey);
    if (isDark == null) return ThemeMode.system;
    return isDark ? ThemeMode.dark : ThemeMode.light;
  }

  Future<void> setTheme(ThemeMode mode) async {
    if (mode == ThemeMode.system) {
      await prefs.remove(_themeKey);
    } else {
      await prefs.setBool(_themeKey, mode == ThemeMode.dark);
    }
    emit(mode);
  }

  Future<void> toggleTheme(BuildContext context) async {
    final Brightness brightness = MediaQuery.of(context).platformBrightness;
    final bool isCurrentlyDark = state == ThemeMode.dark || 
        (state == ThemeMode.system && brightness == Brightness.dark);
    
    await setTheme(isCurrentlyDark ? ThemeMode.light : ThemeMode.dark);
  }
}
