/// Exceptions for setup & provisioning operations.
class SetupAuthException implements Exception {
  final String message;
  const SetupAuthException([
    this.message = 'Authentication failed. Invalid setup PIN or secret.',
  ]);
  @override
  String toString() => message;
}

class SetupRateLimitException implements Exception {
  final String message;
  const SetupRateLimitException([
    this.message =
        'Too many failed attempts. The device is temporarily locked out. Please wait and try again.',
  ]);
  @override
  String toString() => message;
}

class SetupNetworkException implements Exception {
  final String message;
  const SetupNetworkException(this.message);
  @override
  String toString() => message;
}

class SetupUnsupportedBackendException implements Exception {
  final String message;
  const SetupUnsupportedBackendException([
    this.message =
        'The device network backend is unsupported for live provisioning.',
  ]);
  @override
  String toString() => message;
}

/// Transport security metadata reported by the Raspberry Pi.
class TransportSecurityInfo {
  final String scheme;
  final bool encrypted;

  const TransportSecurityInfo({required this.scheme, required this.encrypted});

  factory TransportSecurityInfo.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const TransportSecurityInfo(scheme: 'http', encrypted: false);
    }
    return TransportSecurityInfo(
      scheme: (json['scheme'] as String?) ?? 'http',
      encrypted: (json['encrypted'] as bool?) ?? false,
    );
  }
}

/// Network state of the Raspberry Pi.
class NetworkStateInfo {
  final bool connected;
  final String? currentSsid;
  final String? ipAddress;
  final String? mode;

  const NetworkStateInfo({
    required this.connected,
    this.currentSsid,
    this.ipAddress,
    this.mode,
  });

  factory NetworkStateInfo.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const NetworkStateInfo(connected: false);
    }
    return NetworkStateInfo(
      connected: (json['connected'] as bool?) ?? false,
      currentSsid: json['current_ssid'] as String?,
      ipAddress: json['ip_address'] as String?,
      mode: json['mode'] as String?,
    );
  }
}

/// Represents the response from `GET /api/setup/status`.
class SetupStatusModel {
  final String deviceId;
  final bool isProvisioned;
  final String setupState;
  final NetworkStateInfo networkState;
  final bool authRequired;
  final bool liveMutationsEnabled;
  final String backend;
  final bool mockMode;
  final TransportSecurityInfo transportSecurity;

  const SetupStatusModel({
    required this.deviceId,
    required this.isProvisioned,
    required this.setupState,
    required this.networkState,
    required this.authRequired,
    required this.liveMutationsEnabled,
    required this.backend,
    required this.mockMode,
    required this.transportSecurity,
  });

  /// True when the device backend is running in mock/simulated mode.
  bool get isMockMode =>
      mockMode || backend.toUpperCase() == 'MOCK' || !liveMutationsEnabled;

  /// True when the Linux networking tool is missing or unsupported.
  bool get isUnsupportedBackend => backend.toUpperCase() == 'UNSUPPORTED';

  factory SetupStatusModel.fromJson(Map<String, dynamic> json) {
    return SetupStatusModel(
      deviceId: (json['device_id'] as String?) ?? '',
      isProvisioned: (json['is_provisioned'] as bool?) ?? false,
      setupState: (json['setup_state'] as String?) ?? 'UNKNOWN',
      networkState: NetworkStateInfo.fromJson(
        json['network_state'] as Map<String, dynamic>?,
      ),
      authRequired: (json['auth_required'] as bool?) ?? true,
      liveMutationsEnabled: (json['live_mutations_enabled'] as bool?) ?? false,
      backend: (json['backend'] as String?) ?? 'MOCK',
      mockMode: (json['mock_mode'] as bool?) ?? true,
      transportSecurity: TransportSecurityInfo.fromJson(
        json['transport_security'] as Map<String, dynamic>?,
      ),
    );
  }
}

/// Represents the response from `POST /api/setup/session`.
class SetupSessionModel {
  final String token;
  final int? expiresIn;

  const SetupSessionModel({required this.token, this.expiresIn});

  factory SetupSessionModel.fromJson(Map<String, dynamic> json) {
    final token =
        (json['token'] ?? json['session_token'] ?? json['access_token'])
            as String? ??
        '';
    final expiresIn =
        (json['expires_in'] as int?) ??
        (json['expires_at'] != null
            ? (json['expires_at'] as num).toInt()
            : null);
    return SetupSessionModel(token: token, expiresIn: expiresIn);
  }
}

/// Represents a scanned Wi-Fi network from `GET /api/setup/networks`.
class WifiNetworkInfo {
  final String ssid;
  final int signalStrength;
  final String security;

  const WifiNetworkInfo({
    required this.ssid,
    required this.signalStrength,
    required this.security,
  });

  bool get isOpen =>
      security.toUpperCase() == 'OPEN' || security.toUpperCase() == 'NONE';

  factory WifiNetworkInfo.fromJson(Map<String, dynamic> json) {
    return WifiNetworkInfo(
      ssid: (json['ssid'] as String?) ?? '',
      signalStrength: (json['signal_strength'] as int?) ?? 0,
      security: (json['security'] as String?) ?? 'WPA2',
    );
  }
}

/// Represents the response from `POST /api/setup/wifi`.
class WifiProvisionResponseModel {
  final bool success;
  final String status;
  final String message;

  const WifiProvisionResponseModel({
    required this.success,
    required this.status,
    required this.message,
  });

  factory WifiProvisionResponseModel.fromJson(Map<String, dynamic> json) {
    return WifiProvisionResponseModel(
      success: (json['success'] as bool?) ?? false,
      status: (json['status'] as String?) ?? '',
      message: (json['message'] as String?) ?? '',
    );
  }
}

/// Represents the real-time polling response from `GET /api/setup/connection-status`.
class ConnectionStatusModel {
  final String state;
  final String? ssid;
  final String? ipAddress;
  final bool internetAccessible;
  final String? errorReason;
  final String backend;

  const ConnectionStatusModel({
    required this.state,
    this.ssid,
    this.ipAddress,
    this.internetAccessible = false,
    this.errorReason,
    this.backend = 'MOCK',
  });

  bool get isConnecting => state.toUpperCase() == 'CONNECTING';

  bool get isConnected => state.toUpperCase() == 'CONNECTED';

  bool get isFailed =>
      state.toUpperCase() == 'FAILED' ||
      state.toUpperCase() == 'TIMEOUT' ||
      state.toUpperCase() == 'ROLLBACK';

  bool get isRollback => state.toUpperCase() == 'ROLLBACK';

  bool get isMockMode => backend.toUpperCase() == 'MOCK';

  factory ConnectionStatusModel.fromJson(Map<String, dynamic> json) {
    return ConnectionStatusModel(
      state: (json['state'] as String?) ?? 'UNKNOWN',
      ssid: json['ssid'] as String?,
      ipAddress: json['ip_address'] as String?,
      internetAccessible: (json['internet_accessible'] as bool?) ?? false,
      errorReason: json['error_reason'] as String?,
      backend: (json['backend'] as String?) ?? 'MOCK',
    );
  }
}
