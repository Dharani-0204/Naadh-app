import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../models/document_output.dart';
import 'app_card.dart';

class MockAudioPlayer extends StatelessWidget {
  const MockAudioPlayer({
    super.key,
    required this.title,
    required this.duration,
    required this.outputTarget,
  });

  final String title;
  final Duration duration;
  final String outputTarget;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            'Output: $outputTarget',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.black54),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const CircleAvatar(
                backgroundColor: AppColors.purple,
                child: Icon(Icons.play_arrow, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  children: [
                    LinearProgressIndicator(
                      value: 0.35,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        _formatDuration(duration),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

String _formatDuration(Duration duration) {
  final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
  final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
  return '$minutes:$seconds';
}

const mockOutput = DocumentOutput(
  originalText:
      'The transition from classical to modern physics changed scientific understanding at a foundational level.',
  summaryText:
      'Modern physics introduced quantization and probability, replacing purely deterministic models.',
  originalAudioDuration: Duration(minutes: 18, seconds: 42),
  summaryAudioDuration: Duration(minutes: 4, seconds: 15),
);
