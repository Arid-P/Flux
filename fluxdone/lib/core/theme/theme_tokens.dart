import 'package:flutter/material.dart';

class ThemeTokens {
  // App-wide Common Tokens
  final Color primary;
  final Color background;
  final Color surface;
  final Color surfaceVariant;
  final Color textPrimary;
  final Color textSecondary;
  final Color error;
  final Color divider;
  
  // Specific Domain Colors (User-locked domains)
  final Color numberTheory;
  final Color geometry;
  final Color combinatorics;
  final Color algebraP1;
  final Color algebraP2;
  final Color tests;
  final Color neevDiamond;
  
  const ThemeTokens({
    required this.primary,
    required this.background,
    required this.surface,
    required this.surfaceVariant,
    required this.textPrimary,
    required this.textSecondary,
    required this.error,
    required this.divider,
    required this.numberTheory,
    required this.geometry,
    required this.combinatorics,
    required this.algebraP1,
    required this.algebraP2,
    required this.tests,
    required this.neevDiamond,
  });

  static const ThemeTokens light = ThemeTokens(
    primary: Color(0xFF6366F1), // Using same primary as FF for cohesion
    background: Color(0xFFF8FAFC),
    surface: Colors.white,
    surfaceVariant: Color(0xFFF1F5F9),
    textPrimary: Color(0xFF0F172A),
    textSecondary: Color(0xFF64748B),
    error: Color(0xFFEF4444),
    divider: Color(0xFFE2E8F0),
    numberTheory: Color(0xFF2E7D32),
    geometry: Color(0xFF1565C0),
    combinatorics: Color(0xFF43A047),
    algebraP1: Color(0xFFFB8C00),
    algebraP2: Color(0xFFE64A19),
    tests: Color(0xFFE53935),
    neevDiamond: Color(0xFF576481),
  );

  static const ThemeTokens dark = ThemeTokens(
    primary: Color(0xFF6366F1),
    background: Color(0xFF0F172A),
    surface: Color(0xFF1E293B),
    surfaceVariant: Color(0xFF334155),
    textPrimary: Color(0xFFF8FAFC),
    textSecondary: Color(0xFF94A3B8),
    error: Color(0xFFEF4444),
    divider: Color(0xFF334155),
    numberTheory: Color(0xFF2E7D32),
    geometry: Color(0xFF1565C0),
    combinatorics: Color(0xFF43A047),
    algebraP1: Color(0xFFFB8C00),
    algebraP2: Color(0xFFE64A19),
    tests: Color(0xFFE53935),
    neevDiamond: Color(0xFF576481),
  );
}

extension ThemeTokensExtension on BuildContext {
  ThemeTokens get tokens {
    final Brightness brightness = Theme.of(this).brightness;
    return brightness == Brightness.dark ? ThemeTokens.dark : ThemeTokens.light;
  }
}
