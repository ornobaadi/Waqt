package com.ornobaadi.waqt

import android.content.Intent
import android.os.Build
import android.os.PowerManager
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // Battery optimisation: report status and open the system list. We never
        // request the exemption directly (Play restricts that permission).
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "waqt/battery").setMethodCallHandler { call, result ->
            when (call.method) {
                "isIgnoring" -> {
                    val pm = getSystemService(POWER_SERVICE) as PowerManager
                    result.success(pm.isIgnoringBatteryOptimizations(packageName))
                }
                "openSettings" -> {
                    try {
                        startActivity(Intent(Settings.ACTION_IGNORE_BATTERY_OPTIMIZATION_SETTINGS))
                        result.success(true)
                    } catch (e: Exception) {
                        result.success(false)
                    }
                }
                "manufacturer" -> result.success(Build.MANUFACTURER)
                else -> result.notImplemented()
            }
        }
    }
}
