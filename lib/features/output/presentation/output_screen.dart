import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/app_card.dart';
import '../widgets/output_device_sheet.dart';

/// "Output" tab — output device selector.
///
/// Results (image, text, summary) are shown in [DocumentResultsScreen]
/// after processing. This tab is reserved for output device configuration.
class OutputScreen extends StatefulWidget {
  const OutputScreen({super.key});

  @override
  State<OutputScreen> createState() => _OutputScreenState();
}

class _OutputScreenState extends State<OutputScreen> {
  String outputDevice = 'Phone Speaker';

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Output device selector
        AppCard(
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Current output: $outputDevice',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              TextButton(
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
                child: const Text('Change'),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // Empty state — results appear in DocumentResultsScreen
        Container(
          padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
          decoration: BoxDecoration(
            color: AppColors.cloud.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.gray, width: 0.6),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.library_books_outlined,
                size: 40,
                color: Colors.black38,
              ),
              const SizedBox(height: 12),
              Text(
                'No results yet',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.charcoal,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Capture a document on the Home tab,\n'
                'then tap Process to view results.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.black54,
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
