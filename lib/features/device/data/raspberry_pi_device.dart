import 'dart:async';

import '../domain/reader_device.dart';
import 'services/pi_api_service.dart';

class RaspberryPiDevice implements ReaderDevice {
  RaspberryPiDevice({
    PiApiService? apiService,
  }) : _apiService = apiService ?? PiApiService();

  final PiApiService _apiService;

  final StreamController<ReaderConnectionStatus> _controller =
      StreamController<ReaderConnectionStatus>.broadcast();

  @override
  Stream<ReaderConnectionStatus> get status => _controller.stream;

  @override
  Future<void> connect() async {
    _controller.add(ReaderConnectionStatus.connecting);

    try {
      final data = await _apiService.getStatus();
      final deviceStatus = data['status'] as String?;

      if (deviceStatus == 'AVAILABLE') {
        _controller.add(ReaderConnectionStatus.connected);
      } else if (deviceStatus == 'APP_ACTIVE') {
        _controller.add(ReaderConnectionStatus.busy);
      } else {
        _controller.add(ReaderConnectionStatus.disconnected);
      }
    } catch (_) {
      _controller.add(ReaderConnectionStatus.disconnected);
    }
  }

  @override
  Future<void> disconnect() async {
    _controller.add(ReaderConnectionStatus.disconnected);
  }

  @override
  Future<void> capture() async {
    throw UnimplementedError(
      'Capture API integration is not implemented yet.',
    );
  }

  @override
  Future<void> finishScan() async {
    throw UnimplementedError(
      'Finish scan integration is not implemented yet.',
    );
  }

  @override
  Future<List<String>> getFiles() async {
    return [];
  }

  void dispose() {
    _apiService.dispose();
    _controller.close();
  }
}
