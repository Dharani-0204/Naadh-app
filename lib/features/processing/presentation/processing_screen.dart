import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/app_card.dart';

class ProcessingScreen extends StatefulWidget {
  const ProcessingScreen({super.key, required this.onCompleted});

  final VoidCallback onCompleted;

  @override
  State<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends State<ProcessingScreen> {
  static const states = <String>[
    'Captured',
    'Reading document',
    'Extracting text',
    'Generating summary',
    'Generating audio',
    'Ready',
  ];

  int currentStep = 0;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(milliseconds: 900), (timer) {
      if (currentStep >= states.length - 1) {
        timer.cancel();
        widget.onCompleted();
        return;
      }
      setState(() => currentStep++);
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Processing')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Processing document',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 10),
                LinearProgressIndicator(
                  value: (currentStep + 1) / states.length,
                ),
                const SizedBox(height: AppSpacing.md),
                ...states.asMap().entries.map((entry) {
                  final index = entry.key;
                  final text = entry.value;
                  final done = index <= currentStep;
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      done ? Icons.check_circle : Icons.radio_button_unchecked,
                      color: done ? Colors.green : Colors.black38,
                    ),
                    title: Text(text),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
