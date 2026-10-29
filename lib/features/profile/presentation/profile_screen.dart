import 'dart:io';

import 'package:flutter/material.dart';

import '../../../app/router.dart';
import '../../../core/constants/pi_config.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/theme_controller.dart';
import '../../../features/auth/data/models/user_account.dart';
import '../../../features/auth/data/services/auth_service.dart';
import '../../../features/device/domain/reader_device.dart';
import '../../../features/document/data/services/document_storage_service.dart';
import '../../../shared/widgets/app_card.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
    this.userName,
    this.status = ReaderConnectionStatus.disconnected,
    this.pageCount = 0,
    this.sessionActive = false,
    this.onDisconnect,
    this.onSignOut,
  });

  final String? userName;
  final ReaderConnectionStatus status;
  final int pageCount;
  final bool sessionActive;
  final VoidCallback? onDisconnect;
  final VoidCallback? onSignOut;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _storage = DocumentStorageService();
  final _authService = AuthService();

  int _savedDocCount = 0;
  int _storageTotalBytes = 0;
  bool _statsLoading = true;
  UserAccount? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadStats();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await _authService.getCurrentUser();
    if (mounted) {
      setState(() => _currentUser = user);
    }
  }

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
    } catch (_) {
      if (mounted) setState(() => _statsLoading = false);
    }
  }

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
        return 'App Active';
      case ReaderConnectionStatus.disconnected:
        return 'Not Connected';
    }
  }

  Color get _statusColor {
    switch (widget.status) {
      case ReaderConnectionStatus.connected:
        return AppColors.success;
      case ReaderConnectionStatus.connecting:
      case ReaderConnectionStatus.busy:
        return AppColors.orange;
      case ReaderConnectionStatus.disconnected:
        return AppColors.danger;
    }
  }

  void _showThemeSelector() {
    final current = ThemeController.instance.themeMode;
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Appearance & Theme',
                  style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.brightness_auto),
                  title: const Text('System Default'),
                  subtitle: const Text('Matches your phone display settings'),
                  trailing: current == ThemeMode.system
                      ? const Icon(Icons.check, color: AppColors.purple)
                      : null,
                  onTap: () async {
                    await ThemeController.instance.setThemeMode(ThemeMode.system);
                    if (ctx.mounted) Navigator.pop(ctx);
                    setState(() {});
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.light_mode_outlined),
                  title: const Text('Light Theme'),
                  subtitle: const Text('Clean white background with purple accents'),
                  trailing: current == ThemeMode.light
                      ? const Icon(Icons.check, color: AppColors.purple)
                      : null,
                  onTap: () async {
                    await ThemeController.instance.setThemeMode(ThemeMode.light);
                    if (ctx.mounted) Navigator.pop(ctx);
                    setState(() {});
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.dark_mode_outlined),
                  title: const Text('Dark Theme'),
                  subtitle: const Text('Charcoal background with purple accents'),
                  trailing: current == ThemeMode.dark
                      ? const Icon(Icons.check, color: AppColors.purple)
                      : null,
                  onTap: () async {
                    await ThemeController.instance.setThemeMode(ThemeMode.dark);
                    if (ctx.mounted) Navigator.pop(ctx);
                    setState(() {});
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSignOutDialog() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text(
          'Are you sure you want to sign out? You will need to log in again to access Naadh.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CANCEL'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              widget.onSignOut?.call();
            },
            child: const Text('SIGN OUT'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final onSurface = theme.colorScheme.onSurface;

    final themeModeTitle = switch (ThemeController.instance.themeMode) {
      ThemeMode.system => 'System Default',
      ThemeMode.light => 'Light Theme',
      ThemeMode.dark => 'Dark Theme',
    };

    return RefreshIndicator(
      onRefresh: () async {
        await _loadStats();
        await _loadUser();
      },
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
                  backgroundColor: isDark
                      ? AppColors.purpleDarkTint
                      : AppColors.purpleLightTint,
                  child: const Icon(
                    Icons.person_outline,
                    size: 38,
                    color: AppColors.purple,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _currentUser?.username ??
                      (widget.userName?.isNotEmpty == true
                          ? widget.userName!
                          : 'Guest'),
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (_currentUser?.email != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    _currentUser!.email!,
                    style: TextStyle(
                      color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                      fontSize: 13,
                    ),
                  ),
                ],
                if (_currentUser?.phone != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    _currentUser!.phone!,
                    style: TextStyle(
                      color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                      fontSize: 13,
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: _statusColor.withValues(alpha: 0.3),
                    ),
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

          // ── Appearance / Theme Setting Card ───────────────────────
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.palette_outlined,
                      size: 20,
                      color: isDark ? AppColors.purpleMid : AppColors.purple,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Appearance',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 20),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    isDark ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
                    color: AppColors.purple,
                  ),
                  title: const Text('Theme Mode'),
                  subtitle: Text(themeModeTitle),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _showThemeSelector,
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
                _InfoRow(label: 'Device', value: 'Raspberry Pi Naadh Reader'),
                _InfoRow(label: 'Host / IP', value: _piIpAddress),
                _InfoRow(
                  label: 'Status',
                  value: _statusLabel,
                  valueColor: _statusColor,
                ),
                _InfoRow(
                  label: 'Hardware Control',
                  value: widget.sessionActive ? 'App Controlled' : 'Standalone Mode',
                  valueColor: widget.sessionActive
                      ? AppColors.success
                      : (isDark ? AppColors.darkTextMuted : Colors.black54),
                ),
              ],
              bottomAction: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(
                        context,
                      ).pushNamed(AppRoutes.deviceQrScanner);
                    },
                    icon: const Icon(Icons.qr_code_scanner, size: 18),
                    label: const Text('ADD DEVICE (QR SETUP)'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.purple,
                      side: const BorderSide(color: AppColors.purple),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // ── Usage ─────────────────────────────────────────────────
          AppCard(
            child: _InfoSection(
              title: 'Usage & Storage',
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
                _InfoRow(label: 'Documents Saved', value: '$_savedDocCount'),
                _InfoRow(label: 'Pages in Session', value: '${widget.pageCount}'),
                _InfoRow(
                  label: 'Storage Used',
                  value: _statsLoading ? '…' : _formatBytes(_storageTotalBytes),
                ),
              ],
            ),
          ),

          // ── Device Disconnect Button (if connected) ───────────────
          if (widget.onDisconnect != null && widget.sessionActive) ...[
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: widget.onDisconnect,
                icon: const Icon(Icons.link_off),
                label: const Text('DISCONNECT FROM DEVICE'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.danger,
                  side: const BorderSide(color: AppColors.danger),
                ),
              ),
            ),
          ],

          // ── Sign Out Button ───────────────────────────────────────
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              onPressed: _showSignOutDialog,
              icon: const Icon(Icons.logout),
              label: const Text('LOG OUT OF ACCOUNT'),
              style: OutlinedButton.styleFrom(
                foregroundColor: isDark ? AppColors.darkTextMuted : AppColors.charcoal,
                side: BorderSide(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.lg),
          Center(
            child: Text(
              'Pull down to refresh stats • Version 1.0.0',
              style: TextStyle(
                fontSize: 12,
                color: onSurface.withValues(alpha: 0.5),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  const _InfoSection({
    required this.title,
    required this.icon,
    required this.rows,
    this.trailing,
    this.bottomAction,
  });

  final String title;
  final IconData icon;
  final List<_InfoRow> rows;
  final Widget? trailing;
  final Widget? bottomAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: isDark ? AppColors.purpleMid : AppColors.purple),
            const SizedBox(width: 8),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            if (trailing != null) ...[const Spacer(), trailing!],
          ],
        ),
        const Divider(height: 20),
        ...rows.map(
          (row) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 130,
                  child: Text(
                    row.label,
                    style: TextStyle(
                      color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
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
                      color: row.valueColor ?? (isDark ? AppColors.darkText : AppColors.charcoal),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        ?bottomAction,
      ],
    );
  }
}

class _InfoRow {
  const _InfoRow({required this.label, required this.value, this.valueColor});

  final String label;
  final String value;
  final Color? valueColor;
}
