package com.yourapp.couponapp

import android.accessibilityservice.AccessibilityService
import android.view.accessibility.AccessibilityEvent
import android.util.Log

class AppDetectionService : AccessibilityService() {

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        if (event == null) return

        if (event.eventType == AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED) {
            val packageName = event.packageName?.toString()
            if (packageName != null) {
                Log.d("AppDetect", "Foreground app: $packageName")
            }
        }
    }

    override fun onInterrupt() {}
}
import com.yourapp.couponapp.MainActivity

override fun onAccessibilityEvent(event: AccessibilityEvent?) {
    if (event == null) return

    if (event.eventType == AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED) {
        val packageName = event.packageName?.toString() ?: return

        // Send to Flutter
        MainActivity.channel.invokeMethod(
            "onAppChanged",
            packageName
        )
    }
}