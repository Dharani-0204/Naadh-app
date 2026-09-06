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

  Map<String, dynamic>? _lastCapture;

  @override
  Stream<ReaderConnectionStatus> get status => _controller.stream;

  Map<String, dynamic>? get lastCapture => _lastCapture;

  @override
  Future<void> connect() async {
    _controller.add(ReaderConnectionStatus.connecting);

    try {
      final data = await _apiService.getStatus();

      if (data['status'] == 'AVAILABLE') {
        _controller.add(ReaderConnectionStatus.disconnected);
      } else {
        _controller.add(ReaderConnectionStatus.disconnected);
      }
    } catch (_) {
      _controller.add(ReaderConnectionStatus.disconnected);
    }
  }

  Future<void> startSession(String userName) async {
    _controller.add(ReaderConnectionStatus.connecting);

    try {
      final result = await _apiService.startSession(userName);

      if (result['success'] == true) {
        _controller.add(ReaderConnectionStatus.connected);
      } else {
        _controller.add(ReaderConnectionStatus.disconnected);

        throw Exception(
          result['message'] ?? 'Failed to start session',
        );
      }
    } catch (e) {
      _controller.add(ReaderConnectionStatus.disconnected);
      rethrow;
    }
  }

  @override
  Future<void> disconnect() async {
    _controller.add(ReaderConnectionStatus.disconnected);
  }

  @override
  Future<void> capture() async {
    final result = await _apiService.captureImage();

    if (result['success'] != true) {
      throw Exception(
        result['message'] ?? 'Failed to capture image',
      );
    }

    _lastCapture = result;
  }

  @override
  Future<void> finishScan() async {}

  @override
  Future<List<String>> getFiles() async {
    try {
      final data = await _apiService.getCaptures();

      final captures = data['captures'] as List<dynamic>? ?? [];

      return captures
          .map(
            (capture) => _apiService.getFullUrl(
              capture['image_url'] as String?,
            ),
          )
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<Map<String, dynamic>?> getCaptureDetails(
    int pageNumber,
  ) async {
    try {
      return await _apiService.getCaptureDetails(pageNumber);
    } catch (_) {
      return null;
    }
  }

  String getFullUrl(String? path) {
    return _apiService.getFullUrl(path);
  }

  Future<void> endSession() async {
    await _apiService.endSession();
    _controller.add(ReaderConnectionStatus.disconnected);
  }

  void dispose() {
    _apiService.dispose();
    _controller.close();
  }
}
