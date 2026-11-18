package com.arthurcoand.clim_ai

import com.arthurcoand.clim_ai.widget.HourlyWidgetProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // Lets the app refresh the home screen widget when favorites change
        // (lib/data/home_widget_updater.dart).
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "climai/home_widget")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "refresh" -> {
                        HourlyWidgetProvider.requestUpdate(applicationContext)
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
    }
}
