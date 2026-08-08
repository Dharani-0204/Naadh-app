import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/document_card.dart';
import '../../../shared/widgets/mock_audio_player.dart';
import '../widgets/output_device_sheet.dart';

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
        MockAudioPlayer(
          title: 'Original Audio',
          duration: mockOutput.originalAudioDuration,
          outputTarget: outputDevice,
        ),
        const SizedBox(height: AppSpacing.md),
        MockAudioPlayer(
          title: 'Summary Audio',
          duration: mockOutput.summaryAudioDuration,
          outputTarget: outputDevice,
        ),
        const SizedBox(height: AppSpacing.md),
        const DocumentCard(
          title: 'Original Text',
          description:
              'The transition from classical physics to modern physics introduced quantization and probabilistic models.',
        ),
        const SizedBox(height: AppSpacing.md),
        const DocumentCard(
          title: 'Summary Text',
          description:
              'A concise summary of generated content is shown here for quick review and listening workflows.',
        ),
      ],
    );
  }
}
