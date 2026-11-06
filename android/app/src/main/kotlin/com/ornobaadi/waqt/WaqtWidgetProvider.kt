package com.ornobaadi.waqt

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.os.SystemClock
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider
import org.json.JSONArray

/**
 * Current waqt + next prayer with a live countdown.
 *
 * The app writes a schedule (one entry per waqt for the coming days) as JSON
 * under "schedule"; this provider picks the entry in effect right now, so the
 * widget stays correct for days without the app running. The app also asks
 * home_widget to refresh it at every boundary.
 */
class WaqtWidgetProvider : HomeWidgetProvider() {

    private data class Entry(
        val place: String,
        val current: String,
        val next: String,
        val nextAt: Long,
        val ground: Int,
        val ink: Int,
        val muted: Int,
    )

    private fun pick(json: String?, now: Long): Entry? {
        if (json == null) return null
        return try {
            val arr = JSONArray(json)
            var found: Entry? = null
            for (i in 0 until arr.length()) {
                val o = arr.getJSONObject(i)
                if (o.getLong("at") > now) break
                found = Entry(
                    place = o.optString("place"),
                    current = o.getString("current"),
                    next = o.getString("next"),
                    nextAt = o.getLong("nextAt"),
                    ground = o.getLong("ground").toInt(),
                    ink = o.getLong("ink").toInt(),
                    muted = o.getLong("muted").toInt(),
                )
            }
            // Stale if the schedule ran out (app not opened for a long time).
            if (found != null && found.nextAt <= now) null else found
        } catch (e: Exception) {
            null
        }
    }

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        val now = System.currentTimeMillis()
        val entry = pick(widgetData.getString("schedule", null), now)
        val launch = context.packageManager.getLaunchIntentForPackage(context.packageName)
            ?: Intent(context, MainActivity::class.java)
        val tap = PendingIntent.getActivity(
            context,
            0,
            launch,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )

        for (id in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.waqt_widget)
            views.setOnClickPendingIntent(R.id.waqt_root, tap)
            if (entry == null) {
                views.setTextViewText(R.id.waqt_place, "")
                views.setTextViewText(R.id.waqt_current, widgetData.getString("emptyTitle", "Waqt"))
                views.setTextViewText(R.id.waqt_next, widgetData.getString("emptyBody", "Open Waqt to set your location"))
                views.setViewVisibility(R.id.waqt_countdown, View.GONE)
            } else {
                views.setInt(R.id.waqt_bg, "setColorFilter", entry.ground)
                views.setTextViewText(R.id.waqt_place, entry.place)
                views.setTextColor(R.id.waqt_place, entry.muted)
                views.setTextViewText(R.id.waqt_current, entry.current)
                views.setTextColor(R.id.waqt_current, entry.ink)
                views.setTextViewText(R.id.waqt_next, entry.next)
                views.setTextColor(R.id.waqt_next, entry.muted)
                views.setViewVisibility(R.id.waqt_countdown, View.VISIBLE)
                views.setTextColor(R.id.waqt_countdown, entry.ink)
                val base = SystemClock.elapsedRealtime() + (entry.nextAt - now)
                views.setChronometer(R.id.waqt_countdown, base, null, true)
                views.setChronometerCountDown(R.id.waqt_countdown, true)
            }
            appWidgetManager.updateAppWidget(id, views)
        }
    }
}
