import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/settings_cubit.dart';
import '../../../../core/theme/theme_tokens.dart';

class GoogleSubScreen extends StatelessWidget {
  const GoogleSubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Google Account'),
      ),
      body: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          final tokens = context.tokens;
          
          return ListView(
            children: [
              const SizedBox(height: 16),
              Center(
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: tokens.surfaceVariant,
                  child: Icon(Icons.person, size: 50, color: tokens.textSecondary),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  state.googleCalendarConnected ? 'Connected to Google' : 'Not Connected',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: tokens.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  'Sign in to sync your calendar and backup data',
                  style: TextStyle(color: tokens.textSecondary),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Placeholder for actual sign-in
                    context.read<SettingsCubit>().setGoogleCalendarConnected(!state.googleCalendarConnected);
                  },
                  icon: const Icon(Icons.login),
                  label: Text(state.googleCalendarConnected ? 'Sign Out' : 'Sign in with Google'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: tokens.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const Divider(height: 48),
              ListTile(
                title: Text('Google Calendar Sync', style: TextStyle(color: tokens.textPrimary)),
                subtitle: const Text('Overlay your calendar events'),
                trailing: state.googleCalendarConnected ? Switch(value: true, onChanged: (_) {}) : null,
                enabled: state.googleCalendarConnected,
              ),
              ListTile(
                title: Text('Google Drive Backup', style: TextStyle(color: tokens.textPrimary)),
                subtitle: const Text('Securely backup your database'),
                trailing: const Icon(Icons.chevron_right),
                enabled: state.googleCalendarConnected,
                onTap: () {
                   // context.push('/settings/google/backup');
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
