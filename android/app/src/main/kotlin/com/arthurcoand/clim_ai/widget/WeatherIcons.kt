package com.arthurcoand.clim_ai.widget

import com.arthurcoand.clim_ai.R

/** Icon + tint of a WMO code, mirroring `weatherInfo` / `weatherToneColor` in Dart. */
data class WeatherIcon(
    /** Drawable resource. */
    val drawable: Int,
    /** Color resource. */
    val tint: Int,
    /** PT-BR description, read by screen readers. */
    val label: String,
)

fun weatherIcon(code: Int, isDay: Boolean): WeatherIcon {
    val sun = R.color.widget_accent
    val cloud = R.color.widget_ink
    val rain = R.color.widget_rain
    return when (code) {
        0 -> WeatherIcon(if (isDay) R.drawable.ic_weather_wb_sunny else R.drawable.ic_weather_nightlight_round, sun, "Céu limpo")
        1 -> WeatherIcon(if (isDay) R.drawable.ic_weather_wb_sunny else R.drawable.ic_weather_nightlight_round, sun, "Predominantemente limpo")
        2 -> WeatherIcon(if (isDay) R.drawable.ic_weather_cloud_queue else R.drawable.ic_weather_nights_stay, cloud, "Parcialmente nublado")
        3 -> WeatherIcon(R.drawable.ic_weather_cloud, cloud, "Nublado")
        45, 48 -> WeatherIcon(R.drawable.ic_weather_foggy, cloud, "Nevoeiro")
        51, 53, 55 -> WeatherIcon(R.drawable.ic_weather_grain, rain, "Garoa")
        56, 57 -> WeatherIcon(R.drawable.ic_weather_severe_cold, cloud, "Garoa congelante")
        61 -> WeatherIcon(R.drawable.ic_weather_water_drop, rain, "Chuva fraca")
        63 -> WeatherIcon(R.drawable.ic_weather_water_drop, rain, "Chuva moderada")
        65 -> WeatherIcon(R.drawable.ic_weather_water_drop, rain, "Chuva forte")
        66, 67 -> WeatherIcon(R.drawable.ic_weather_severe_cold, cloud, "Chuva congelante")
        71, 73, 75, 77 -> WeatherIcon(R.drawable.ic_weather_ac_unit, cloud, "Neve")
        80, 81, 82 -> WeatherIcon(R.drawable.ic_weather_umbrella, rain, "Pancadas de chuva")
        85, 86 -> WeatherIcon(R.drawable.ic_weather_ac_unit, cloud, "Pancadas de neve")
        95 -> WeatherIcon(R.drawable.ic_weather_thunderstorm, sun, "Trovoada")
        96, 99 -> WeatherIcon(R.drawable.ic_weather_thunderstorm, sun, "Trovoada com granizo")
        else -> WeatherIcon(R.drawable.ic_weather_cloud_queue, cloud, "Indefinido")
    }
}
