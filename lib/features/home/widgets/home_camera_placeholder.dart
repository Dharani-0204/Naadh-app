import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../device/domain/reader_device.dart';

class HomeCameraPlaceholder extends StatelessWidget {
  const HomeCameraPlaceholder({super.key, required this.status});

  final ReaderConnectionStatus status;

  @override
  Widget build(BuildContext context) {
    // Determine status color and text
    final (labelText, dotColor) = switch (status) {
      ReaderConnectionStatus.connected => ('CONNECTED', AppColors.success),
      ReaderConnectionStatus.connecting => ('CONNECTING', AppColors.orange),
      ReaderConnectionStatus.disconnected => ('DISCONNECTED', AppColors.danger),
      ReaderConnectionStatus.busy => ('PROCESSING...', AppColors.purpleMid),
    };

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF121218), // Dark camera background
        borderRadius: BorderRadius.circular(20), // Rounded outer corners
        border: Border.all(
          color: AppColors.orange, // Orange border
          width: 2.0,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          children: [
            // Orange document-positioning corner guides
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.all(28.0),
                child: CustomPaint(
                  painter: CornerGuidesPainter(
                    color: AppColors.orange,
                    strokeWidth: 3.0,
                    length: 22.0,
                  ),
                ),
              ),
            ),
            // Connection indicator near the bottom
            Positioned(
              top: 12,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6), // Dark translucent pill/background
                    borderRadius: BorderRadius.circular(999),
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CornerGuidesPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double length;

  CornerGuidesPainter({
    required this.color,
    this.strokeWidth = 3.0,
    this.length = 20.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final w = size.width;
    final h = size.height;

    // Top-Left corner
    canvas.drawLine(const Offset(0, 0), Offset(length, 0), paint);
    canvas.drawLine(const Offset(0, 0), Offset(0, length), paint);

    // Top-Right corner
    canvas.drawLine(Offset(w, 0), Offset(w - length, 0), paint);
    canvas.drawLine(Offset(w, 0), Offset(w, length), paint);

    // Bottom-Left corner
    canvas.drawLine(Offset(0, h), Offset(length, h), paint);
    canvas.drawLine(Offset(0, h), Offset(0, h - length), paint);

    // Bottom-Right corner
    canvas.drawLine(Offset(w, h), Offset(w - length, h), paint);
    canvas.drawLine(Offset(w, h), Offset(w, h - length), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
