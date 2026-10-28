import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shapes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/responsive.dart';
import '../../../features/device/domain/reader_device.dart';
import '../widgets/home_camera_placeholder.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.status,
    required this.onConnect,
    required this.onCapture,
    required this.onFinish,
    required this.pageCount,
    this.onDeletePage,
    this.ocrFailureMessage,
  });

  final ReaderConnectionStatus status;
  final VoidCallback onConnect;
  final VoidCallback onCapture;
  final VoidCallback onFinish;
  final int pageCount;
  final VoidCallback? onDeletePage;
  final String? ocrFailureMessage;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedPageIndex = 0;

  @override
  void didUpdateWidget(covariant HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.pageCount <= _selectedPageIndex) {
      _selectedPageIndex = widget.pageCount > 0 ? widget.pageCount - 1 : 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final pad = Responsive.adaptivePadding(context);

    // Both CONNECTED and BUSY mean the Raspberry Pi is reachable.
    // BUSY happens when APP_ACTIVE is returned after starting a session.
    final isDeviceReady =
        widget.status == ReaderConnectionStatus.connected ||
        widget.status == ReaderConnectionStatus.busy;

    final isConnecting = widget.status == ReaderConnectionStatus.connecting;

    return Container(
      color: Colors.white,
      child: ListView(
        padding: EdgeInsets.all(pad),
        children: [
          AspectRatio(
            aspectRatio: 3 / 4,
            child: HomeCameraPlaceholder(status: widget.status),
          ),

          const SizedBox(height: AppSpacing.lg),

          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: isDeviceReady || isConnecting
                  ? null
                  : widget.onConnect,
              icon: Icon(isDeviceReady ? Icons.check_circle : Icons.wifi),
              label: Text(
                isConnecting
                    ? 'CONNECTING...'
                    : isDeviceReady
                    ? 'CONNECTED'
                    : 'CONNECT TO DEVICE',
              ),
              style: FilledButton.styleFrom(
                backgroundColor: isDeviceReady
                    ? AppColors.success
                    : AppColors.purple,
                disabledBackgroundColor: isDeviceReady
                    ? AppColors.success
                    : AppColors.gray.withValues(alpha: 0.5),
                foregroundColor: Colors.white,
                disabledForegroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppShapes.buttonRadius),
                ),
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.xl),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Multi-page Scanning',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppColors.charcoal,
                ),
              ),
              Text(
                '${widget.pageCount} Page${widget.pageCount == 1 ? '' : 's'}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.purpleMid,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          widget.pageCount == 0
              ? _buildEmptyState()
              : _buildPageThumbnailsList(),

          if (widget.ocrFailureMessage != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.danger.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.danger.withValues(alpha: 0.5),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: AppColors.danger,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.ocrFailureMessage!,
                      style: const TextStyle(
                        color: AppColors.danger,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
          ],

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: isDeviceReady ? widget.onCapture : null,
                  icon: const Icon(Icons.camera_alt_outlined, size: 20),
                  label: const Text('Capture'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.purple,
                    disabledForegroundColor: AppColors.gray,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: AppColors.purple, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppShapes.buttonRadius,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: AppSpacing.md),

              Expanded(
                child: FilledButton.icon(
                  onPressed: widget.pageCount > 0 ? widget.onFinish : null,
                  icon: const Icon(Icons.check, size: 20),
                  label: const Text('Process'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.orange,
                    disabledBackgroundColor: AppColors.gray.withValues(
                      alpha: 0.5,
                    ),
                    foregroundColor: Colors.white,
                    disabledForegroundColor: Colors.white70,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppShapes.buttonRadius,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 36),
      decoration: BoxDecoration(
        color: AppColors.cloud.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(AppShapes.cardRadius),
        border: Border.all(color: AppColors.gray, width: 0.6),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.filter_none_outlined,
            size: 36,
            color: Colors.black38,
          ),
          const SizedBox(height: 12),
          Text(
            'No pages captured yet',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 15,
              color: AppColors.charcoal,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Connect to the device and tap Capture',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.black54,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageThumbnailsList() {
    return SizedBox(
      height: 110,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: widget.pageCount,
        itemBuilder: (context, index) {
          final isSelected = index == _selectedPageIndex;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedPageIndex = index;
              });
            },
            child: Container(
              width: 80,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? AppColors.orange : AppColors.gray,
                  width: isSelected ? 2.5 : 1,
                ),
              ),
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.article_outlined,
                          size: 16,
                          color: isSelected
                              ? AppColors.orange
                              : AppColors.purpleMid,
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 4,
                          color: AppColors.gray.withValues(alpha: 0.5),
                          width: double.infinity,
                        ),
                        const SizedBox(height: 4),
                        Container(
                          height: 4,
                          color: AppColors.gray.withValues(alpha: 0.5),
                          width: 44,
                        ),
                        const Spacer(),
                        Center(
                          child: Text(
                            'Page ${index + 1}',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? AppColors.orange
                                  : AppColors.charcoal,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 2,
                    right: 2,
                    child: GestureDetector(
                      onTap: () {
                        widget.onDeletePage?.call();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: AppColors.danger,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          size: 10,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
