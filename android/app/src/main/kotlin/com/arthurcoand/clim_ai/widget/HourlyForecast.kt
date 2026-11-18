package com.arthurcoand.clim_ai.widget

import org.json.JSONObject

/** Favorite municipality as saved by the app (`City.toJson` in Dart). */
data class WidgetCity(
    /** Geocoding id (`City.id`). */
    val id: Long,
    val name: String,
    val admin1: String,
    val latitude: Double,
    val longitude: Double,
)

/** One hour of the widget strip. */
data class WidgetHour(
    /** "Agora" for the first hour, then "14h". */
    val label: String,
    val temperature: Double,
    val precipitationProbability: Int?,
    /** Precipitation (mm) during the preceding hour; null when missing. */
    val precipitation: Double?,
    val weatherCode: Int,
    val isDay: Boolean,
)

/** Points used by the widget: the current hour plus the next 8. */
const val WIDGET_HOURS = 9

/**
 * Mirrors `WeatherForecast.next24Hours` in Dart, limited to [count] hours:
 * the hourly points from the whole hour of `current.time` on, with the first
 * point replaced by the current conditions (its rain chance and mm come from
 * the forecast). Times are the municipality's wall-clock time.
 */
fun parseNextHours(json: JSONObject, count: Int = WIDGET_HOURS): List<WidgetHour> {
    val current = json.getJSONObject("current")
    val hourly = json.getJSONObject("hourly")
    val times = hourly.getJSONArray("time")
    val temps = hourly.getJSONArray("temperature_2m")
    val rain = hourly.optJSONArray("precipitation_probability")
    val amount = hourly.optJSONArray("precipitation")
    val codes = hourly.getJSONArray("weather_code")
    val isDay = hourly.optJSONArray("is_day")

    // "2026-11-17T19:15" -> "2026-11-17T19:00"; ISO strings sort by time.
    val start = current.getString("time").substring(0, 13) + ":00"

    val hours = mutableListOf<WidgetHour>()
    for (i in 0 until times.length()) {
        if (hours.size == count) break
        val time = times.getString(i)
        if (time < start || temps.isNull(i) || codes.isNull(i)) continue
        val chance = if (rain == null || rain.isNull(i)) null else Math.round(rain.getDouble(i)).toInt()
        // Like next24Hours, "Agora" keeps the forecast's precipitation of this hour.
        val mm = if (amount == null || amount.isNull(i)) null else amount.getDouble(i)
        hours += if (hours.isEmpty()) {
            WidgetHour(
                label = "Agora",
                temperature = current.getDouble("temperature_2m"),
                precipitationProbability = chance,
                precipitation = mm,
                weatherCode = current.getInt("weather_code"),
                isDay = current.optInt("is_day", 1) != 0,
            )
        } else {
            WidgetHour(
                label = time.substring(11, 13) + "h",
                temperature = temps.getDouble(i),
                precipitationProbability = chance,
                precipitation = mm,
                weatherCode = codes.getInt(i),
                isDay = isDay == null || isDay.isNull(i) || isDay.getInt(i) != 0,
            )
        }
    }
    return hours
}

/** "23°" — rounded, never "-0°" (same as `formatTemp` in Dart). */
fun formatTemp(celsius: Double): String = "${Math.round(celsius).toInt()}°"

fun formatPercent(value: Int?): String = if (value == null) "–" else "$value%"

/** "2,4 mm", "12 mm", "0 mm", "– mm" (same as `formatRainAmount` in Dart). */
fun formatRainAmount(mm: Double?): String {
    if (mm == null) return "– mm"
    val tenths = Math.round(mm * 10).toInt()
    val whole = tenths / 10
    val decimal = tenths % 10
    return if (decimal == 0) "$whole mm" else "$whole,$decimal mm"
}
