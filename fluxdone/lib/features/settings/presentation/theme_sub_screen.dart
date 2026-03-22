import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../../../../core/theme/theme_tokens.dart';

class ThemeSubScreen extends StatelessWidget {
  const ThemeSubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeCubit = context.watch<ThemeCubit>();
    final currentMode = themeCubit.state;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Appearance'),
      ),
      body: ListView(
        children: [
          _buildThemeOption(
            context,
            title: 'System Default',
            subtitle: 'Match system settings',
            mode: ThemeMode.system,
            currentMode: currentMode,
            icon: Icons.brightness_auto,
          ),
          _buildThemeOption(
            context,
            title: 'Light Mode',
            subtitle: 'Classic bright theme',
            mode: ThemeMode.light,
            currentMode: currentMode,
            icon: Icons.light_mode_outlined,
          ),
          _buildThemeOption(
            context,
            title: 'Dark Mode',
            subtitle: 'Easier on the eyes at night',
            mode: ThemeMode.dark,
            currentMode: currentMode,
            icon: Icons.dark_mode_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context, {
    required String title,
    required String subtitle,
    required ThemeMode mode,
    required ThemeMode currentMode,
    required IconData icon,
  }) {
    final isSelected = mode == currentMode;
    final tokens = context.tokens;

    return ListTile(
      leading: Icon(icon, color: isSelected ? tokens.primary : tokens.textSecondary),
      title: Text(title, style: TextStyle(color: tokens.textPrimary, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
      subtitle: Text(subtitle, style: TextStyle(color: tokens.textSecondary)),
      trailing: isSelected ? Icon(Icons.check, color: tokens.primary) : null,
      onTap: () => context.read<ThemeCubit>().setTheme(mode),
    );
  }
}
