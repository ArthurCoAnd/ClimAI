package com.arthurcoand.clim_ai.widget

import android.app.Activity
import android.appwidget.AppWidgetManager
import android.content.Intent
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.widget.ImageView
import android.widget.LinearLayout
import android.widget.TextView
import com.arthurcoand.clim_ai.MainActivity
import com.arthurcoand.clim_ai.R

/**
 * Picks which favorite a widget shows. Opens when the widget is added and,
 * on Android 12+, from the widget's "reconfigure" option.
 */
class HourlyWidgetConfigureActivity : Activity() {

    private var widgetId = AppWidgetManager.INVALID_APPWIDGET_ID

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // Backing out without a choice cancels adding the widget.
        setResult(RESULT_CANCELED)

        widgetId = intent?.extras?.getInt(AppWidgetManager.EXTRA_APPWIDGET_ID, AppWidgetManager.INVALID_APPWIDGET_ID)
            ?: AppWidgetManager.INVALID_APPWIDGET_ID
        if (widgetId == AppWidgetManager.INVALID_APPWIDGET_ID) {
            finish()
            return
        }

        setContentView(R.layout.widget_configure)
        val favorites = WidgetCities.favorites(this)
        if (favorites.isEmpty()) {
            showEmpty()
        } else {
            showFavorites(favorites)
        }
    }

    private fun showFavorites(favorites: List<WidgetCity>) {
        val current = WidgetCities.chosen(this, widgetId)?.id
        val list = findViewById<LinearLayout>(R.id.favorites)
        val inflater = LayoutInflater.from(this)
        for (city in favorites) {
            val row = inflater.inflate(R.layout.widget_configure_row, list, false)
            row.findViewById<TextView>(R.id.name).text = city.name
            row.findViewById<TextView>(R.id.state).apply {
                text = city.admin1
                visibility = if (city.admin1.isEmpty()) View.GONE else View.VISIBLE
            }
            val selected = city.id == current
            row.findViewById<ImageView>(R.id.selected).visibility = if (selected) View.VISIBLE else View.GONE
            row.contentDescription = buildString {
                append(city.name)
                if (city.admin1.isNotEmpty()) append(", ").append(city.admin1)
                if (selected) append(", selecionado")
            }
            row.setOnClickListener { choose(city) }
            list.addView(row)
        }
    }

    private fun showEmpty() {
        findViewById<View>(R.id.favorites_scroll).visibility = View.GONE
        findViewById<View>(R.id.empty).visibility = View.VISIBLE
        findViewById<View>(R.id.open_app).apply {
            visibility = View.VISIBLE
            setOnClickListener {
                startActivity(Intent(this@HourlyWidgetConfigureActivity, MainActivity::class.java))
                finish()
            }
        }
    }

    private fun choose(city: WidgetCity) {
        WidgetCities.choose(this, widgetId, city)
        HourlyWidgetProvider.requestUpdate(this, intArrayOf(widgetId))
        setResult(RESULT_OK, Intent().putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, widgetId))
        finish()
    }
}
