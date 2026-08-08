import 'dart:async';

import '../domain/reader_device.dart';

class MockReaderDevice implements ReaderDevice {
  MockReaderDevice() {
    _controller.add(ReaderConnectionStatus.connecting);
    Future<void>.delayed(
      const Duration(milliseconds: 900),
      () => _controller.add(ReaderConnectionStatus.connected),
    );
  }

  final StreamController<ReaderConnectionStatus> _controller =
      StreamController<ReaderConnectionStatus>.broadcast();

  @override
  Stream<ReaderConnectionStatus> get status => _controller.stream;

  @override
  Future<void> connect() async {
    _controller.add(ReaderConnectionStatus.connecting);
    await Future<void>.delayed(const Duration(milliseconds: 700));
    _controller.add(ReaderConnectionStatus.connected);
  }

  @override
  Future<void> disconnect() async {
    _controller.add(ReaderConnectionStatus.disconnected);
  }

  @override
  Future<void> capture() async {
    _controller.add(ReaderConnectionStatus.busy);
    await Future<void>.delayed(const Duration(milliseconds: 500));
    _controller.add(ReaderConnectionStatus.connected);
  }

  @override
  Future<void> finishScan() async {
    _controller.add(ReaderConnectionStatus.busy);
    await Future<void>.delayed(const Duration(milliseconds: 600));
    _controller.add(ReaderConnectionStatus.connected);
  }

  @override
  Future<List<String>> getFiles() async {
    return <String>['Physics.pdf', 'Biology-summary.mp3', 'History-notes.txt'];
  }

  void dispose() {
    _controller.close();
  }
}
