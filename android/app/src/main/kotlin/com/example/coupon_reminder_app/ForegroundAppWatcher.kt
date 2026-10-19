package com.example.coupon_reminder_app

import android.app.usage.UsageStatsManager
import android.content.Context
import android.os.Handler
import android.os.Looper
import io.flutter.plugin.common.MethodChannel

class ForegroundAppWatcher(
    private val context: Context,
    private val channel: MethodChannel
) {

    private val handler = Handler(Looper.getMainLooper())
    private var lastPackage: String? = null

    private val runnable = object : Runnable {
        override fun run() {
            val currentApp = getForegroundApp()
            if (currentApp != null && currentApp != lastPackage) {
                lastPackage = currentApp

                // 🔥 Send package name to Flutter
                channel.invokeMethod("onAppChanged", currentApp)
            }

            handler.postDelayed(this, 2000) // every 2 sec
        }
    }

    fun start() {
        handler.post(runnable)
    }

    private fun getForegroundApp(): String? {
        val usageStatsManager =
            context.getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager

        val endTime = System.currentTimeMillis()
        val beginTime = endTime - 5000

        val stats = usageStatsManager.queryUsageStats(
            UsageStatsManager.INTERVAL_DAILY,
            beginTime,
            endTime
        )

        if (stats.isNullOrEmpty()) return null

        return stats.maxByOrNull { it.lastTimeUsed }?.packageName
    }
}