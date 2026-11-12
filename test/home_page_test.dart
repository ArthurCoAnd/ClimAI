import 'dart:convert';

import 'package:clim_ai/app_services.dart';
import 'package:clim_ai/data/api/forecast_api.dart';
import 'package:clim_ai/data/api/geocoding_api.dart';
import 'package:clim_ai/data/favorites_store.dart';
import 'package:clim_ai/main.dart';
import 'package:clim_ai/state/favorites_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fixtures.dart';

AppServices _services({required bool forecastFails}) {
  final client = MockClient((request) async {
    if (forecastFails) return http.Response('error', 500);
    final body = request.url.queryParameters.containsKey('hourly')
        ? forecastJson()
        : currentJson();
    return http.Response.bytes(utf8.encode(jsonEncode(body)), 200);
  });
  final forecastApi = ForecastApi(client);
  return AppServices(
    favorites: FavoritesController(
      store: FavoritesStore(),
      forecastApi: forecastApi,
    ),
    geocodingApi: GeocodingApi(client),
    forecastApi: forecastApi,
  );
}

void _seedFavorites() {
  SharedPreferences.setMockInitialValues({
    'favorites_v1': jsonEncode([beloHorizonte.toJson()]),
  });
}

void main() {
  testWidgets('shows the empty state without favorites', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final services = _services(forecastFails: false);
    await services.favorites.load();

    await tester.pumpWidget(ClimAiApp(services: services));

    expect(find.textContaining('ainda não tem municípios'), findsOneWidget);
    expect(find.text('Buscar município'), findsOneWidget);
  });

  testWidgets('shows a favorite card with the current weather', (tester) async {
    _seedFavorites();
    final services = _services(forecastFails: false);
    await services.favorites.load();

    await tester.pumpWidget(ClimAiApp(services: services));

    expect(find.text('Belo Horizonte'), findsOneWidget);
    expect(find.text('Minas Gerais'), findsOneWidget);
    expect(find.text('28°'), findsOneWidget);
    expect(find.text('Parcialmente nublado'), findsOneWidget);
    expect(find.text('Umidade 64%'), findsOneWidget);
  });

  testWidgets('shows an error with retry when the weather fails', (
    tester,
  ) async {
    _seedFavorites();
    final services = _services(forecastFails: true);
    await services.favorites.load();

    await tester.pumpWidget(ClimAiApp(services: services));

    expect(find.text('Belo Horizonte'), findsOneWidget);
    expect(find.text('Não foi possível carregar'), findsOneWidget);
    expect(find.text('Tentar novamente'), findsOneWidget);
  });

  testWidgets('removing a favorite can be undone', (tester) async {
    _seedFavorites();
    final services = _services(forecastFails: false);
    await services.favorites.load();
    await tester.pumpWidget(ClimAiApp(services: services));

    await tester.tap(find.byTooltip('Remover Belo Horizonte dos favoritos'));
    await tester.pumpAndSettle();
    expect(services.favorites.favorites, isEmpty);
    expect(find.textContaining('ainda não tem municípios'), findsOneWidget);

    await tester.tap(find.text('Desfazer'));
    await tester.pumpAndSettle();
    expect(services.favorites.favorites, [beloHorizonte]);
    expect(find.text('Belo Horizonte'), findsOneWidget);
  });

  testWidgets('opens the city page with 24 hours and 7 days', (tester) async {
    _seedFavorites();
    final services = _services(forecastFails: false);
    await services.favorites.load();
    await tester.pumpWidget(ClimAiApp(services: services));

    await tester.tap(find.text('Belo Horizonte'));
    await tester.pumpAndSettle();

    expect(find.text('Próximas 24 horas'), findsOneWidget);
    expect(find.text('Agora'), findsOneWidget);
    // 23 hour labels besides "Agora" (the horizontal strip builds them all).
    expect(find.textContaining(RegExp(r'^\d\dh$')), findsNWidgets(23));

    // The page has two scrollables: the vertical list and the hourly strip.
    await tester.scrollUntilVisible(
      find.text('Amanhã'),
      200,
      scrollable: find
          .descendant(
            of: find.byType(RefreshIndicator),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    expect(find.text('Amanhã'), findsOneWidget);

    await tester.tap(find.text('Amanhã'));
    await tester.pumpAndSettle();
    expect(find.text('HORA A HORA'), findsOneWidget);
    expect(find.text('Amanhã · Quinta-feira, 12/11'), findsOneWidget);
  });
}
