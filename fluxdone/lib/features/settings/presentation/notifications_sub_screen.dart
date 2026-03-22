import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/settings_cubit.dart';
import '../../../../core/theme/theme_tokens.dart';

class NotificationsSubScreen extends StatelessWidget {
  const NotificationsSubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          final tokens = context.tokens;
          
          return ListView(
            children: [
              SwitchListTile(
                title: Text('Enable Notifications', style: TextStyle(color: tokens.textPrimary, fontWeight: FontWeight.w500)),
                subtitle: Text('Master switch for all reminders', style: TextStyle(color: tokens.textSecondary)),
                value: state.notificationsEnabled,
                activeColor: tokens.primary,
                onChanged: (value) => context.read<SettingsCubit>().setNotificationsEnabled(value),
              ),
              const Divider(),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  'DEFAULT REMINDERS',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: tokens.textSecondary,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              _buildOffsetOption(context, 'At time of event', 0, state.defaultReminderOffset),
              _buildOffsetOption(context, '5 minutes before', 5, state.defaultReminderOffset),
              _buildOffsetOption(context, '10 minutes before', 10, state.defaultReminderOffset),
              _buildOffsetOption(context, '15 minutes before', 15, state.defaultReminderOffset),
              _buildOffsetOption(context, '30 minutes before', 30, state.defaultReminderOffset),
              _buildOffsetOption(context, '1 hour before', 60, state.defaultReminderOffset),
              _buildOffsetOption(context, '1 day before', 1440, state.defaultReminderOffset),
            ],
          );
        },
      ),
    );
  }

  Widget _buildOffsetOption(BuildContext context, String label, int value, int currentValue) {
    final isSelected = value == currentValue;
    final tokens = context.tokens;

    return RadioListTile<int>(
      title: Text(label, style: TextStyle(color: tokens.textPrimary)),
      value: value,
      groupValue: currentValue,
      activeColor: tokens.primary,
      onChanged: (val) {
        if (val != null) {
          context.read<SettingsCubit>().setDefaultReminderOffset(val);
        }
      },
    );
  }
}
