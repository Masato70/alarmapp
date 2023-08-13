package com.example.alarmclock.alarm_clock

import android.content.ContentValues.TAG
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugins.GeneratedPluginRegistrant
import androidx.annotation.NonNull
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.ExperimentalCoroutinesApi
import java.util.*


class MainActivity : FlutterActivity() {
    private val CHANNEL = "Alarm"
    private val METHOD_GET_LIST = "alarms"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine)
        val methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "Alarm")

        methodChannel.setMethodCallHandler { call, result ->
            if (call.method == "startAlarmAndVibration") {
                Log.d(TAG, "Received startAlarmAndVibration method call")
                val serializedAlarms = call.argument<List<Map<String, Any>>>("alarms")

                if (serializedAlarms != null) {
                    Log.d(TAG, "Received serializedAlarms: $serializedAlarms")
                    val alarmTimeList = serializedAlarms.mapNotNull { alarm ->
                        val alarmTime = alarm["alarmTime"] as? Long
                        Log.d(TAG, "Received alarmTime: $alarmTime")
                        alarmTime?.let { Date(it) }
                    }
                    checkAndTriggerAlarm(alarmTimeList)
                } else {
                    Log.e(TAG, "Serialized alarms is null")
                }

                result.success(null)
            } else {
                Log.d(TAG, "Unhandled method call: ${call.method}")
                result.notImplemented()
            }
        }
    }

    private fun checkAndTriggerAlarm(alarmTimeList: List<Date>?) {
        val currentTime = Date()
        val timeToleranceInMillis = 10000 // 10秒の許容範囲

        alarmTimeList?.forEach { alarmTime ->
            val timeDifferenceInMillis = Math.abs(alarmTime.time - currentTime.time)
            if (timeDifferenceInMillis <= timeToleranceInMillis) {
                triggerAlarm()
            }
        }
    }

    private fun triggerAlarm() {
        val alarmHandler = AlarmHandler(this)

        alarmHandler.handleAlarm()
    }
}
