import 'package:http/http.dart' as http;
import 'package:material_ui/material_ui.dart';

import 'app_services.dart';
import 'core/theme/glass_theme.dart';
import 'data/api/forecast_api.dart';
import 'data/api/geocoding_api.dart';
import 'data/favorites_store.dart';
import 'state/favorites_controller.dart';
import 'ui/home/home_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final client = http.Client();
  final forecastApi = ForecastApi(client);
  final services = AppServices(
    favorites: FavoritesController(
      store: FavoritesStore(),
      forecastApi: forecastApi,
    )..load(),
    geocodingApi: GeocodingApi(client),
    forecastApi: forecastApi,
  );
  runApp(ClimAiApp(services: services));
}

class ClimAiApp extends StatelessWidget {
  const ClimAiApp({super.key, required this.services});

  final AppServices services;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ClimAI',
      debugShowCheckedModeBanner: false,
      theme: buildGlassTheme(),
      home: HomePage(services: services),
    );
  }
}
