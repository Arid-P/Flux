import 'package:flutter/material.dart';
import 'theme_tokens.dart';

class AppTheme {
  static ThemeData get lightTheme {
    final tokens = ThemeTokens.light;
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: tokens.primary,
      scaffoldBackgroundColor: tokens.background,
      fontFamily: 'Roboto', // Default standard font
      colorScheme: ColorScheme.light(
        primary: tokens.primary,
        surface: tokens.surface,
        error: tokens.error,
        background: tokens.background,
      ),
      listTileTheme: ListTileThemeData(
        textColor: tokens.textPrimary,
        iconColor: tokens.textSecondary,
      ),
      dividerTheme: DividerThemeData(
        color: tokens.divider,
      ),
      textTheme: TextTheme(
        bodyMedium: TextStyle(color: tokens.textPrimary),
        bodySmall: TextStyle(color: tokens.textSecondary),
      ),
    );
  }

  static ThemeData get darkTheme {
    final tokens = ThemeTokens.dark;
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: tokens.primary,
      scaffoldBackgroundColor: tokens.background,
      fontFamily: 'Roboto',
      colorScheme: ColorScheme.dark(
        primary: tokens.primary,
        surface: tokens.surface,
        error: tokens.error,
        background: tokens.background,
      ),
      listTileTheme: ListTileThemeData(
        textColor: tokens.textPrimary,
        iconColor: tokens.textSecondary,
      ),
      dividerTheme: DividerThemeData(
        color: tokens.divider,
      ),
      textTheme: TextTheme(
        bodyMedium: TextStyle(color: tokens.textPrimary),
        bodySmall: TextStyle(color: tokens.textSecondary),
      ),
    );
  }
}
