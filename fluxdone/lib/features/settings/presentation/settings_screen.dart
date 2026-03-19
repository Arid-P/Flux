import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/theme_cubit.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Appearance'),
            subtitle: const Text('Toggle between Light and Dark themes'),
            trailing: const Icon(Icons.brightness_6),
            onTap: () {
              context.read<ThemeCubit>().toggleTheme(context);
            },
          ),
        ],
      ),
    );
  }
}
