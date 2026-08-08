import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class HomeCameraPlaceholder extends StatelessWidget {
  const HomeCameraPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1A1828), Color(0xFF0C0C14)],
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.orange.withValues(alpha: 0.55),
                    width: 2,
                  ),
                ),
              ),
            ),
          ),
          const Positioned(
            top: 12,
            left: 0,
            right: 0,
            child: Center(
              child: Chip(
                avatar: Icon(Icons.circle, color: AppColors.orange, size: 8),
                label: Text('ALIEN READER · LIVE (Placeholder)'),
              ),
            ),
          ),
          const Positioned(
            bottom: 14,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'Camera preview placeholder (Raspberry Pi integration pending)',
                style: TextStyle(color: Colors.white70, fontSize: 11),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
