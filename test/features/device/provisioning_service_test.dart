import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:alien_reader_app/features/device/data/models/provisioning_models.dart';
import 'package:alien_reader_app/features/device/data/models/saved_device.dart';
import 'package:alien_reader_app/features/device/data/services/device_storage_service.dart';
import 'package:alien_reader_app/features/device/data/services/pi_api_service.dart';

void main() {
  group('PiApiService Provisioning Endpoints', () {
    test(
      'getSetupStatus parses status response and identifies mock mode',
      () async {
        final mockClient = MockClient((request) async {
          expect(request.url.path, equals('/api/setup/status'));
          return http.Response(
            jsonEncode({
              'device_id': 'NAADH-000123',
              'is_provisioned': false,
              'setup_state': 'READY_FOR_SETUP',
              'network_state': {
                'connected': false,
                'current_ssid': null,
                'ip_address': null,
                'mode': 'AP',
              },
              'auth_required': true,
              'live_mutations_enabled': false,
              'backend': 'MOCK',
              'mock_mode': true,
              'transport_security': {'scheme': 'http', 'encrypted': false},
            }),
            200,
          );
        });

        final service = PiApiService(client: mockClient);
        final status = await service.getSetupStatus();

        expect(status.deviceId, equals('NAADH-000123'));
        expect(status.isProvisioned, isFalse);
        expect(status.setupState, equals('READY_FOR_SETUP'));
        expect(status.isMockMode, isTrue);
        expect(status.isUnsupportedBackend, isFalse);
        expect(status.networkState.connected, isFalse);
        expect(status.transportSecurity.encrypted, isFalse);
      },
    );

    test(
      'getSetupStatus detects unsupported network manager backend',
      () async {
        final mockClient = MockClient((request) async {
          return http.Response(
            jsonEncode({
              'device_id': 'NAADH-000123',
              'is_provisioned': false,
              'setup_state': 'UNSUPPORTED',
              'network_state': {'connected': false},
              'auth_required': true,
              'live_mutations_enabled': true,
              'backend': 'UNSUPPORTED',
              'mock_mode': false,
              'transport_security': {'scheme': 'http', 'encrypted': false},
            }),
            200,
          );
        });

        final service = PiApiService(client: mockClient);
        final status = await service.getSetupStatus();

        expect(status.isUnsupportedBackend, isTrue);
        expect(status.backend, equals('UNSUPPORTED'));
      },
    );

    test(
      'createSetupSession authenticates successfully and extracts token',
      () async {
        final mockClient = MockClient((request) async {
          expect(request.url.path, equals('/api/setup/session'));
          final body = jsonDecode(request.body) as Map<String, dynamic>;
          expect(body['setup_secret'], equals('test-pin-1234'));

          return http.Response(
            jsonEncode({'token': 'mock-session-token-abc', 'expires_in': 900}),
            200,
          );
        });

        final service = PiApiService(client: mockClient);
        final session = await service.createSetupSession('test-pin-1234');

        expect(session.token, equals('mock-session-token-abc'));
        expect(session.expiresIn, equals(900));
      },
    );

    test('createSetupSession throws SetupAuthException on HTTP 401', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({'detail': 'Invalid setup secret'}),
          401,
        );
      });

      final service = PiApiService(client: mockClient);
      expect(
        () => service.createSetupSession('wrong-secret'),
        throwsA(isA<SetupAuthException>()),
      );
    });

    test(
      'createSetupSession throws SetupRateLimitException on HTTP 429',
      () async {
        final mockClient = MockClient((request) async {
          return http.Response(
            jsonEncode({'detail': 'Too many failed attempts'}),
            429,
          );
        });

        final service = PiApiService(client: mockClient);
        expect(
          () => service.createSetupSession('spam-secret'),
          throwsA(isA<SetupRateLimitException>()),
        );
      },
    );

    test(
      'getAvailableNetworks transmits bearer token and parses network list',
      () async {
        final mockClient = MockClient((request) async {
          expect(request.url.path, equals('/api/setup/networks'));
          expect(
            request.headers['Authorization'],
            equals('Bearer valid-token-xyz'),
          );

          return http.Response(
            jsonEncode({
              'networks': [
                {
                  'ssid': 'Home-WiFi-5G',
                  'signal_strength': 85,
                  'security': 'WPA2',
                },
                {
                  'ssid': 'Public-Guest',
                  'signal_strength': 40,
                  'security': 'OPEN',
                },
              ],
            }),
            200,
          );
        });

        final service = PiApiService(client: mockClient);
        final networks = await service.getAvailableNetworks('valid-token-xyz');

        expect(networks.length, equals(2));
        expect(networks[0].ssid, equals('Home-WiFi-5G'));
        expect(networks[0].isOpen, isFalse);
        expect(networks[1].ssid, equals('Public-Guest'));
        expect(networks[1].isOpen, isTrue);
      },
    );

    test('provisionWifi submits credentials and returns response', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.path, equals('/api/setup/wifi'));
        expect(request.headers['Authorization'], equals('Bearer token-123'));

        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body['ssid'], equals('MyHomeWiFi'));
        expect(body['password'], equals('SuperSecretPassword123'));
        expect(body['hidden'], isFalse);

        return http.Response(
          jsonEncode({
            'success': true,
            'status': 'CONNECTING',
            'message': 'Wi-Fi connection attempt initiated.',
          }),
          200,
        );
      });

      final service = PiApiService(client: mockClient);
      final result = await service.provisionWifi(
        'token-123',
        ssid: 'MyHomeWiFi',
        password: 'SuperSecretPassword123',
      );

      expect(result.success, isTrue);
      expect(result.status, equals('CONNECTING'));
    });

    test(
      'getConnectionStatus parses polling state and connection details',
      () async {
        final mockClient = MockClient((request) async {
          expect(request.url.path, equals('/api/setup/connection-status'));
          expect(request.headers['Authorization'], equals('Bearer token-123'));

          return http.Response(
            jsonEncode({
              'state': 'CONNECTED',
              'ssid': 'MyHomeWiFi',
              'ip_address': '192.168.1.150',
              'internet_accessible': true,
              'error_reason': null,
              'backend': 'MOCK',
            }),
            200,
          );
        });

        final service = PiApiService(client: mockClient);
        final status = await service.getConnectionStatus('token-123');

        expect(status.state, equals('CONNECTED'));
        expect(status.isConnected, isTrue);
        expect(status.isConnecting, isFalse);
        expect(status.isFailed, isFalse);
        expect(status.ipAddress, equals('192.168.1.150'));
        expect(status.isMockMode, isTrue);
      },
    );

    test('getConnectionStatus recognizes ROLLBACK and FAILED states', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'state': 'ROLLBACK',
            'ssid': 'FailedWiFi',
            'error_reason': 'Authentication failed with access point',
            'backend': 'NetworkManager',
          }),
          200,
        );
      });

      final service = PiApiService(client: mockClient);
      final status = await service.getConnectionStatus('token-123');

      expect(status.isFailed, isTrue);
      expect(status.isRollback, isTrue);
      expect(status.isMockMode, isFalse);
    });

    test('cancelSetupSession sends POST /api/setup/cancel', () async {
      bool cancelCalled = false;
      final mockClient = MockClient((request) async {
        expect(request.url.path, equals('/api/setup/cancel'));
        expect(
          request.headers['Authorization'],
          equals('Bearer token-to-cancel'),
        );
        cancelCalled = true;
        return http.Response(
          jsonEncode({'success': true, 'message': 'Cancelled'}),
          200,
        );
      });

      final service = PiApiService(client: mockClient);
      await service.cancelSetupSession('token-to-cancel');

      expect(cancelCalled, isTrue);
    });
  });

  group('DeviceStorageService', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('saves, retrieves, and updates device setup status', () async {
      final storage = DeviceStorageService();

      final initial = SavedDevice(
        deviceId: 'NAADH-000123',
        setupStatus: DeviceSetupStatus.identifiedNotConfigured,
        createdAt: DateTime.now(),
      );

      await storage.saveDevice(initial);

      final retrieved = await storage.getDevice('NAADH-000123');
      expect(retrieved, isNotNull);
      expect(retrieved!.deviceId, equals('NAADH-000123'));
      expect(
        retrieved.setupStatus,
        equals(DeviceSetupStatus.identifiedNotConfigured),
      );

      // Update to configured
      await storage.updateDeviceSetupStatus(
        'NAADH-000123',
        DeviceSetupStatus.configured,
        lastKnownAddress: '192.168.1.150',
      );

      final updated = await storage.getDevice('NAADH-000123');
      expect(updated!.setupStatus, equals(DeviceSetupStatus.configured));
      expect(updated.lastKnownAddress, equals('192.168.1.150'));

      // Active device tracking
      await storage.setActiveDeviceId('NAADH-000123');
      expect(await storage.getActiveDeviceId(), equals('NAADH-000123'));

      // Remove device
      await storage.removeDevice('NAADH-000123');
      expect(await storage.getDevice('NAADH-000123'), isNull);
      expect(await storage.getActiveDeviceId(), isNull);
    });
  });
}
