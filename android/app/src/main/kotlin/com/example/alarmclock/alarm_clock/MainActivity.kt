package com.example.alarmclock.alarm_clock

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.ContentValues.TAG
import android.content.Context
import android.content.Intent
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import android.util.Log
import androidx.annotation.NonNull
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.*

class MainActivity : FlutterActivity() {

    companion object {
        lateinit var flutterEngine: FlutterEngine
    }

    private var alarmPendingIntent: PendingIntent? = null
    private val CHANNEL = "com.example.myapp"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MainActivity.flutterEngine = flutterEngine
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->
            if (call.method == "lets") {
                val list = call.arguments as List<String>
                println("MainActiivtyのリスト${list}")
                Log.d("ああああ", "レッツ")
                setAlarm(list)
            }
        }
    }

    fun setAlarm(alarmTimes: List<String>) {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager

        for (time in alarmTimes) {
            val parts = time.split(":")
            val hour = parts[0].toInt()
            val minute = parts[1].toInt()

            val calendar = Calendar.getInstance().apply {
                set(Calendar.HOUR_OF_DAY, hour)
                set(Calendar.MINUTE, minute)
                set(Calendar.SECOND, 0)
            }
            val requestCode = hour * 60 + minute
            val intent = Intent(context, AlarmReceiver::class.java)
            val alarmPendingIntent = PendingIntent.getBroadcast(context, requestCode, intent, PendingIntent.FLAG_IMMUTABLE)


            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                val alarmClockInfo = AlarmManager.AlarmClockInfo(calendar.timeInMillis, null)
                alarmManager.setAlarmClock(alarmClockInfo, alarmPendingIntent)
            } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
                alarmManager.setExact(
                    AlarmManager.RTC_WAKEUP,
                    calendar.timeInMillis,
                    alarmPendingIntent
                )
            } else {
                alarmManager.set(AlarmManager.RTC_WAKEUP, calendar.timeInMillis, alarmPendingIntent)
            }
        }
    }
}