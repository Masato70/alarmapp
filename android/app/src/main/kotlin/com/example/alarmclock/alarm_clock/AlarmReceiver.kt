package com.example.alarmclock.alarm_clock

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.media.MediaPlayer
import android.media.RingtoneManager
import android.os.Build
import android.util.Log
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import androidx.core.content.ContextCompat.getSystemService
import com.example.alarmclock.alarm_clock.MainActivity
import io.flutter.plugin.common.MethodChannel

class AlarmReceiver : BroadcastReceiver() {
    private val CHANNEL = "com.example.app/alarm"
    private val CHANNEL_Id = "tesutodesuyo"
    override fun onReceive(context: Context, intent: Intent) {
        Log.d("AlarmReceiver", "onReceive calledててて")

        try {
            //アラームを鳴らす
            Log.d("AlarmReceiver", "try 成功。アラームと通知表示します。")
            val defaultRingtoneUri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_ALARM)
            val mediaPlayer = MediaPlayer.create(context, defaultRingtoneUri)
            mediaPlayer.start()

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                val name = "My Channel"
                val descriptionText = "This is my channel"
                val importance = NotificationManager.IMPORTANCE_DEFAULT
                val channel = NotificationChannel(CHANNEL_Id, name, importance).apply {
                    description = descriptionText
                }
                // Register the channel with the system
                val notificationManager: NotificationManager =
                    context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
                notificationManager.createNotificationChannel(channel)
            }

//            通知を表示
            val notification =
                NotificationCompat.Builder(context, CHANNEL_Id)
                    .setContentTitle("アラーム")
                    .setContentText("アラームが鳴っています")
                    .setSmallIcon(R.drawable.icon_115930_256)
                    .setAutoCancel(false)
                    .setPriority(NotificationCompat.PRIORITY_MAX)
                    .setContentIntent(getPendingIntent(context)).build()
            NotificationManagerCompat.from(context).notify(1, notification)

        } catch (e: Exception) {
            Log.d("AlarmReceiver", "Exception", e)
        }


//        val methodChannel =
//            MethodChannel(MainActivity.flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
//        methodChannel.invokeMethod("triggerAlarm", null)

        // 通知を表示します。
    }

    private fun getPendingIntent(context: Context): PendingIntent {
        val intent = Intent(context, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
        }
        return PendingIntent.getActivity(context, 0, intent, PendingIntent.FLAG_IMMUTABLE)
    }
}