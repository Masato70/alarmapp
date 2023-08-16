import 'dart:async';
import 'dart:io';
import 'package:alarm_clock/alarm_data_service.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'alarm_card.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';

class AlarmManager {
  AudioPlayer audioPlayer = AudioPlayer();
  bool isAlarmRinging = false;
  Timer? alarmTimer;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  AlarmDataService alarmDataService = AlarmDataService();
  Timer? vibrationTimer;

  AlarmManager() {
    _initializeNotifications();
  }


  void _initializeNotifications() {
    final AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings('tokei_clock_icon_2066');

    final DarwinInitializationSettings darwinInitializationSettings =
        DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    final InitializationSettings initializationSettings =
        InitializationSettings(
            android: androidInitializationSettings,
            iOS: darwinInitializationSettings);

    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: _handleNotificationAction);
  }

  // Future<void> startAlarmTimer(
  //     BuildContext context, List<AlarmCard> alarms, Function callback) async {
  //   alarmTimer = Timer.periodic(Duration(seconds: 1), (timer) {
  //     final currentTime = TimeOfDay.now();
  //     final setAlarms = alarms.where((alarm) => alarm.switchValue).toList();
  //
  //     for (var alarm in setAlarms) {
  //       if (currentTime.hour == alarm.alarmTime.hour &&
  //           currentTime.minute == alarm.alarmTime.minute &&
  //           !isAlarmRinging) {
  //         print("アラームがなります - アラームID: ${alarm.id}");
  //         print(alarms);
  //         _playAlarmSound();
  //         alarm.switchValue = false;
  //         alarmDataService.saveAlarms(alarms);
  //         alarmDataService.loadAlarms(alarms, callback);
  //       }
  //     }
  //   });
  // }

  Future<void> _playAlarmSound() async {
    try {
      await audioPlayer.play(AssetSource("ringtone-126505.mp3"));
      audioPlayer.setReleaseMode(ReleaseMode.loop);
      isAlarmRinging = true;
      _showNotification();
      startVibration();
      print("アラーム音が再生しました");
    } catch (e) {
      print("アラーム音の再生中にエラーが発生しました $e");
      isAlarmRinging = false;
    }
  }

  void stopAlarmSound(String alarmId) async {
    audioPlayer.stop();
    isAlarmRinging = false;

    print("アラームを停止しました");
  }

  void startVibration() async {
    vibrationTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      Vibration.vibrate(duration: 500);
    });
  }

  void stopVibration() {
    vibrationTimer?.cancel();
    print("バイブレーションがキャンセルされました");
    Vibration.cancel();
  }

  Future<void> requestPermissions() async {
    print("通知のパーミッションを要求する直後");

    if (Platform.isIOS || Platform.isMacOS) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              MacOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    } else if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      await androidImplementation?.requestPermission();
    }
  }

  Future<void> _showNotification() async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'your channel id',
      'your channel name',
      channelDescription: 'your channel description',
      importance: Importance.max,
      priority: Priority.high,
      icon: "tokei_clock_icon_2066",
      fullScreenIntent: true,
      enableVibration: true,
      ticker: 'ticker',
    );

    const String darwinNotificationCategoryPlain = 'plainCategory';
    const DarwinNotificationDetails iosNotificationDetails =
        DarwinNotificationDetails(
      presentAlert: true,
      categoryIdentifier: darwinNotificationCategoryPlain,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails, iOS: iosNotificationDetails);

    await flutterLocalNotificationsPlugin.show(
      0,
      'アラーム',
      'ストップ',
      notificationDetails,
      payload: 'stop_action:',
    );
  }

  Future<void> _handleNotificationAction(NotificationResponse? payload) async {
    String payloadValue = payload?.payload ?? '';
    print("通知がタップされました。Payload: $payloadValue");

    if (payloadValue.startsWith('stop_action:')) {
      String alarmId = payloadValue.split(':').last;
      stopAlarmSound(alarmId);
      stopVibration();
    }
  }
  //
  // @pragma('vm:entry-point')
  // void setupBackgroundAlarm(List<AlarmCard> alarms) {
  //
  //   print(alarms);
  //   AndroidAlarmManager.periodic(
  //     const Duration(seconds: 1),
  //     0,
  //     (int alarmId) {
  //       backgroundAlarmCallback(alarms);
  //     },
  //     exact: true,
  //     wakeup: true,
  //     rescheduleOnReboot: true,
  //     allowWhileIdle: true,
  //   );
  // }

  @pragma('vm:entry-point')
  Future<void> backgroundAlarmCallback(List<AlarmCard> alarms) async {
    final setAlarms = alarms.where((alarm) => alarm.switchValue).toList();
    final now = DateTime.now();
    print("ぁぁー");
    for (var alarm in setAlarms) {
      print("${setAlarms}");
      if (now.hour == alarm.alarmTime.hour &&
          now.minute == alarm.alarmTime.minute) {
        print("実行されます");
        await _playAlarmSound();
        startVibration();

        break;
      }
    }
  }
}
