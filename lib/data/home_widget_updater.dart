import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Asks the Android home screen widget ("Próximas 8 horas") to refresh.
///
/// Each widget reads its chosen municipality (picked when it is added) on its
/// own; the app only signals that the favorites changed. See `.specs/05-widget-android.md`.
abstract interface class HomeWidgetUpdater {
  /// Picks the platform implementation: Android gets the channel, every other
  /// platform (web included) a no-op.
  factory HomeWidgetUpdater.forPlatform() =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android
      ? ChannelHomeWidgetUpdater()
      : const NoopHomeWidgetUpdater();

  Future<void> refresh();
}

class NoopHomeWidgetUpdater implements HomeWidgetUpdater {
  const NoopHomeWidgetUpdater();

  @override
  Future<void> refresh() async {}
}

class ChannelHomeWidgetUpdater implements HomeWidgetUpdater {
  ChannelHomeWidgetUpdater([
    this._channel = const MethodChannel('climai/home_widget'),
  ]);

  final MethodChannel _channel;

  @override
  Future<void> refresh() async {
    try {
      await _channel.invokeMethod<void>('refresh');
    } on MissingPluginException {
      // No native side (e.g. tests): nothing to refresh.
    } on PlatformException {
      // The widget is best effort; never break the favorites flow.
    }
  }
}
