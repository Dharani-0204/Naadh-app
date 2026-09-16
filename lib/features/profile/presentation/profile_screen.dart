import 'dart:io';

import 'package:flutter/material.dart';

import '../../../core/constants/pi_config.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../features/device/domain/reader_device.dart';
import '../../../features/document/data/services/document_storage_service.dart';
import '../../../shared/widgets/app_card.dart';

/// Profile screen — displays real user, device, and usage information.
///
/// All values come from:
/// - [userName] / [status] / [pageCount] passed from [AppShell]
/// - [DocumentStorageService] for saved document stats
/// - [PiConfig] for the Raspberry Pi IP address
///
/// Pull down to refresh usage statistics.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
    this.userName,
    this.status = ReaderConnectionStatus.disconnected,
    this.pageCount = 0,
    this.sessionActive = false,
    this.onDisconnect,
  });

  /// The display name entered by the user at session start.
  final String? userName;

  /// Current Pi connection status.
  final ReaderConnectionStatus status;

  /// Number of pages captured in the current session.
  final int pageCount;

  /// Whether a Pi session is currently active.
  final bool sessionActive;

  /// Callback to end the Pi session and disconnect.
  final VoidCallback? onDisconnect;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _storage = DocumentStorageService();

  int _savedDocCount = 0;
  int _storageTotalBytes = 0;
  bool _statsLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  // ─── Load real usage stats ────────────────────────────────────────

  Future<void> _loadStats() async {
    setState(() => _statsLoading = true);
    try {
      final docs = await _storage.loadAllDocuments();
      int totalBytes = 0;

      for (final doc in docs) {
        final paths = [
          doc.imagePath,
          doc.originalTextPath,
          doc.originalPdfPath,
          doc.summaryTextPath,
          doc.summaryPdfPath,
          doc.originalAudioPath,
          doc.summaryAudioPath,
        ];
        for (final path in paths) {
          if (path == null) continue;
          final f = File(path);
          if (await f.exists()) {
            totalBytes += await f.length();
          }
        }
      }

      if (mounted) {
        setState(() {
          _savedDocCount = docs.length;
          _storageTotalBytes = totalBytes;
          _statsLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _statsLoading = false);
    }
  }

  // ─── Helpers ──────────────────────────────────────────────────────

  /// Extracts just the host (IP) from [PiConfig.baseUrl].
  String get _piIpAddress {
    try {
      return Uri.parse(PiConfig.baseUrl).host;
    } catch (_) {
      return PiConfig.baseUrl;
    }
  }

  String _formatBytes(int bytes) {
    if (bytes == 0) return '0 MB';
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String get _statusLabel {
    switch (widget.status) {
      case ReaderConnectionStatus.connected:
        return 'Connected';
      case ReaderConnectionStatus.connecting:
        return 'Connecting…';
      case ReaderConnectionStatus.busy:
        return 'Processing';
      case ReaderConnectionStatus.disconnected:
        return 'Not Connected';
    }
  }

  Color get _statusColor {
    switch (widget.status) {
      case ReaderConnectionStatus.connected:
        return Colors.green.shade600;
      case ReaderConnectionStatus.connecting:
      case ReaderConnectionStatus.busy:
        return Colors.orange.shade600;
      case ReaderConnectionStatus.disconnected:
        return Colors.red.shade400;
    }
  }

  // ─── Build ────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadStats,
      color: AppColors.purple,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── User / Profile Card ───────────────────────────────────
          AppCard(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: AppColors.purple.withValues(alpha: 0.12),
                  child: const Icon(
                    Icons.person_outline,
                    size: 38,
                    color: AppColors.purple,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  widget.userName?.isNotEmpty == true
                      ? widget.userName!
                      : 'Guest',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    _statusLabel,
                    style: TextStyle(
                      color: _statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // ── Device Information ────────────────────────────────────
          AppCard(
            child: _InfoSection(
              title: 'Device Information',
              icon: Icons.memory_outlined,
              rows: [
                _InfoRow(
                  label: 'Device',
                  value: 'Raspberry Pi Alien Reader',
                ),
                _InfoRow(
                  label: 'IP Address',
                  value: _piIpAddress,
                ),
                _InfoRow(
                  label: 'Status',
                  value: _statusLabel,
                  valueColor: _statusColor,
                ),
                _InfoRow(
                  label: 'Session',
                  value: widget.sessionActive ? 'Active' : 'Inactive',
                  valueColor: widget.sessionActive
                      ? Colors.green.shade600
                      : Colors.black54,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // ── Usage ─────────────────────────────────────────────────
          AppCard(
            child: _InfoSection(
              title: 'Usage',
              icon: Icons.bar_chart_outlined,
              trailing: _statsLoading
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 1.5,
                        color: AppColors.purpleMid,
                      ),
                    )
                  : null,
              rows: [
                _InfoRow(
                  label: 'Documents Saved',
                  value: '$_savedDocCount',
                ),
                _InfoRow(
                  label: 'Pages Scanned',
                  value: '${widget.pageCount}',
                ),
                _InfoRow(
                  label: 'Storage Used',
                  value: _statsLoading ? '…' : _formatBytes(_storageTotalBytes),
                ),
              ],
            ),
          ),
          if (widget.onDisconnect != null) ...[
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: widget.onDisconnect,
                icon: const Icon(Icons.link_off),
                label: const Text('DISCONNECT FROM DEVICE'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red.shade600,
                  side: BorderSide(color: Colors.red.shade300),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.sm),

          // ── Pull to refresh hint ───────────────────────────────────
          const Center(
            child: Text(
              'Pull down to refresh stats',
              style: TextStyle(fontSize: 11, color: Colors.black38),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Info section card body
// ─────────────────────────────────────────────────────────────────────────────

class _InfoSection extends StatelessWidget {
  const _InfoSection({
    required this.title,
    required this.icon,
    required this.rows,
    this.trailing,
  });

  final String title;
  final IconData icon;
  final List<_InfoRow> rows;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            Icon(icon, size: 18, color: AppColors.purpleMid),
            const SizedBox(width: 8),
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            if (trailing != null) ...[
              const Spacer(),
              trailing!,
            ],
          ],
        ),
        const Divider(height: 20),
        // Rows
        ...rows.map(
          (row) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 120,
                  child: Text(
                    row.label,
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 13,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    row.value,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: row.valueColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Single labeled row
// ─────────────────────────────────────────────────────────────────────────────

class _InfoRow {
  const _InfoRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;
}
