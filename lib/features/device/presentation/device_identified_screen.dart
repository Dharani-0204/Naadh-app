import 'package:flutter/material.dart';

import '../../../app/router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shapes.dart';
import '../../../core/theme/app_spacing.dart';
import '../data/models/device_qr_payload.dart';

/// Screen displayed after successfully scanning and validating a Naadh device QR code.
///
/// Communicates:
/// - The detected device identifier.
/// - Clear, honest onboarding status: "Device identified — setup not completed".
/// - Explanation that Wi-Fi hotspot provisioning will be available in the next release.
/// - Accessible navigation to return to the main application or rescan.
class DeviceIdentifiedScreen extends StatelessWidget {
  const DeviceIdentifiedScreen({super.key, required this.payload});

  final DeviceQrPayload payload;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Device Setup'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.charcoal,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Back to Application',
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildProgressStepper(context),
              const SizedBox(height: AppSpacing.lg),
              _buildDeviceIdentificationCard(context),
              const SizedBox(height: AppSpacing.lg),
              _buildStatusCard(context),
              const SizedBox(height: AppSpacing.lg),
              _buildNextStepNotice(context),
              const SizedBox(height: AppSpacing.xl),
              FilledButton.icon(
                onPressed: () {
                  Navigator.of(context).pushNamed(
                    AppRoutes.wifiOnboarding,
                    arguments: payload.deviceId,
                  );
                },
                icon: const Icon(Icons.wifi),
                label: const Text('CONFIGURE WI-FI'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.purple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppShapes.buttonRadius),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.charcoal,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: AppColors.gray),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppShapes.buttonRadius),
                  ),
                ),
                child: const Text('Cancel / Return to App'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressStepper(BuildContext context) {
    final steps = [
      _StepInfo('Add Device', isComplete: true, isActive: false),
      _StepInfo('Scan QR', isComplete: true, isActive: false),
      _StepInfo('Identified', isComplete: false, isActive: true),
      _StepInfo(
        'Wi-Fi Setup',
        isComplete: false,
        isActive: false,
        isPending: true,
      ),
    ];

    return Semantics(
      label: 'Setup progress: Step 3 of 4: Device Identified',
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: AppColors.cloud.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(AppShapes.cardRadius),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: steps.asMap().entries.map((entry) {
            final idx = entry.key;
            final step = entry.value;

            return Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          radius: 14,
                          backgroundColor: step.isComplete
                              ? AppColors.success
                              : (step.isActive
                                    ? AppColors.purple
                                    : AppColors.gray),
                          child: Icon(
                            step.isComplete
                                ? Icons.check
                                : (step.isActive
                                      ? Icons.fingerprint
                                      : Icons.wifi),
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          step.title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: step.isActive
                                ? FontWeight.bold
                                : FontWeight.w500,
                            color: step.isActive
                                ? AppColors.purple
                                : AppColors.charcoal,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (idx < steps.length - 1)
                    Container(
                      width: 14,
                      height: 2,
                      color: steps[idx].isComplete
                          ? AppColors.success
                          : AppColors.gray,
                    ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildDeviceIdentificationCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppShapes.cardRadius),
        border: Border.all(
          color: AppColors.purple.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.purple.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.purple.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.qr_code_2,
              size: 48,
              color: AppColors.purple,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Device Detected',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.charcoal,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.cloud,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.gray),
            ),
            child: SelectableText(
              payload.deviceId,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
                color: AppColors.purple,
              ),
            ),
          ),
          if (payload.model != null || payload.version != null) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                if (payload.model != null)
                  Chip(
                    label: Text('Model: ${payload.model}'),
                    backgroundColor: AppColors.cloud,
                    labelStyle: const TextStyle(fontSize: 11),
                  ),
                if (payload.version != null)
                  Chip(
                    label: Text('v${payload.version}'),
                    backgroundColor: AppColors.cloud,
                    labelStyle: const TextStyle(fontSize: 11),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.orange.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppShapes.cardRadius),
        border: Border.all(color: AppColors.orange.withValues(alpha: 0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, color: AppColors.orange, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Device identified — setup not completed',
                  style: TextStyle(
                    color: AppColors.charcoal,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'The device identifier has been verified from the QR code. The device has not yet joined your Wi-Fi network and is not currently communicating with this app.',
                  style: TextStyle(
                    color: AppColors.charcoal.withValues(alpha: 0.8),
                    fontSize: 12.5,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextStepNotice(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cloud.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppShapes.cardRadius),
        border: Border.all(color: AppColors.gray),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.network_wifi,
                size: 20,
                color: AppColors.purpleMid,
              ),
              const SizedBox(width: 8),
              Text(
                'Next Step: Wi-Fi Provisioning',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.charcoal,
                ),
              ),
            ],
          ),
          const Divider(height: 20),
          const Text(
            'Authenticate with the device-specific PIN/secret printed on your reader, select your local Wi-Fi network, and securely transfer credentials to the device.',
            style: TextStyle(
              fontSize: 12.5,
              color: Colors.black54,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _StepInfo {
  final String title;
  final bool isComplete;
  final bool isActive;
  final bool isPending;

  _StepInfo(
    this.title, {
    this.isComplete = false,
    this.isActive = false,
    this.isPending = false,
  });
}
