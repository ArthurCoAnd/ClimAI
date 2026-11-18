import 'dart:convert';

import 'package:clim_ai/data/api/forecast_api.dart';
import 'package:clim_ai/data/favorites_store.dart';
import 'package:clim_ai/data/home_widget_updater.dart';
import 'package:clim_ai/state/favorites_controller.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fixtures.dart';

class _CountingUpdater implements HomeWidgetUpdater {
  int calls = 0;

  @override
  Future<void> refresh() async => calls++;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  FavoritesController controller(HomeWidgetUpdater updater) {
    final client = MockClient(
      (_) async =>
          http.Response.bytes(utf8.encode(jsonEncode(currentJson())), 200),
    );
    return FavoritesController(
      store: FavoritesStore(),
      forecastApi: ForecastApi(client),
      homeWidget: updater,
    );
  }

  test('refreshes the home widget when favorites change', () async {
    SharedPreferences.setMockInitialValues({});
    final updater = _CountingUpdater();
    final favorites = controller(updater);
    await favorites.load();
    expect(updater.calls, 0);

    await favorites.add(beloHorizonte);
    expect(updater.calls, 1);

    await favorites.toggle(beloHorizonte);
    expect(updater.calls, 2);

    // Removing something that is not a favorite changes nothing.
    await favorites.remove(beloHorizonte);
    expect(updater.calls, 2);
  });

  test('saves favorites before the widget reads them', () async {
    SharedPreferences.setMockInitialValues({});
    late List<String> savedNames;
    final favorites = controller(
      _CallbackUpdater(() async {
        savedNames = [for (final c in await FavoritesStore().load()) c.name];
      }),
    );
    await favorites.load();
    await favorites.add(beloHorizonte);
    expect(savedNames, ['Belo Horizonte']);
  });

  test('channel updater ignores a missing native side', () async {
    const channel = MethodChannel('climai/home_widget_test');
    await ChannelHomeWidgetUpdater(channel).refresh();
  });

  test('channel updater calls "refresh" on the native side', () async {
    const channel = MethodChannel('climai/home_widget_test');
    final calls = <String>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          calls.add(call.method);
          return null;
        });
    addTearDown(
      () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null),
    );

    await ChannelHomeWidgetUpdater(channel).refresh();
    expect(calls, ['refresh']);
  });
}

class _CallbackUpdater implements HomeWidgetUpdater {
  _CallbackUpdater(this._onRefresh);

  final Future<void> Function() _onRefresh;

  @override
  Future<void> refresh() => _onRefresh();
}
