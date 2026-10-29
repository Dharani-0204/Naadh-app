import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/app_card.dart';
import '../widgets/output_device_sheet.dart';

/// "Output" tab — output device selector and audio status.
///
/// Processed document results are shown in DocumentResultsScreen.
/// This tab configures audio output destinations (Speaker, Headphones, Bluetooth).
class OutputScreen extends StatefulWidget {
  const OutputScreen({super.key});

  @override
  State<OutputScreen> createState() => _OutputScreenState();
}

class _OutputScreenState extends State<OutputScreen> {
  String outputDevice = 'Phone Speaker';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Output device selector
        AppCard(
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.purpleDarkTint
                      : AppColors.purpleLightTint,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.volume_up_outlined,
                  color: AppColors.purple,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'AUDIO ROUTING',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                        color: AppColors.purple,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      outputDevice,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton.icon(
                onPressed: () async {
                  await showModalBottomSheet<void>(
                    context: context,
                    showDragHandle: true,
                    builder: (context) => OutputDeviceSheet(
                      selected: outputDevice,
                      onSelected: (value) {
                        setState(() => outputDevice = value);
                        Navigator.of(context).pop();
                      },
                    ),
                  );
                },
                icon: const Icon(Icons.tune, size: 16),
                label: const Text('Change'),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // Information card
        AppCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.library_books_outlined,
                size: 44,
                color: isDark ? AppColors.purpleMid : AppColors.purple,
              ),
              const SizedBox(height: 12),
              Text(
                'Document Audio Ready',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'When you capture a document on the Home tab and tap "Process", your synthesized audio and AI summary will play through your selected audio device ($outputDevice).',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
