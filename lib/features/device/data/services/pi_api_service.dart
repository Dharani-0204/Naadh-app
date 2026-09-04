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

  void dispose() {
    _client.close();
  }
}
