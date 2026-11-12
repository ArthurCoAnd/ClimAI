import 'dart:convert';

import 'package:http/http.dart' as http;

class WeatherApiException implements Exception {
  const WeatherApiException(this.message);

  final String message;

  @override
  String toString() => 'WeatherApiException: $message';
}

/// GETs [uri] and decodes a JSON object, mapping every failure to
/// [WeatherApiException].
Future<Map<String, dynamic>> getJson(http.Client client, Uri uri) async {
  try {
    final response = await client.get(uri).timeout(const Duration(seconds: 15));
    if (response.statusCode != 200) {
      throw WeatherApiException('HTTP ${response.statusCode}');
    }
    return jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
  } on WeatherApiException {
    rethrow;
  } catch (e) {
    throw WeatherApiException('$e');
  }
}

/// Runs a JSON-to-model [parse], mapping malformed payloads to
/// [WeatherApiException].
T parseOrThrow<T>(T Function() parse) {
  try {
    return parse();
  } catch (e) {
    throw WeatherApiException('$e');
  }
}
