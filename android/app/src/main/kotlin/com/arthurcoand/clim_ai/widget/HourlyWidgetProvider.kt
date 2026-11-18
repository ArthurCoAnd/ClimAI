package com.arthurcoand.clim_ai.widget

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.view.View
import android.widget.RemoteViews
import com.arthurcoand.clim_ai.MainActivity
import com.arthurcoand.clim_ai.R
import org.json.JSONObject
import java.net.HttpURLConnection
import java.net.URL
import java.net.URLEncoder

/**
 * Home screen widget with the current weather and the next 8 hours of a
 * favorite municipality, picked in [HourlyWidgetConfigureActivity]
 * (`.specs/05-widget-android.md`). Fetches Open-Meteo on its own, so it
 * refreshes with the app closed (every 30 min, the platform minimum).
 */
class HourlyWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(context: Context, manager: AppWidgetManager, ids: IntArray) {
        val app = context.applicationContext
        val pending = goAsync()
        Thread {
            try {
                refresh(app, manager, ids)
            } finally {
                pending.finish()
            }
        }.start()
    }

    override fun onDeleted(context: Context, ids: IntArray) {
        val state = context.getSharedPreferences(STATE_PREFS, Context.MODE_PRIVATE).edit()
        ids.forEach { state.remove(hasDataKey(it)) }
        state.apply()
        WidgetCities.forget(context, ids)
    }

    companion object {
        private const val STATE_PREFS = "climai_widget"

        private const val CURRENT =
            "temperature_2m,relative_humidity_2m,apparent_temperature,precipitation,weather_code,is_day"
        private const val HOURLY =
            "temperature_2m,relative_humidity_2m,precipitation_probability,precipitation,weather_code,is_day"

        // Index 0 is the current hour (top row); 1..8 are the next hours.
        private val HOUR_IDS = intArrayOf(
            0, R.id.hour_1, R.id.hour_2, R.id.hour_3, R.id.hour_4,
            R.id.hour_5, R.id.hour_6, R.id.hour_7, R.id.hour_8,
        )
        private val ICON_IDS = intArrayOf(
            R.id.icon_0, R.id.icon_1, R.id.icon_2, R.id.icon_3, R.id.icon_4,
            R.id.icon_5, R.id.icon_6, R.id.icon_7, R.id.icon_8,
        )
        private val TEMP_IDS = intArrayOf(
            R.id.temp_0, R.id.temp_1, R.id.temp_2, R.id.temp_3, R.id.temp_4,
            R.id.temp_5, R.id.temp_6, R.id.temp_7, R.id.temp_8,
        )
        private val RAIN_IDS = intArrayOf(
            R.id.rain_0, R.id.rain_1, R.id.rain_2, R.id.rain_3, R.id.rain_4,
            R.id.rain_5, R.id.rain_6, R.id.rain_7, R.id.rain_8,
        )
        private val AMOUNT_IDS = intArrayOf(
            R.id.amount_0, R.id.amount_1, R.id.amount_2, R.id.amount_3, R.id.amount_4,
            R.id.amount_5, R.id.amount_6, R.id.amount_7, R.id.amount_8,
        )
        private val CELL_IDS = intArrayOf(
            R.id.cell_0, R.id.cell_1, R.id.cell_2, R.id.cell_3, R.id.cell_4,
            R.id.cell_5, R.id.cell_6, R.id.cell_7, R.id.cell_8,
        )

        /** Asks every placed widget to refresh (called by the app when favorites change). */
        fun requestUpdate(context: Context) {
            val manager = AppWidgetManager.getInstance(context)
            val ids = manager.getAppWidgetIds(ComponentName(context, HourlyWidgetProvider::class.java))
            if (ids.isNotEmpty()) context.sendBroadcast(updateIntent(context, ids))
        }

        /** Refreshes only [ids] (e.g. after picking the city of a new widget). */
        fun requestUpdate(context: Context, ids: IntArray) {
            context.sendBroadcast(updateIntent(context, ids))
        }

        private fun updateIntent(context: Context, ids: IntArray) =
            Intent(context, HourlyWidgetProvider::class.java)
                .setAction(AppWidgetManager.ACTION_APPWIDGET_UPDATE)
                .putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, ids)

        private fun hasDataKey(id: Int) = "has_data_$id"

        private fun refresh(context: Context, manager: AppWidgetManager, ids: IntArray) {
            val state = context.getSharedPreferences(STATE_PREFS, Context.MODE_PRIVATE)
            val edit = state.edit()

            // Widgets showing the same city share one request.
            ids.groupBy { WidgetCities.cityFor(context, it) }.forEach { (city, cityIds) ->
                val group = cityIds.toIntArray()
                if (city == null) {
                    group.forEach {
                        manager.updateAppWidget(it, messageViews(context, group, EMPTY_MESSAGE, retry = false))
                        edit.remove(hasDataKey(it))
                    }
                    return@forEach
                }

                // Loading only on the first fill; later refreshes keep the last reading.
                group.filterNot { state.getBoolean(hasDataKey(it), false) }.forEach {
                    manager.updateAppWidget(
                        it,
                        messageViews(context, group, context.getString(R.string.widget_loading), retry = false, title = cityLabel(city)),
                    )
                }

                val views = try {
                    val hours = parseNextHours(fetchForecast(city), WIDGET_HOURS)
                    if (hours.isEmpty()) error("sem horas")
                    hoursViews(context, city, hours)
                } catch (e: Exception) {
                    null
                }

                group.forEach { id ->
                    if (views != null) {
                        manager.updateAppWidget(id, views)
                        edit.putBoolean(hasDataKey(id), true)
                    } else {
                        manager.updateAppWidget(
                            id,
                            messageViews(context, group, "Não foi possível carregar o clima.", retry = true, title = cityLabel(city)),
                        )
                        edit.remove(hasDataKey(id))
                    }
                }
            }
            edit.apply()
        }

        private fun fetchForecast(city: WidgetCity): JSONObject {
            fun enc(value: String) = URLEncoder.encode(value, "UTF-8")
            val url = URL(
                "https://api.open-meteo.com/v1/forecast" +
                    "?latitude=${city.latitude}&longitude=${city.longitude}" +
                    "&timezone=auto&forecast_days=2" +
                    "&current=${enc(CURRENT)}&hourly=${enc(HOURLY)}",
            )
            val connection = url.openConnection() as HttpURLConnection
            try {
                connection.connectTimeout = 15_000
                connection.readTimeout = 15_000
                if (connection.responseCode != HttpURLConnection.HTTP_OK) {
                    error("HTTP ${connection.responseCode}")
                }
                val body = connection.inputStream.bufferedReader(Charsets.UTF_8).use { it.readText() }
                return JSONObject(body)
            } finally {
                connection.disconnect()
            }
        }

        private fun cityLabel(city: WidgetCity) = city.name

        private const val EMPTY_MESSAGE = "Adicione um município aos favoritos no ClimAI."

        private fun openAppIntent(context: Context): PendingIntent =
            PendingIntent.getActivity(
                context,
                0,
                Intent(context, MainActivity::class.java).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK),
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
            )

        private fun hoursViews(context: Context, city: WidgetCity, hours: List<WidgetHour>): RemoteViews {
            val views = RemoteViews(context.packageName, R.layout.hourly_widget)
            views.setOnClickPendingIntent(R.id.widget_root, openAppIntent(context))
            views.setTextViewText(R.id.city, cityLabel(city))
            views.setViewVisibility(R.id.now, View.VISIBLE)
            views.setViewVisibility(R.id.content, View.VISIBLE)
            views.setViewVisibility(R.id.message, View.GONE)
            views.setViewVisibility(R.id.retry, View.GONE)

            // Top row: current conditions with rain chance and mm.
            val now = hours[0]
            val nowIcon = weatherIcon(now.weatherCode, now.isDay)
            setIcon(context, views, ICON_IDS[0], nowIcon)
            views.setTextViewText(TEMP_IDS[0], formatTemp(now.temperature))
            views.setTextViewText(RAIN_IDS[0], formatPercent(now.precipitationProbability))
            views.setTextViewText(AMOUNT_IDS[0], formatRainAmount(now.precipitation))
            views.setContentDescription(
                CELL_IDS[0],
                "${cityLabel(city)}, agora: ${nowIcon.label}, ${Math.round(now.temperature)} graus, " +
                    "chance de chuva ${formatPercent(now.precipitationProbability)}, " +
                    "precipitação ${formatRainAmount(now.precipitation)}",
            )

            // Next hours: hour, icon, temperature, rain chance and mm.
            for (i in 1 until CELL_IDS.size) {
                val hour = hours.getOrNull(i)
                if (hour == null) {
                    views.setViewVisibility(CELL_IDS[i], View.INVISIBLE)
                    continue
                }
                val icon = weatherIcon(hour.weatherCode, hour.isDay)
                views.setViewVisibility(CELL_IDS[i], View.VISIBLE)
                views.setTextViewText(HOUR_IDS[i], hour.label)
                setIcon(context, views, ICON_IDS[i], icon)
                views.setTextViewText(TEMP_IDS[i], formatTemp(hour.temperature))
                views.setTextViewText(RAIN_IDS[i], formatPercent(hour.precipitationProbability))
                views.setTextViewText(AMOUNT_IDS[i], formatRainAmount(hour.precipitation))
                views.setContentDescription(
                    CELL_IDS[i],
                    "${hour.label}, ${icon.label}, ${Math.round(hour.temperature)} graus, " +
                        "chance de chuva ${formatPercent(hour.precipitationProbability)}, " +
                        "precipitação ${formatRainAmount(hour.precipitation)}",
                )
            }
            return views
        }

        private fun setIcon(context: Context, views: RemoteViews, id: Int, icon: WeatherIcon) {
            views.setImageViewResource(id, icon.drawable)
            views.setInt(id, "setColorFilter", context.getColor(icon.tint))
        }

        private fun messageViews(
            context: Context,
            ids: IntArray,
            message: String,
            retry: Boolean,
            title: String = "ClimAI",
        ): RemoteViews {
            val views = RemoteViews(context.packageName, R.layout.hourly_widget)
            views.setOnClickPendingIntent(R.id.widget_root, openAppIntent(context))
            views.setTextViewText(R.id.city, title)
            views.setViewVisibility(R.id.now, View.GONE)
            views.setViewVisibility(R.id.content, View.GONE)
            views.setViewVisibility(R.id.message, View.VISIBLE)
            views.setTextViewText(R.id.message, message)
            views.setViewVisibility(R.id.retry, if (retry) View.VISIBLE else View.GONE)
            if (retry) {
                views.setOnClickPendingIntent(
                    R.id.retry,
                    PendingIntent.getBroadcast(
                        context,
                        1,
                        updateIntent(context, ids),
                        PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
                    ),
                )
            }
            return views
        }
    }
}
