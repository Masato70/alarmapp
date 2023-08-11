package com.example.alarmclock.alarm_clock

import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.os.Build
import android.os.PowerManager
import android.os.VibrationEffect
import android.os.Vibrator
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat

class AlarmHandler(private val context: Context) {

    private var wakeLock: PowerManager.WakeLock? = null
    private lateinit var vibrator: Vibrator
    private val CHANNEL_ID = "your channel id"


    fun handleAlarm() {
        val powerManager = context.getSystemService(Context.POWER_SERVICE) as PowerManager
        wakeLock = powerManager.newWakeLock(
            PowerManager.PARTIAL_WAKE_LOCK,
            "MyApp:AlarmWakeLock"
        )
        wakeLock?.acquire()

        try {
            playAlarmSound()
            vibrate()
            showNotification()
        } finally {
            wakeLock?.release()
        }
    }

    private fun playAlarmSound() {

    }


    private fun vibrate() {


    }

    private fun showNotification() {

        val notificationManager = NotificationManagerCompat.from(context)

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "Your Channel Name",
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "Your Channel Description"
                enableVibration(true)
            }
            notificationManager.createNotificationChannel(channel)
        }

        val androidNotificationBuilder = NotificationCompat.Builder(context, CHANNEL_ID)
            .setContentTitle("アラーム")
            .setContentText("ストップ")
            .setSmallIcon(
                context.resources.getIdentifier(
                    "tokei_clock_icon_2066",
                    "drawable",
                    context.packageName
                )
            )
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setCategory(NotificationCompat.CATEGORY_ALARM)
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
            .setFullScreenIntent(null, true)
            .setTicker("ticker")
            .build()

        notificationManager.notify(0, androidNotificationBuilder)

    }
}