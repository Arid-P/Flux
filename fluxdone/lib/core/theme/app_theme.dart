import 'package:flutter/material.dart';
import 'theme_tokens.dart';

class AppTheme {
  static ThemeData get lightTheme {
    final tokens = ThemeTokens.light;
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: tokens.primary,
      scaffoldBackgroundColor: tokens.surface,
      fontFamily: 'Roboto', // Default standard font
      colorScheme: ColorScheme.fromSeed(
        seedColor: tokens.primary,
        surface: tokens.surface,
        error: const Color(0xFFE53935),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: tokens.surface,
        elevation: 0,
        iconTheme: IconThemeData(color: tokens.textPrimary),
        titleTextStyle: TextStyle(
          color: tokens.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
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
      scaffoldBackgroundColor: tokens.surface,
      fontFamily: 'Roboto',
      colorScheme: ColorScheme.fromSeed(
        seedColor: tokens.primary,
        brightness: Brightness.dark,
        surface: tokens.surface,
        error: const Color(0xFFE53935),
      ),
    );
  }
}
