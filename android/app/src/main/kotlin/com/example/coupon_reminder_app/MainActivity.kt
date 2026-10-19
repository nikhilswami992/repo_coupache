package com.example.coupon_reminder_app

import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.Intent
import android.os.Handler
import android.os.Looper
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val CHANNEL = "app_foreground_channel"
    private var lastPackage: String? = null
    private val handler = Handler(Looper.getMainLooper())

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        val channel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        )

        // 🔁 Start monitoring foreground app
        startForegroundPolling(channel)
    }

    private fun startForegroundPolling(channel: MethodChannel) {
        handler.post(object : Runnable {
            override fun run() {
                val currentApp = getForegroundApp()

                if (currentApp != null && currentApp != lastPackage) {
                    lastPackage = currentApp

                    // 🚀 PUSH event to Flutter
                    channel.invokeMethod(
                        "onAppChanged",
                        currentApp
                    )
                }

                handler.postDelayed(this, 1500) // poll every 1.5 sec
            }
        })
    }

    private fun getForegroundApp(): String? {
        val usm =
            getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager

        val time = System.currentTimeMillis()
        val stats =
            usm.queryUsageStats(
                UsageStatsManager.INTERVAL_DAILY,
                time - 1000 * 10,
                time
            )

        if (stats.isNullOrEmpty()) return return "NO_USAGE_PERMISSION"

        return stats.maxByOrNull { it.lastTimeUsed }?.packageName
    }

    override fun onResume() {
        super.onResume()

        // 🔐 Redirect user if permission not granted
        if (!hasUsagePermission()) {
            startActivity(Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS))
        }
    }

    private fun hasUsagePermission(): Boolean {
        val usm =
            getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager

        val time = System.currentTimeMillis()
        val stats =
            usm.queryUsageStats(
                UsageStatsManager.INTERVAL_DAILY,
                time - 1000 * 5,
                time
            )

        return !stats.isNullOrEmpty()
    }
}
