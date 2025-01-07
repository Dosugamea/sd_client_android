import 'dart:convert';

import 'package:http/http.dart' as http;

class StableDiffusionService {
  static const String baseUrl = 'http://127.0.0.1:7860';

  Future<void> setModel(String modelName) async {
    try {
      await http.post(
        Uri.parse('$baseUrl/sdapi/v1/options'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'sd_model_checkpoint': modelName,
        }),
      );
    } catch (e) {
      throw Exception('Failed to set model: $e');
    }
  }
}
