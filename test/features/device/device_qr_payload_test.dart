import 'package:flutter_test/flutter_test.dart';

import 'package:alien_reader_app/features/device/data/models/device_qr_payload.dart';
import 'package:alien_reader_app/features/device/data/models/saved_device.dart';

void main() {
  group('DeviceQrPayload parsing & validation', () {
    test('successfully parses standard NAADH setup QR code', () {
      const raw = 'NAADH://setup?device_id=NAADH-000123';
      final payload = DeviceQrPayload.parse(raw);

      expect(payload.deviceId, equals('NAADH-000123'));
      expect(payload.raw, equals(raw));
      expect(payload.version, isNull);
      expect(payload.model, isNull);
    });

    test('supports case-insensitive scheme', () {
      const raw = 'naadh://setup?device_id=NAADH-TEST-99';
      final payload = DeviceQrPayload.parse(raw);

      expect(payload.deviceId, equals('NAADH-TEST-99'));
    });

    test('supports alternative camelCase parameter deviceId', () {
      const raw = 'NAADH://setup?deviceId=NAADH-456';
      final payload = DeviceQrPayload.parse(raw);

      expect(payload.deviceId, equals('NAADH-456'));
    });

    test('extracts optional version and model metadata', () {
      const raw =
          'NAADH://setup?device_id=NAADH-000789&version=1.2&model=pi-zero-w&batch=2026-A';
      final payload = DeviceQrPayload.parse(raw);

      expect(payload.deviceId, equals('NAADH-000789'));
      expect(payload.version, equals('1.2'));
      expect(payload.model, equals('pi-zero-w'));
      expect(payload.additionalParams['batch'], equals('2026-A'));
    });

    test('tryParse returns valid payload or null on failure', () {
      expect(
        DeviceQrPayload.tryParse('NAADH://setup?device_id=NAADH-001'),
        isNotNull,
      );
      expect(DeviceQrPayload.tryParse('https://example.com'), isNull);
    });

    test('rejects empty and whitespace strings', () {
      expect(
        () => DeviceQrPayload.parse(''),
        throwsA(
          isA<QrPayloadException>().having(
            (e) => e.message,
            'message',
            contains('empty'),
          ),
        ),
      );
      expect(
        () => DeviceQrPayload.parse('   '),
        throwsA(isA<QrPayloadException>()),
      );
      expect(
        () => DeviceQrPayload.parse(null),
        throwsA(isA<QrPayloadException>()),
      );
    });

    test('rejects standard web HTTP / HTTPS URLs to prevent redirection', () {
      expect(
        () => DeviceQrPayload.parse(
          'https://evil-site.com/setup?device_id=NAADH-123',
        ),
        throwsA(
          isA<QrPayloadException>().having(
            (e) => e.message,
            'message',
            contains('Web URLs are not valid'),
          ),
        ),
      );

      expect(
        () => DeviceQrPayload.parse(
          'http://192.168.1.50/setup?device_id=NAADH-123',
        ),
        throwsA(isA<QrPayloadException>()),
      );
    });

    test('rejects unsupported schemes', () {
      expect(
        () => DeviceQrPayload.parse('BLUETOOTH://setup?device_id=NAADH-001'),
        throwsA(
          isA<QrPayloadException>().having(
            (e) => e.message,
            'message',
            contains('Unsupported QR code scheme'),
          ),
        ),
      );
    });

    test('rejects invalid action/path', () {
      expect(
        () => DeviceQrPayload.parse('NAADH://connect?device_id=NAADH-001'),
        throwsA(
          isA<QrPayloadException>().having(
            (e) => e.message,
            'message',
            contains('Invalid setup action'),
          ),
        ),
      );
    });

    test('rejects missing or empty device_id', () {
      expect(
        () => DeviceQrPayload.parse('NAADH://setup'),
        throwsA(
          isA<QrPayloadException>().having(
            (e) => e.message,
            'message',
            contains('Missing required parameter "device_id"'),
          ),
        ),
      );

      expect(
        () => DeviceQrPayload.parse('NAADH://setup?device_id='),
        throwsA(isA<QrPayloadException>()),
      );
    });

    test('rejects malformed device IDs with special characters or spaces', () {
      expect(
        () =>
            DeviceQrPayload.parse('NAADH://setup?device_id=INVALID DEVICE ID!'),
        throwsA(
          isA<QrPayloadException>().having(
            (e) => e.message,
            'message',
            contains('Invalid device_id format'),
          ),
        ),
      );

      expect(
        () => DeviceQrPayload.parse('NAADH://setup?device_id=;;DROP TABLE;'),
        throwsA(isA<QrPayloadException>()),
      );

      // Too short (< 3 chars)
      expect(
        () => DeviceQrPayload.parse('NAADH://setup?device_id=NA'),
        throwsA(isA<QrPayloadException>()),
      );
    });
  });

  group('SavedDevice model', () {
    test('serializes and deserializes correctly', () {
      final now = DateTime.now();
      final device = SavedDevice(
        deviceId: 'NAADH-000123',
        displayName: 'Living Room Reader',
        lastKnownAddress: 'drpi2copy1.local',
        setupStatus: DeviceSetupStatus.identifiedNotConfigured,
        pairingStatus: DevicePairingStatus.unpaired,
        createdAt: now,
      );

      final json = device.toJson();
      expect(json['device_id'], equals('NAADH-000123'));
      expect(json['setup_status'], equals('identifiedNotConfigured'));
      expect(json['pairing_status'], equals('unpaired'));

      final reconstructed = SavedDevice.fromJson(json);
      expect(reconstructed.deviceId, equals('NAADH-000123'));
      expect(reconstructed.displayName, equals('Living Room Reader'));
      expect(
        reconstructed.setupStatus,
        equals(DeviceSetupStatus.identifiedNotConfigured),
      );
      expect(reconstructed.pairingStatus, equals(DevicePairingStatus.unpaired));
    });

    test('copyWith updates properties', () {
      final device = SavedDevice(
        deviceId: 'NAADH-001',
        createdAt: DateTime.now(),
      );

      final updated = device.copyWith(
        displayName: 'Bedroom Reader',
        setupStatus: DeviceSetupStatus.configured,
      );

      expect(updated.deviceId, equals('NAADH-001'));
      expect(updated.displayName, equals('Bedroom Reader'));
      expect(updated.setupStatus, equals(DeviceSetupStatus.configured));
    });
  });
}
