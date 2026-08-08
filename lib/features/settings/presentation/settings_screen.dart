import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/app_card.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _SettingSection(
            title: 'DEVICE',
            rows: [
              'Device Information',
              'Connection',
              'Reconnect',
              'Firmware Information',
            ],
          ),
          SizedBox(height: AppSpacing.md),
          _SettingSection(
            title: 'SCANNING',
            rows: ['Scan Preferences', 'Page Detection', 'Capture Preferences'],
          ),
          SizedBox(height: AppSpacing.md),
          _SettingSection(
            title: 'AUDIO',
            rows: [
              'Default Output',
              'Voice',
              'Speech Speed',
              'Playback Settings',
            ],
          ),
          SizedBox(height: AppSpacing.md),
          _SettingSection(
            title: 'APPLICATION',
            rows: ['Theme', 'Language', 'Notifications', 'Storage'],
          ),
          SizedBox(height: AppSpacing.md),
          _SettingSection(
            title: 'ABOUT',
            rows: [
              'About Alien Innovations',
              'Version',
              'Help',
              'Privacy',
              'Terms',
            ],
          ),
        ],
      ),
    );
  }
}

class _SettingSection extends StatelessWidget {
  const _SettingSection({required this.title, required this.rows});

  final String title;
  final List<String> rows;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 8),
          ...rows.map(
            (row) => ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: Text(row),
              trailing: const Icon(Icons.chevron_right),
            ),
          ),
        ],
      ),
    );
  }
}
