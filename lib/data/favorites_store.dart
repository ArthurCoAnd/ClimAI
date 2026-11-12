import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'models/city.dart';

/// Persists the favorite municipalities on the device.
class FavoritesStore {
  static const _key = 'favorites_v1';

  Future<List<City>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return [];
    try {
      return [
        for (final item in jsonDecode(raw) as List)
          City.fromJson(item as Map<String, dynamic>),
      ];
    } catch (_) {
      // Corrupt data: start over rather than crash on launch.
      return [];
    }
  }

  Future<void> save(List<City> cities) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode([for (final c in cities) c.toJson()]),
    );
  }
}
