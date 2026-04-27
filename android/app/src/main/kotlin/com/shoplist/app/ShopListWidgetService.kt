package com.shoplist.app

import android.content.Context
import android.content.Intent
import android.graphics.Paint
import android.widget.RemoteViews
import android.widget.RemoteViewsService
import org.json.JSONArray

class ShopListWidgetService : RemoteViewsService() {
    override fun onGetViewFactory(intent: Intent): RemoteViewsFactory {
        return ShopListFactory(applicationContext, intent)
    }
}

class ShopListFactory(
    private val context: Context,
    intent: Intent
) : RemoteViewsService.RemoteViewsFactory {

    private val appWidgetId = intent.getIntExtra(
        android.appwidget.AppWidgetManager.EXTRA_APPWIDGET_ID, 0
    )
    private val listJson = intent.getStringExtra("list_json") ?: "[]"
    private val items = mutableListOf<WidgetItem>()

    data class WidgetItem(val id: String, val name: String, val emoji: String, val checked: Boolean)

    override fun onCreate() { parseItems() }
    override fun onDataSetChanged() { parseItems() }
    override fun onDestroy() {}

    private fun parseItems() {
        items.clear()
        try {
            val arr = JSONArray(listJson)
            for (i in 0 until arr.length()) {
                val obj = arr.getJSONObject(i)
                items.add(
                    WidgetItem(
                        id = obj.getString("id"),
                        name = obj.getString("name"),
                        emoji = obj.optString("emoji", ""),
                        checked = obj.getBoolean("checked")
                    )
                )
            }
        } catch (_: Exception) {}
    }

    override fun getCount() = items.size

    override fun getViewAt(position: Int): RemoteViews {
        val item = items[position]
        val views = RemoteViews(context.packageName, R.layout.widget_list_item)

        // Emoji + name
        val display = if (item.emoji.isNotEmpty()) "${item.emoji} ${item.name}" else item.name
        views.setTextViewText(R.id.item_text, display)

        // Strike-through + dim if checked
        if (item.checked) {
            views.setInt(R.id.item_text, "setPaintFlags",
                Paint.STRIKE_THRU_TEXT_FLAG or Paint.ANTI_ALIAS_FLAG)
            views.setTextColor(R.id.item_text, android.graphics.Color.parseColor("#AAAAAA"))
            views.setImageViewResource(R.id.item_check, R.drawable.ic_check_filled)
        } else {
            views.setInt(R.id.item_text, "setPaintFlags", Paint.ANTI_ALIAS_FLAG)
            views.setTextColor(R.id.item_text, android.graphics.Color.parseColor("#1A1A2E"))
            views.setImageViewResource(R.id.item_check, R.drawable.ic_check_empty)
        }

        // Fill intent for toggle
        val fillIntent = Intent().apply {
            putExtra("item_id", item.id)
            action = "TOGGLE_ITEM"
        }
        views.setOnClickFillInIntent(R.id.widget_list_item_root, fillIntent)

        return views
    }

    override fun getLoadingView() = null
    override fun getViewTypeCount() = 1
    override fun getItemId(position: Int) = items[position].id.hashCode().toLong()
    override fun hasStableIds() = true
}
