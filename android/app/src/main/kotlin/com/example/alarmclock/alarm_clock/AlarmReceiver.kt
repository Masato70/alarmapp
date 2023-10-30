package com.example.alarmclock.alarm_clock

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log
import io.flutter.plugin.common.MethodChannel

class AlarmReceiver : BroadcastReceiver() {
    private val CHANNEL = "com.example.app/alarm"
    override fun onReceive(context: Context, intent: Intent) {
        Log.d("AlarmReceiver", "onReceive called")
        val methodChannel = MethodChannel(MainActivity.flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        methodChannel.invokeMethod("triggerAlarm", null)
    }
}