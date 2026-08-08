import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../shared/models/document_output.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/mock_audio_player.dart';

class DocumentResultsScreen extends StatelessWidget {
  const DocumentResultsScreen({super.key, required this.output});

  final DocumentOutput output;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Document Results'),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.copy_outlined)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.share_outlined)),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _TextBlock(title: 'Original Text', text: output.originalText),
          const SizedBox(height: AppSpacing.md),
          _TextBlock(title: 'Summary Text', text: output.summaryText),
          const SizedBox(height: AppSpacing.md),
          MockAudioPlayer(
            title: 'Original Audio',
            duration: output.originalAudioDuration,
            outputTarget: 'Phone Speaker',
          ),
          const SizedBox(height: AppSpacing.md),
          MockAudioPlayer(
            title: 'Summary Audio',
            duration: output.summaryAudioDuration,
            outputTarget: 'Phone Speaker',
          ),
          const SizedBox(height: AppSpacing.md),
          FilledButton.icon(
            onPressed: () =>
                Navigator.of(context).popUntil((route) => route.isFirst),
            icon: const Icon(Icons.save_outlined),
            label: const Text('Save & Return Home'),
          ),
        ],
      ),
    );
  }
}

class _TextBlock extends StatelessWidget {
  const _TextBlock({required this.title, required this.text});

  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(text),
        ],
      ),
    );
  }
}
