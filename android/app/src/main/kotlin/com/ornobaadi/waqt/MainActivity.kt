package com.ornobaadi.waqt

import android.content.Context
import android.content.Intent
import android.hardware.GeomagneticField
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import android.os.Build
import android.os.PowerManager
import android.os.VibrationEffect
import android.os.Vibrator
import android.os.VibratorManager
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
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
        // Haptics straight from the vibrator: crisper and stronger than the
        // view-level feedback Flutter uses, which many phones mute or soften.
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "waqt/haptics").setMethodCallHandler { call, result ->
            playHaptic(call.arguments as? String ?: "click")
            result.success(null)
        }
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, "waqt/heading").setStreamHandler(HeadingStream(this))
    }

    private val vibrator: Vibrator? by lazy {
        if (Build.VERSION.SDK_INT >= 31) {
            (getSystemService(VIBRATOR_MANAGER_SERVICE) as? VibratorManager)?.defaultVibrator
        } else {
            @Suppress("DEPRECATION")
            getSystemService(VIBRATOR_SERVICE) as? Vibrator
        }
    }

    private fun playHaptic(kind: String) {
        val v = vibrator ?: return
        if (!v.hasVibrator()) return
        try {
            if (Build.VERSION.SDK_INT >= 29) {
                val effect = when (kind) {
                    "tick" -> VibrationEffect.createPredefined(VibrationEffect.EFFECT_TICK)
                    "heavy" -> VibrationEffect.createPredefined(VibrationEffect.EFFECT_HEAVY_CLICK)
                    "double" -> VibrationEffect.createPredefined(VibrationEffect.EFFECT_DOUBLE_CLICK)
                    "success" -> VibrationEffect.createWaveform(longArrayOf(0, 28, 90, 28, 90, 60), intArrayOf(0, 255, 0, 255, 0, 255), -1)
                    else -> VibrationEffect.createPredefined(VibrationEffect.EFFECT_CLICK)
                }
                v.vibrate(effect)
            } else if (Build.VERSION.SDK_INT >= 26) {
                val (ms, amp) = when (kind) {
                    "tick" -> 8L to 120
                    "heavy" -> 30L to 255
                    "double", "success" -> 24L to 255
                    else -> 16L to 200
                }
                val amplitude = if (v.hasAmplitudeControl()) amp else VibrationEffect.DEFAULT_AMPLITUDE
                v.vibrate(VibrationEffect.createOneShot(ms, amplitude))
            } else {
                @Suppress("DEPRECATION")
                v.vibrate(if (kind == "tick") 8L else 20L)
            }
        } catch (_: Exception) {
        }
    }
}

/**
 * Qibla heading from Android's fused rotation-vector sensor (gyroscope +
 * accelerometer + magnetometer): fast and steady, unlike raw magnetometer
 * maths. Corrected to true north with the World Magnetic Model for the
 * chosen place. Emits [headingDegrees, tiltDegrees, accuracyDegrees (-1 unknown)].
 * Works flat or held upright: when the phone stands up, the heading is where
 * its back faces.
 */
private class HeadingStream(private val context: Context) : EventChannel.StreamHandler, SensorEventListener {
    private var sink: EventChannel.EventSink? = null
    private var manager: SensorManager? = null
    private var declination = 0f
    private val r = FloatArray(9)
    private val remapped = FloatArray(9)
    private val orientation = FloatArray(3)

    override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
        val sm = context.getSystemService(Context.SENSOR_SERVICE) as SensorManager
        val sensor = sm.getDefaultSensor(Sensor.TYPE_ROTATION_VECTOR)
            ?: sm.getDefaultSensor(Sensor.TYPE_GEOMAGNETIC_ROTATION_VECTOR)
        if (sensor == null) {
            events.error("unavailable", "No rotation vector sensor", null)
            return
        }
        (arguments as? Map<*, *>)?.let { a ->
            val lat = (a["lat"] as? Number)?.toFloat()
            val lng = (a["lng"] as? Number)?.toFloat()
            if (lat != null && lng != null) {
                declination = GeomagneticField(lat, lng, 0f, System.currentTimeMillis()).declination
            }
        }
        sink = events
        manager = sm
        sm.registerListener(this, sensor, SensorManager.SENSOR_DELAY_GAME)
    }

    override fun onCancel(arguments: Any?) {
        manager?.unregisterListener(this)
        manager = null
        sink = null
    }

    override fun onSensorChanged(event: SensorEvent) {
        SensorManager.getRotationMatrixFromVector(r, event.values)
        // r[8] is the cosine of the screen's tilt from flat.
        val tilt = Math.toDegrees(Math.acos(r[8].toDouble().coerceIn(-1.0, 1.0)))
        val m = if (tilt > 55) {
            SensorManager.remapCoordinateSystem(r, SensorManager.AXIS_X, SensorManager.AXIS_Z, remapped)
            remapped
        } else r
        SensorManager.getOrientation(m, orientation)
        var heading = Math.toDegrees(orientation[0].toDouble()) + declination
        heading = (heading % 360 + 360) % 360
        val accuracy = if (event.values.size > 4 && event.values[4] >= 0) Math.toDegrees(event.values[4].toDouble()) else -1.0
        sink?.success(listOf(heading, tilt, accuracy))
    }

    override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {}
}
