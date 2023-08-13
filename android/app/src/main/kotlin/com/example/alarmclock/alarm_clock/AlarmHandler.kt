package com.example.alarmclock.alarm_clock

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
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
        vibrator = context.getSystemService(Context.VIBRATOR_SERVICE) as Vibrator

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            // パターンを定義（ここでは1秒バイブ、1秒待機、1秒バイブ...）
            val pattern = longArrayOf(0, 1000, 1000)
            val vibrationEffect = VibrationEffect.createWaveform(pattern, -1) // -1は無限ループを意味するsuru
            vibrator.vibrate(vibrationEffect)
        } else {
            @Suppress("DEPRECATION")
            // 古いAPIバージョンの場合
            vibrator.vibrate(longArrayOf(0, 1000, 1000), 0)
        }
    }

     fun stopVibration() {
        vibrator.cancel()
    }


    private fun showNotification() {
        val notificationManager = NotificationManagerCompat.from(context)

        val tapIntent = Intent(context, NotificationTapReceiver::class.java)
        tapIntent.action = "STOP_VIBRATION"
        val tapPendingIntent = PendingIntent.getBroadcast(context, 0, tapIntent, 0)

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
            .setContentIntent(tapPendingIntent)
            .build()

        notificationManager.notify(0, androidNotificationBuilder)
    }
}


class NotificationTapReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context?, intent: Intent?) {
        if (intent?.action == "STOP_VIBRATION") {
            val alarmHandler = AlarmHandler(context!!)
            alarmHandler.stopVibration()
        }
    }
}