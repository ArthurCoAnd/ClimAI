/// A municipality returned by the Open-Meteo geocoding API.
class City {
  const City({
    required this.id,
    required this.name,
    required this.admin1,
    required this.latitude,
    required this.longitude,
  });

  factory City.fromJson(Map<String, dynamic> json) => City(
    id: (json['id'] as num).toInt(),
    name: json['name'] as String,
    admin1: (json['admin1'] as String?) ?? '',
    latitude: (json['latitude'] as num).toDouble(),
    longitude: (json['longitude'] as num).toDouble(),
  );

  final int id;
  final String name;

  /// State (UF) name, e.g. "Minas Gerais". Empty when unknown.
  final String admin1;
  final double latitude;
  final double longitude;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'admin1': admin1,
    'latitude': latitude,
    'longitude': longitude,
  };

  @override
  bool operator ==(Object other) => other is City && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
