import 'data/api/forecast_api.dart';
import 'data/api/geocoding_api.dart';
import 'state/favorites_controller.dart';

/// Dependencies shared by the screens, created once in `main`.
class AppServices {
  const AppServices({
    required this.favorites,
    required this.geocodingApi,
    required this.forecastApi,
  });

  final FavoritesController favorites;
  final GeocodingApi geocodingApi;
  final ForecastApi forecastApi;
}
