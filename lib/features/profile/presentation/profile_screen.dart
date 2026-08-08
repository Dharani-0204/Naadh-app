import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/app_card.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(radius: 28, child: Icon(Icons.person)),
              SizedBox(height: AppSpacing.md),
              Text('Jordan Davis'),
              SizedBox(height: 4),
              Text('jordan.davis@email.com'),
            ],
          ),
        ),
        SizedBox(height: AppSpacing.md),
        AppCard(
          child: _ProfileInfoBlock(
            title: 'Device Information',
            lines: [
              'Alien Reader Model A1',
              'Firmware v2.4.1',
              'Connected device usage: 24 documents',
            ],
          ),
        ),
        SizedBox(height: AppSpacing.md),
        AppCard(
          child: _ProfileInfoBlock(
            title: 'Usage',
            lines: [
              'Pages scanned: 312',
              'Audio generated: 18 hours',
              'Storage used: 486 MB',
            ],
          ),
        ),
      ],
    );
  }
}

class _ProfileInfoBlock extends StatelessWidget {
  const _ProfileInfoBlock({required this.title, required this.lines});

  final String title;
  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        ...lines.map(
          (line) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(line),
          ),
        ),
      ],
    );
  }
}
