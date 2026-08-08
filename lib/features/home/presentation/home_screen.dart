import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/responsive.dart';
import '../../../features/device/domain/reader_device.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/connection_status_chip.dart';
import '../../../shared/widgets/document_card.dart';
import '../widgets/home_camera_placeholder.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.status,
    required this.onCapture,
    required this.onFinish,
    required this.pageCount,
  });

  final ReaderConnectionStatus status;
  final VoidCallback onCapture;
  final VoidCallback onFinish;
  final int pageCount;

  @override
  Widget build(BuildContext context) {
    final pad = Responsive.adaptivePadding(context);
    return ListView(
      padding: EdgeInsets.all(pad),
      children: [
        Row(
          children: [
            ConnectionStatusChip(status: status),
            const Spacer(),
            Text(
              '$pageCount page${pageCount == 1 ? '' : 's'}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        AspectRatio(aspectRatio: 3 / 4, child: const HomeCameraPlaceholder()),
        const SizedBox(height: AppSpacing.md),
        AppCard(
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: status == ReaderConnectionStatus.connected
                      ? onCapture
                      : null,
                  icon: const Icon(Icons.camera_alt_outlined),
                  label: const Text('Capture'),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: FilledButton.icon(
                  onPressed: pageCount > 0 ? onFinish : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.orange,
                  ),
                  icon: const Icon(Icons.done),
                  label: const Text('Finish'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        const DocumentCard(
          title: 'Document Scanning Interface',
          description:
              'Multi-page controls, page thumbnails, and scan controls are scaffolded in UI-only mode for this stage.',
        ),
      ],
    );
  }
}
