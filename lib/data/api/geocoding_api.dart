import 'package:http/http.dart' as http;

import '../models/city.dart';
import 'api_exception.dart';

class GeocodingApi {
  GeocodingApi(this._client);

  final http.Client _client;

  /// Searches Brazilian municipalities by name.
  Future<List<City>> search(String query) async {
    final uri = Uri.https('geocoding-api.open-meteo.com', '/v1/search', {
      'name': query,
      'count': '20',
      'language': 'pt',
      'countryCode': 'BR',
      'format': 'json',
    });
    final json = await getJson(_client, uri);
    return parseOrThrow(
      () => [
        for (final r in (json['results'] as List?) ?? const [])
          City.fromJson(r as Map<String, dynamic>),
      ],
    );
  }
}
