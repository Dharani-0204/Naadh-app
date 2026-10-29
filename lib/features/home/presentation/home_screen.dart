import 'package:flutter/material.dart';

import '../../../app/router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shapes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/responsive.dart';
import '../../../features/device/domain/reader_device.dart';
import '../../../shared/widgets/app_card.dart';
import '../widgets/home_camera_placeholder.dart';
import 'full_screen_camera_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.status,
    required this.onConnect,
    required this.onCapture,
    required this.onFinish,
    required this.pageCount,
    this.onDisconnect,
    this.onDeletePage,
    this.ocrFailureMessage,
    this.userName,
    this.onOpenFiles,
    this.onOpenSettings,
    this.onOpenProfile,
  });

  final ReaderConnectionStatus status;
  final VoidCallback onConnect;
  final VoidCallback? onDisconnect;
  final VoidCallback onCapture;
  final VoidCallback onFinish;
  final int pageCount;
  final VoidCallback? onDeletePage;
  final String? ocrFailureMessage;
  final String? userName;
  final VoidCallback? onOpenFiles;
  final VoidCallback? onOpenSettings;
  final VoidCallback? onOpenProfile;

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

  void _openFullScreenCamera() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => FullScreenCameraScreen(
          status: widget.status,
          onCapture: widget.onCapture,
        ),
      ),
    );
  }

  void _showPagePreview(int pageIndex) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog<void>(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor:
              isDark ? AppColors.darkSurfaceElevated : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppShapes.cardRadius),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Page ${pageIndex + 1} Preview',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () => Navigator.of(ctx).pop(),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  height: 220,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.black26 : AppColors.cloud,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark
                          ? AppColors.darkBorder
                          : AppColors.lightBorder,
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.article_rounded,
                          size: 56,
                          color: isDark ? AppColors.purpleMid : AppColors.purple,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Page ${pageIndex + 1} Captured',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Ready for OCR processing',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? AppColors.darkTextMuted
                                : AppColors.lightTextMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (widget.onDeletePage != null)
                      TextButton.icon(
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          widget.onDeletePage!();
                        },
                        icon: const Icon(Icons.delete_outline,
                            size: 18, color: AppColors.danger),
                        label: const Text(
                          'Delete Page',
                          style: TextStyle(color: AppColors.danger),
                        ),
                      ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.purple,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppShapes.buttonRadius),
                        ),
                      ),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final pad = Responsive.adaptivePadding(context);
    final screenHeight = MediaQuery.of(context).size.height;
    final cameraHeight = (screenHeight * 0.42).clamp(230.0, 360.0);

    final isDeviceReady =
        widget.status == ReaderConnectionStatus.connected ||
        widget.status == ReaderConnectionStatus.busy;
    final isConnecting = widget.status == ReaderConnectionStatus.connecting;

    final (statusLabel, statusColor, statusIcon) = switch (widget.status) {
      ReaderConnectionStatus.connected => (
        'Connected',
        AppColors.success,
        Icons.check_circle_rounded
      ),
      ReaderConnectionStatus.busy => (
        'Busy',
        AppColors.purpleMid,
        Icons.sync_rounded
      ),
      ReaderConnectionStatus.connecting => (
        'Connecting...',
        AppColors.orange,
        Icons.autorenew_rounded
      ),
      ReaderConnectionStatus.disconnected => (
        'Disconnected',
        AppColors.danger,
        Icons.cloud_off_rounded
      ),
    };

    return ListView(
      padding: EdgeInsets.symmetric(horizontal: pad, vertical: 12),
      children: [
        // ── 1. Wi-Fi Setup / Device Pairing (First Main Section) ──────
        _buildWifiSetupCard(context, isDark),

        const SizedBox(height: AppSpacing.md),

        // ── 2. Live Camera Heading & Status Pill ─────────────────────
        _buildCameraHeader(context, isDark, statusLabel, statusColor, statusIcon),

        const SizedBox(height: 8),

        // ── 3. Live Camera Preview (Main Focus, ~40-50% screen height) ─
        _buildCameraPreview(cameraHeight),

        const SizedBox(height: AppSpacing.sm),

        // ── 4. Compact Connect to Device Control ─────────────────────
        _buildConnectionControl(isDark, isDeviceReady, isConnecting),

        const SizedBox(height: AppSpacing.md),

        // ── 5. Capture Page & Process Buttons ─────────────────────────
        _buildCaptureAndProcessControls(isDark, isDeviceReady),

        // OCR Failure Warning Banner (if present)
        if (widget.ocrFailureMessage != null) ...[
          const SizedBox(height: AppSpacing.sm),
          _buildOcrFailureBanner(),
        ],

        const SizedBox(height: AppSpacing.lg),

        // ── 6. Compact Captured Pages Thumbnail Strip ────────────────
        _buildCapturedPagesSection(context, isDark),

        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 1. WI-FI SETUP / DEVICE PAIRING CARD (First Section below App Bar)
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildWifiSetupCard(BuildContext context, bool isDark) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: isDark ? AppColors.darkSurfaceElevated : Colors.white,
      borderColor: isDark
          ? AppColors.purpleMid.withValues(alpha: 0.35)
          : AppColors.purple.withValues(alpha: 0.25),
      onTap: () {
        Navigator.of(context).pushNamed(AppRoutes.deviceQrScanner);
      },
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.purpleDarkTint
                  : AppColors.purpleLightTint,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.qr_code_scanner_rounded,
              color: AppColors.purple,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        'Connect via Wi-Fi / Scan QR',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14.5,
                          color: isDark ? Colors.white : AppColors.purple,
                          letterSpacing: -0.2,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(
                      Icons.wifi_rounded,
                      size: 16,
                      color: AppColors.purpleMid,
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  'Scan your Naadh device QR to connect or configure Wi-Fi',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: isDark
                        ? AppColors.darkTextMuted
                        : AppColors.lightTextMuted,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            Icons.arrow_forward_ios_rounded,
            color: isDark ? AppColors.purpleMid : AppColors.purple,
            size: 16,
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 2. LIVE CAMERA HEADING & STATUS PILL
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildCameraHeader(
    BuildContext context,
    bool isDark,
    String statusLabel,
    Color statusColor,
    IconData statusIcon,
  ) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Live Camera',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 16,
            letterSpacing: -0.2,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: statusColor.withValues(alpha: 0.3),
              width: 1.0,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(statusIcon, color: statusColor, size: 12),
              const SizedBox(width: 5),
              Text(
                statusLabel,
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 11.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 3. LIVE CAMERA PREVIEW (~40-50% Content Area)
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildCameraPreview(double cameraHeight) {
    return SizedBox(
      height: cameraHeight,
      width: double.infinity,
      child: HomeCameraPlaceholder(
        status: widget.status,
        onToggleFullScreen: _openFullScreenCamera,
        onConnect: widget.onConnect,
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 4. COMPACT CONNECT TO DEVICE CONTROL
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildConnectionControl(
    bool isDark,
    bool isDeviceReady,
    bool isConnecting,
  ) {
    if (!isDeviceReady) {
      return SizedBox(
        width: double.infinity,
        height: 44,
        child: FilledButton.icon(
          onPressed: isConnecting ? null : widget.onConnect,
          icon: isConnecting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.wifi_tethering_rounded, size: 18),
          label: Text(
            isConnecting ? 'Connecting to Device...' : 'Connect to Device',
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              letterSpacing: 0.3,
            ),
          ),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.purple,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppShapes.buttonRadius),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceElevated : Colors.white,
        borderRadius: BorderRadius.circular(AppShapes.buttonRadius),
        border: Border.all(
          color: AppColors.success.withValues(alpha: 0.35),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle_rounded,
            color: AppColors.success,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Connected to Naadh Reader',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: isDark ? AppColors.darkText : AppColors.charcoal,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (widget.onDisconnect != null)
            InkWell(
              onTap: widget.onDisconnect,
              borderRadius: BorderRadius.circular(6),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.link_off_rounded,
                      size: 14,
                      color: AppColors.danger,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Disconnect',
                      style: TextStyle(
                        color: AppColors.danger,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 5. CAPTURE PAGE & PROCESS BUTTONS
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildCaptureAndProcessControls(bool isDark, bool isDeviceReady) {
    return Row(
      children: [
        // Capture Page Button
        Expanded(
          child: SizedBox(
            height: 48,
            child: OutlinedButton.icon(
              onPressed: isDeviceReady ? widget.onCapture : null,
              icon: const Icon(Icons.camera_alt_outlined, size: 20),
              label: const Text(
                'Capture Page',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.purple,
                disabledForegroundColor:
                    isDark ? Colors.white24 : AppColors.gray,
                side: BorderSide(
                  color: isDeviceReady
                      ? AppColors.purple
                      : (isDark ? Colors.white12 : AppColors.gray),
                  width: 1.5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppShapes.buttonRadius),
                ),
              ),
            ),
          ),
        ),

        const SizedBox(width: 12),

        // Process Document Button
        Expanded(
          child: SizedBox(
            height: 48,
            child: FilledButton.icon(
              onPressed: widget.pageCount > 0 ? widget.onFinish : null,
              icon: const Icon(Icons.auto_awesome_rounded, size: 20),
              label: const Text(
                'Process',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.orange,
                disabledBackgroundColor: isDark
                    ? Colors.white12
                    : AppColors.gray.withValues(alpha: 0.4),
                foregroundColor: Colors.white,
                disabledForegroundColor: Colors.white38,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppShapes.buttonRadius),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // OCR FAILURE BANNER
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildOcrFailureBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.danger.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.danger.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: AppColors.danger,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              widget.ocrFailureMessage!,
              style: const TextStyle(
                color: AppColors.danger,
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 6. COMPACT CAPTURED PAGES THUMBNAIL STRIP (Adobe Scan Inspired)
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildCapturedPagesSection(BuildContext context, bool isDark) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Captured Pages',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 15,
                letterSpacing: -0.2,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
              decoration: BoxDecoration(
                color: widget.pageCount > 0
                    ? AppColors.purple.withValues(alpha: 0.12)
                    : (isDark ? Colors.white10 : AppColors.cloud),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '${widget.pageCount} ${widget.pageCount == 1 ? 'Page' : 'Pages'}',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 11.5,
                  color: widget.pageCount > 0
                      ? AppColors.purple
                      : (isDark
                          ? AppColors.darkTextMuted
                          : AppColors.lightTextMuted),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        widget.pageCount == 0
            ? _buildEmptyPagesState(isDark)
            : _buildHorizontalThumbnailsStrip(isDark),
      ],
    );
  }

  Widget _buildEmptyPagesState(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurfaceElevated.withValues(alpha: 0.5)
            : AppColors.cloud.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(AppShapes.cardRadius),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 1.0,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.document_scanner_outlined,
            size: 18,
            color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
          ),
          const SizedBox(width: 8),
          Text(
            'No pages captured yet',
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalThumbnailsStrip(bool isDark) {
    return SizedBox(
      height: 94,
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
              _showPagePreview(index);
            },
            child: Container(
              width: 76,
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurfaceElevated : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected
                      ? AppColors.orange
                      : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                  width: isSelected ? 2.0 : 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(7),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.article_outlined,
                          size: 18,
                          color: isSelected
                              ? AppColors.orange
                              : (isDark
                                  ? AppColors.purpleMid
                                  : AppColors.purple),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          height: 3,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white12
                                : AppColors.gray.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(height: 3),
                        Container(
                          height: 3,
                          width: 38,
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white12
                                : AppColors.gray.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const Spacer(),
                        Center(
                          child: Text(
                            'Page ${index + 1}',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: isSelected
                                  ? AppColors.orange
                                  : (isDark
                                      ? AppColors.darkText
                                      : AppColors.charcoal),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Delete Page Button
                  if (widget.onDeletePage != null)
                    Positioned(
                      top: 2,
                      right: 2,
                      child: GestureDetector(
                        onTap: () {
                          widget.onDeletePage!();
                        },
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: const BoxDecoration(
                            color: AppColors.danger,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            size: 9,
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
