package com.arthurcoand.clim_ai.widget

import android.content.Context
import org.json.JSONArray
import org.json.JSONObject

/**
 * Which municipality each widget shows (`.specs/05-widget-android.md`).
 *
 * The favorites come from the app's SharedPreferences (`City.toJson` in Dart).
 * The city picked for a widget is copied into the widget's own preferences, so
 * the widget keeps working if that city later leaves the favorites.
 */
object WidgetCities {
    private const val FLUTTER_PREFS = "FlutterSharedPreferences"
    private const val FAVORITES_KEY = "flutter.favorites_v1"
    private const val WIDGET_PREFS = "climai_widget"

    private fun cityKey(widgetId: Int) = "city_$widgetId"

    /** Favorites in the app's order; empty when none or unreadable. */
    fun favorites(context: Context): List<WidgetCity> {
        val raw = context.getSharedPreferences(FLUTTER_PREFS, Context.MODE_PRIVATE)
            .getString(FAVORITES_KEY, null) ?: return emptyList()
        return try {
            val list = JSONArray(raw)
            (0 until list.length()).map { fromJson(list.getJSONObject(it)) }
        } catch (e: Exception) {
            emptyList()
        }
    }

    /** City chosen for [widgetId], or null when none was chosen. */
    fun chosen(context: Context, widgetId: Int): WidgetCity? {
        val raw = prefs(context).getString(cityKey(widgetId), null) ?: return null
        return try {
            fromJson(JSONObject(raw))
        } catch (e: Exception) {
            null
        }
    }

    /**
     * City shown by [widgetId]: the chosen one, else the first favorite
     * (widgets placed before the picker existed).
     */
    fun cityFor(context: Context, widgetId: Int): WidgetCity? =
        chosen(context, widgetId) ?: favorites(context).firstOrNull()

    fun choose(context: Context, widgetId: Int, city: WidgetCity) {
        prefs(context).edit().putString(cityKey(widgetId), toJson(city).toString()).apply()
    }

    fun forget(context: Context, widgetIds: IntArray) {
        val edit = prefs(context).edit()
        widgetIds.forEach { edit.remove(cityKey(it)) }
        edit.apply()
    }

    private fun prefs(context: Context) = context.getSharedPreferences(WIDGET_PREFS, Context.MODE_PRIVATE)

    private fun fromJson(json: JSONObject) = WidgetCity(
        id = json.getLong("id"),
        name = json.getString("name"),
        admin1 = json.optString("admin1", ""),
        latitude = json.getDouble("latitude"),
        longitude = json.getDouble("longitude"),
    )

    private fun toJson(city: WidgetCity) = JSONObject()
        .put("id", city.id)
        .put("name", city.name)
        .put("admin1", city.admin1)
        .put("latitude", city.latitude)
        .put("longitude", city.longitude)
}
