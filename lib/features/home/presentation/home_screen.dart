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
    required this.onCapture,
    required this.onFinish,
    required this.pageCount,
    this.onDeletePage,
  });

  final ReaderConnectionStatus status;
  final VoidCallback onCapture;
  final VoidCallback onFinish;
  final int pageCount;
  final VoidCallback? onDeletePage;

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

    return Container(
      color: Colors.white, // White background for the visual Home screen layout
      child: ListView(
        padding: EdgeInsets.all(pad),
        children: [
          // Camera Preview Area
          AspectRatio(
            aspectRatio: 3 / 4,
            child: HomeCameraPlaceholder(status: widget.status),
          ),
          const SizedBox(height: AppSpacing.xl),

          // Multi-page Scanning Section Info Header
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

          // Scanning empty state or page list visualizer
          widget.pageCount == 0 ? _buildEmptyState() : _buildPageThumbnailsList(),
          const SizedBox(height: AppSpacing.xl),

          // Action Controls Footer
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: widget.status == ReaderConnectionStatus.connected
                      ? widget.onCapture
                      : null,
                  icon: const Icon(Icons.camera_alt_outlined, size: 20),
                  label: const Text('Capture'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.purple,
                    disabledForegroundColor: AppColors.gray,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: AppColors.purple, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppShapes.buttonRadius),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: FilledButton.icon(
                  onPressed: widget.pageCount > 0 ? widget.onFinish : null,
                  icon: const Icon(Icons.check, size: 20),
                  label: const Text('Finish'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.orange,
                    disabledBackgroundColor: AppColors.gray.withValues(alpha: 0.5),
                    foregroundColor: Colors.white,
                    disabledForegroundColor: Colors.white70,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppShapes.buttonRadius),
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
            Icons.filter_none_outlined, // Document pages icon
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
            'Tap ‘Capture’ to start scanning',
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
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.orange.withValues(alpha: 0.12),
                          blurRadius: 4,
                          spreadRadius: 1,
                        )
                      ]
                    : null,
              ),
              child: Stack(
                children: [
                  // Mock lines representation
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.article_outlined,
                          size: 16,
                          color: isSelected ? AppColors.orange : AppColors.purpleMid,
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
                              color: isSelected ? AppColors.orange : AppColors.charcoal,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Delete button in top-right
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
