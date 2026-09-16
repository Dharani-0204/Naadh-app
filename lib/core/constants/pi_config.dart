class PiConfig {
  PiConfig._();

  /// Base URL of the FastAPI server running on the Raspberry Pi.
  /// Update this if the Pi's IP address changes.
  static const String baseUrl = 'http://192.168.1.20:8000';

  /// Live MJPEG camera stream endpoint.
  /// Returns a multipart/x-mixed-replace stream of JPEG frames.
  static String get streamUrl => '$baseUrl/camera/stream';

  /// Default timeout for short API calls (status, session, captures list).
  static const Duration connectionTimeout = Duration(seconds: 5);
}
