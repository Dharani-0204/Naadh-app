/// Status of device onboarding/configuration.
enum DeviceSetupStatus {
  /// Scanned and identified, but Wi-Fi provisioning not yet performed.
  identifiedNotConfigured,

  /// Wi-Fi credentials transfer/provisioning in progress.
  provisioningPending,

  /// Successfully configured on local network.
  configured,
}

/// Status of device authentication/pairing with the account or cloud.
enum DevicePairingStatus {
  /// Discovered or identified locally, not paired to user account.
  unpaired,

  /// Pairing exchange in progress.
  pairing,

  /// Authenticated and paired.
  paired,
}

/// Minimal model representing a known Naadh device.
///
/// NOTE: Sensitive credentials (such as Wi-Fi passwords or API secret keys)
/// must NEVER be stored in plain model storage or unencrypted SharedPreferences.
class SavedDevice {
  /// Stable device serial or identifier, e.g. "NAADH-000123".
  final String deviceId;

  /// Optional friendly display name assigned by the user.
  final String? displayName;

  /// Optional last known local IP or mDNS hostname (e.g. "drpi2copy1.local").
  final String? lastKnownAddress;

  /// Current onboarding/setup status.
  final DeviceSetupStatus setupStatus;

  /// Current pairing status.
  final DevicePairingStatus pairingStatus;

  /// When this device was first scanned/added on this phone.
  final DateTime createdAt;

  /// Last time this device was seen or queried.
  final DateTime? lastSeenAt;

  const SavedDevice({
    required this.deviceId,
    this.displayName,
    this.lastKnownAddress,
    this.setupStatus = DeviceSetupStatus.identifiedNotConfigured,
    this.pairingStatus = DevicePairingStatus.unpaired,
    required this.createdAt,
    this.lastSeenAt,
  });

  SavedDevice copyWith({
    String? deviceId,
    String? displayName,
    String? lastKnownAddress,
    DeviceSetupStatus? setupStatus,
    DevicePairingStatus? pairingStatus,
    DateTime? createdAt,
    DateTime? lastSeenAt,
  }) {
    return SavedDevice(
      deviceId: deviceId ?? this.deviceId,
      displayName: displayName ?? this.displayName,
      lastKnownAddress: lastKnownAddress ?? this.lastKnownAddress,
      setupStatus: setupStatus ?? this.setupStatus,
      pairingStatus: pairingStatus ?? this.pairingStatus,
      createdAt: createdAt ?? this.createdAt,
      lastSeenAt: lastSeenAt ?? this.lastSeenAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'device_id': deviceId,
      'display_name': displayName,
      'last_known_address': lastKnownAddress,
      'setup_status': setupStatus.name,
      'pairing_status': pairingStatus.name,
      'created_at': createdAt.toIso8601String(),
      'last_seen_at': lastSeenAt?.toIso8601String(),
    };
  }

  factory SavedDevice.fromJson(Map<String, dynamic> json) {
    return SavedDevice(
      deviceId: json['device_id'] as String,
      displayName: json['display_name'] as String?,
      lastKnownAddress: json['last_known_address'] as String?,
      setupStatus: DeviceSetupStatus.values.firstWhere(
        (e) => e.name == json['setup_status'],
        orElse: () => DeviceSetupStatus.identifiedNotConfigured,
      ),
      pairingStatus: DevicePairingStatus.values.firstWhere(
        (e) => e.name == json['pairing_status'],
        orElse: () => DevicePairingStatus.unpaired,
      ),
      createdAt:
          DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now(),
      lastSeenAt: json['last_seen_at'] != null
          ? DateTime.tryParse(json['last_seen_at'] as String)
          : null,
    );
  }
}
