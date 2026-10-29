import 'package:flutter/material.dart';

import '../../../core/constants/pi_config.dart';
import '../../../core/theme/app_colors.dart';
import '../../device/domain/reader_device.dart';
import '../widgets/home_camera_placeholder.dart';
import '../widgets/mjpeg_camera_view.dart';

class FullScreenCameraScreen extends StatelessWidget {
  const FullScreenCameraScreen({
    super.key,
    required this.status,
    this.onCapture,
  });

  final ReaderConnectionStatus status;
  final VoidCallback? onCapture;

  @override
  Widget build(BuildContext context) {
    final isDeviceReady = status == ReaderConnectionStatus.connected ||
        status == ReaderConnectionStatus.busy;

    final (labelText, dotColor) = switch (status) {
      ReaderConnectionStatus.connected => ('CONNECTED', AppColors.success),
      ReaderConnectionStatus.connecting => ('CONNECTING', AppColors.orange),
      ReaderConnectionStatus.disconnected => ('DISCONNECTED', AppColors.danger),
      ReaderConnectionStatus.busy => ('PROCESSING...', AppColors.purpleMid),
    };

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // ── Full-screen Live MJPEG camera feed ───────────────────
            Positioned.fill(
              child: Center(
                child: AspectRatio(
                  aspectRatio: 3 / 4,
                  child: MjpegCameraView(
                    streamUrl: PiConfig.streamUrl,
                    active: isDeviceReady,
                  ),
                ),
              ),
            ),

            // ── Corner guides overlay ────────────────────────────────
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: CustomPaint(
                  painter: CornerGuidesPainter(
                    color: AppColors.orange.withValues(alpha: 0.9),
                    strokeWidth: 3.5,
                    length: 28.0,
                  ),
                ),
              ),
            ),

            // ── Top Bar: Close button & minimal status indicator ─────
            Positioned(
              top: 12,
              left: 16,
              right: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Material(
                    color: Colors.black.withValues(alpha: 0.6),
                    shape: const CircleBorder(),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      tooltip: 'Exit Full Screen',
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: dotColor.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.circle, color: dotColor, size: 8),
                        const SizedBox(width: 8),
                        Text(
                          labelText,
                          style: TextStyle(
                            color: dotColor,
                            fontWeight: FontWeight.w800,
                            fontSize: 11,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Bottom Capture Shutter Button ────────────────────────
            if (onCapture != null && isDeviceReady) ...[
              Positioned(
                bottom: 24,
                left: 0,
                right: 0,
                child: Center(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        onCapture!();
                        Navigator.of(context).pop();
                      },
                      customBorder: const CircleBorder(),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                        child: Container(
                          width: 58,
                          height: 58,
                          decoration: const BoxDecoration(
                            color: AppColors.orange,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

