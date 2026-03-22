import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/settings/data/preferences_repository.dart';
import 'package:flutter/material.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  final PreferencesRepository _prefsRepo;

  ThemeCubit(this._prefsRepo) : super(_loadTheme(_prefsRepo));

  static ThemeMode _loadTheme(PreferencesRepository repo) {
    final themeStr = repo.getAppTheme();
    switch (themeStr) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  Future<void> setTheme(ThemeMode mode) async {
    String themeStr;
    switch (mode) {
      case ThemeMode.light:
        themeStr = 'light';
        break;
      case ThemeMode.dark:
        themeStr = 'dark';
        break;
      case ThemeMode.system:
        themeStr = 'system';
        break;
    }
    await _prefsRepo.setAppTheme(themeStr);
    emit(mode);
  }

  Future<void> toggleTheme(BuildContext context) async {
    final Brightness brightness = MediaQuery.of(context).platformBrightness;
    final bool isCurrentlyDark = state == ThemeMode.dark || 
        (state == ThemeMode.system && brightness == Brightness.dark);
    
    await setTheme(isCurrentlyDark ? ThemeMode.light : ThemeMode.dark);
  }
}

