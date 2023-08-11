package com.example.alarmclock.alarm_clock

import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugins.GeneratedPluginRegistrant

import android.content.pm.PackageManager
import androidx.annotation.NonNull
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.ExperimentalCoroutinesApi


class MainActivity : FlutterActivity() {
    private val CHANNEL = "Alarm"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "startBackgroundProcess" -> {
                    val alarmId = call.argument<String>("alarmId")
                    if (alarmId != null) {
                        triggerAlarm()
                        result.success(null)
                    } else {
                        result.error("INVALID_ARGUMENT", "Alarm ID is missing.", null)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun triggerAlarm() {
        val alarmHandler = AlarmHandler(this)

        alarmHandler.handleAlarm()
    }
}
