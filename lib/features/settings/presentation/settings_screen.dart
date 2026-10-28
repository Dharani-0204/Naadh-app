import 'package:flutter/material.dart';

import '../../../app/router.dart';
import '../../../core/theme/app_colors.dart';
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
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('DEVICE', style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 8),
                ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: const CircleAvatar(
                    radius: 16,
                    backgroundColor: AppColors.lilac,
                    child: Icon(
                      Icons.qr_code_scanner,
                      size: 18,
                      color: AppColors.purple,
                    ),
                  ),
                  title: const Text(
                    'Add Device (QR Setup)',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.purple,
                    ),
                  ),
                  subtitle: const Text(
                    'Scan QR code on your Naadh reader',
                    style: TextStyle(fontSize: 12),
                  ),
                  trailing: const Icon(
                    Icons.chevron_right,
                    color: AppColors.purple,
                  ),
                  onTap: () {
                    Navigator.of(context).pushNamed(AppRoutes.deviceQrScanner);
                  },
                ),
                const Divider(height: 16),
                ...const [
                  'Device Information',
                  'Connection',
                  'Reconnect',
                  'Firmware Information',
                ].map(
                  (row) => ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title: Text(row),
                    trailing: const Icon(Icons.chevron_right),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          const _SettingSection(
            title: 'SCANNING',
            rows: ['Scan Preferences', 'Page Detection', 'Capture Preferences'],
          ),
          const SizedBox(height: AppSpacing.md),
          const _SettingSection(
            title: 'AUDIO',
            rows: [
              'Default Output',
              'Voice',
              'Speech Speed',
              'Playback Settings',
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          const _SettingSection(
            title: 'APPLICATION',
            rows: ['Theme', 'Language', 'Notifications', 'Storage'],
          ),
          const SizedBox(height: AppSpacing.md),
          const _SettingSection(
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
