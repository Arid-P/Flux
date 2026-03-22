import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/theme_tokens.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          _buildSectionHeader(context, 'Preferences'),
          _buildSettingsTile(
            context,
            icon: Icons.palette_outlined,
            title: 'Appearance',
            subtitle: 'Theme, dark mode, accent colors',
            onTap: () => context.push('/settings/theme'),
          ),
          _buildSettingsTile(
            context,
            icon: Icons.notifications_none_outlined,
            title: 'Notifications',
            subtitle: 'Reminders, sounds, default offsets',
            onTap: () => context.push('/settings/notifications'),
          ),
          const Divider(),
          _buildSectionHeader(context, 'Account & Sync'),
          _buildSettingsTile(
            context,
            icon: Icons.account_circle_outlined,
            title: 'Google Account',
            subtitle: 'Sync, backup, calendar integration',
            onTap: () => context.push('/settings/google'),
          ),
          const Divider(),
          _buildSectionHeader(context, 'About'),
          _buildSettingsTile(
            context,
            icon: Icons.info_outline,
            title: 'FluxDone v1.0.0',
            subtitle: 'Help, support, privacy policy',
            onTap: () {
                // Show about dialog or similar
                showAboutDialog(
                  context: context,
                  applicationName: 'FluxDone',
                  applicationVersion: '1.0.0',
                  applicationLegalese: 'Part of Aridaman Flux Family',
                );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: context.tokens.textSecondary,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: context.tokens.primary),
      title: Text(title, style: TextStyle(color: context.tokens.textPrimary, fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle, style: TextStyle(color: context.tokens.textSecondary)),
      trailing: Icon(Icons.chevron_right, color: context.tokens.divider),
      onTap: onTap,
    );
  }
}
