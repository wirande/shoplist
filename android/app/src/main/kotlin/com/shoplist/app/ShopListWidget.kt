package com.shoplist.app

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin

class ShopListWidget : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            updateWidget(context, appWidgetManager, appWidgetId)
        }
    }

    companion object {
        fun updateWidget(
            context: Context,
            appWidgetManager: AppWidgetManager,
            appWidgetId: Int
        ) {
            val widgetData = HomeWidgetPlugin.getData(context)
            val pendingCount = widgetData.getInt("pending_count", 0)
            val listJson = widgetData.getString("shopping_list", "[]")

            val views = RemoteViews(context.packageName, R.layout.shop_list_widget)

            // Header count
            views.setTextViewText(
                R.id.widget_count,
                "$pendingCount item${if (pendingCount != 1) "s" else ""}"
            )

            // Set up the list via RemoteViewsService
            val serviceIntent = Intent(context, ShopListWidgetService::class.java).apply {
                putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId)
                putExtra("list_json", listJson)
                data = Uri.parse(toUri(Intent.URI_INTENT_SCHEME))
            }
            views.setRemoteAdapter(R.id.widget_list, serviceIntent)
            views.setEmptyView(R.id.widget_list, R.id.widget_empty)

            // Click handler for list items
            val clickIntent = Intent(context, ShopListWidget::class.java).apply {
                action = "TOGGLE_ITEM"
                putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId)
            }
            val clickPendingIntent = android.app.PendingIntent.getBroadcast(
                context, 0, clickIntent,
                android.app.PendingIntent.FLAG_UPDATE_CURRENT or android.app.PendingIntent.FLAG_MUTABLE
            )
            views.setPendingIntentTemplate(R.id.widget_list, clickPendingIntent)

            // Open app on header tap
            val openIntent = context.packageManager.getLaunchIntentForPackage(context.packageName)
            val openPendingIntent = android.app.PendingIntent.getActivity(
                context, 0, openIntent,
                android.app.PendingIntent.FLAG_UPDATE_CURRENT or android.app.PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(R.id.widget_header, openPendingIntent)

            appWidgetManager.updateAppWidget(appWidgetId, views)
            appWidgetManager.notifyAppWidgetViewDataChanged(appWidgetId, R.id.widget_list)
        }
    }

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        if (intent.action == "TOGGLE_ITEM") {
            val itemId = intent.getStringExtra("item_id") ?: return
            val appWidgetId = intent.getIntExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, AppWidgetManager.INVALID_APPWIDGET_ID)

            // Toggle item directly in SharedPreferences (no app launch)
            val prefs = HomeWidgetPlugin.getData(context)
            val listJson = prefs.getString("shopping_list", "[]") ?: "[]"

            val toggled = toggleItemInJson(listJson, itemId)

            val pendingCount = countPending(toggled)
            prefs.edit()
                .putString("shopping_list", toggled)
                .putInt("pending_count", pendingCount)
                // Queue toggle so Flutter applies it to SQLite on next resume
                .putString("widget_pending_toggle", itemId)
                .apply()

            // Refresh widget immediately
            val manager = AppWidgetManager.getInstance(context)
            if (appWidgetId != AppWidgetManager.INVALID_APPWIDGET_ID) {
                updateWidget(context, manager, appWidgetId)
            } else {
                val ids = manager.getAppWidgetIds(
                    android.content.ComponentName(context, ShopListWidget::class.java)
                )
                ids.forEach { updateWidget(context, manager, it) }
            }
        }
    }

    private fun toggleItemInJson(json: String, itemId: String): String {
        return try {
            val arr = org.json.JSONArray(json)
            for (i in 0 until arr.length()) {
                val obj = arr.getJSONObject(i)
                if (obj.getString("id") == itemId) {
                    obj.put("checked", !obj.getBoolean("checked"))
                    break
                }
            }
            arr.toString()
        } catch (_: Exception) { json }
    }

    private fun countPending(json: String): Int {
        return try {
            val arr = org.json.JSONArray(json)
            var count = 0
            for (i in 0 until arr.length()) {
                if (!arr.getJSONObject(i).getBoolean("checked")) count++
            }
            count
        } catch (_: Exception) { 0 }
    }
}
