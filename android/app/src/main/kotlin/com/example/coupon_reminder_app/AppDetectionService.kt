package com.example.coupon_reminder_app

import android.accessibilityservice.AccessibilityService
import android.view.accessibility.AccessibilityEvent
import android.util.Log
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.plugin.common.MethodChannel

class AppDetectionService : AccessibilityService() {

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        if (event == null) return

        if (event.eventType == AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED) {
            val packageName = event.packageName?.toString() ?: return

            Log.d("AppDetect", "Foreground app: $packageName")

            val engine = FlutterEngineCache
                .getInstance()
                .get("main_engine")

            engine?.dartExecutor?.let {
                MethodChannel(it.binaryMessenger, "app_detection")
                    .invokeMethod("onAppChanged", packageName)
            }
        }
    }

    override fun onInterrupt() {}
}