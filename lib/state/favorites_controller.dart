import 'package:flutter/foundation.dart';

import '../data/api/forecast_api.dart';
import '../data/favorites_store.dart';
import '../data/home_widget_updater.dart';
import '../data/models/city.dart';
import '../data/models/weather.dart';

/// Current-weather state of one favorite card.
class CityWeatherState {
  const CityWeatherState.loading() : weather = null, hasError = false;
  const CityWeatherState.error() : weather = null, hasError = true;
  const CityWeatherState.data(CurrentWeather this.weather) : hasError = false;

  final CurrentWeather? weather;
  final bool hasError;

  bool get isLoading => weather == null && !hasError;
}

/// Favorites list plus the current weather of each favorite.
class FavoritesController extends ChangeNotifier {
  FavoritesController({
    required this.store,
    required this.forecastApi,
    this.homeWidget = const NoopHomeWidgetUpdater(),
  });

  final FavoritesStore store;
  final ForecastApi forecastApi;

  /// Refreshed after every change, since widgets show favorites.
  final HomeWidgetUpdater homeWidget;

  final List<City> _favorites = [];
  final Map<int, CityWeatherState> _weather = {};
  bool _loaded = false;

  List<City> get favorites => List.unmodifiable(_favorites);

  /// False until the persisted favorites have been read.
  bool get loaded => _loaded;

  bool isFavorite(City city) => _favorites.contains(city);

  CityWeatherState weatherOf(City city) =>
      _weather[city.id] ?? const CityWeatherState.loading();

  Future<void> load() async {
    _favorites
      ..clear()
      ..addAll(await store.load());
    _loaded = true;
    notifyListeners();
    await refreshAll();
  }

  Future<void> refreshAll() => Future.wait(_favorites.map(refresh));

  Future<void> refresh(City city) async {
    // Keep showing the previous reading while refreshing.
    if (_weather[city.id]?.weather == null) {
      _weather[city.id] = const CityWeatherState.loading();
      notifyListeners();
    }
    CityWeatherState next;
    try {
      next = CityWeatherState.data(await forecastApi.fetchCurrent(city));
    } catch (_) {
      next = const CityWeatherState.error();
    }
    // The city may have been removed while the request was in flight.
    if (!_favorites.contains(city)) return;
    _weather[city.id] = next;
    notifyListeners();
  }

  Future<void> toggle(City city) async {
    if (isFavorite(city)) {
      await remove(city);
    } else {
      await add(city);
    }
  }

  /// Adds [city]; [index] restores a removed favorite to its old position.
  Future<void> add(City city, {int? index}) async {
    if (isFavorite(city)) return;
    final at = (index ?? _favorites.length).clamp(0, _favorites.length);
    _favorites.insert(at, city);
    notifyListeners();
    await store.save(_favorites);
    await homeWidget.refresh();
    await refresh(city);
  }

  /// Removes [city] and returns the index it had, or -1 if it was not there.
  Future<int> remove(City city) async {
    final index = _favorites.indexOf(city);
    if (index < 0) return -1;
    _favorites.removeAt(index);
    _weather.remove(city.id);
    notifyListeners();
    await store.save(_favorites);
    await homeWidget.refresh();
    return index;
  }
}
