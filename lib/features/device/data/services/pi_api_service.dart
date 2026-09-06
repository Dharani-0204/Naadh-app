import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../core/constants/pi_config.dart';

class PiApiService {
  final http.Client _client;

  PiApiService({http.Client? client})
      : _client = client ?? http.Client();

  Future<Map<String, dynamic>> getStatus() async {
    final uri = Uri.parse('${PiConfig.baseUrl}/status');

    final response = await _client
        .get(uri)
        .timeout(PiConfig.connectionTimeout);

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to get device status: ${response.statusCode}',
      );
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> startSession(String displayName) async {
    final uri = Uri.parse('${PiConfig.baseUrl}/session/start');

    final response = await _client
        .post(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode({
            'display_name': displayName,
          }),
        )
        .timeout(PiConfig.connectionTimeout);

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to start session: '
        '${response.statusCode} ${response.body}',
      );
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> captureImage() async {
    final uri = Uri.parse('${PiConfig.baseUrl}/capture');

    final response = await _client
        .post(
          uri,
          headers: {
            'Accept': 'application/json',
          },
        )
        .timeout(const Duration(seconds: 60));

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to capture image: '
        '${response.statusCode} ${response.body}',
      );
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getCaptureDetails(
    int pageNumber,
  ) async {
    final uri = Uri.parse(
      '${PiConfig.baseUrl}/capture/$pageNumber',
    );

    final response = await _client
        .get(uri)
        .timeout(PiConfig.connectionTimeout);

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to get capture details: '
        '${response.statusCode} ${response.body}',
      );
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getCaptures() async {
    final uri = Uri.parse('${PiConfig.baseUrl}/captures');

    final response = await _client
        .get(uri)
        .timeout(PiConfig.connectionTimeout);

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to get captures: '
        '${response.statusCode} ${response.body}',
      );
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  String getFullUrl(String? path) {
    if (path == null || path.isEmpty) {
      return '';
    }

    if (path.startsWith('http')) {
      return path;
    }

    return '${PiConfig.baseUrl}$path';
  }

  Future<void> endSession() async {
    final uri = Uri.parse('${PiConfig.baseUrl}/session/end');

    await _client
        .post(uri)
        .timeout(PiConfig.connectionTimeout);
  }

  void dispose() {
    _client.close();
  }
}