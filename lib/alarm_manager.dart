import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'alarm_card.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class AlarmManager {
  AudioPlayer audioPlayer = AudioPlayer();
  bool isAlarmRinging = false;
  Timer? alarmTimer;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  AlarmManager() {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('tokei_clock_icon_2066');

    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsDarwin);

    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: _notificationOnSelect);

    print("通知の初期化が完了しました");
  }

  Future<void> startAlarmTimer(
      BuildContext context, List<AlarmCard> alarms) async {
    alarmTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      final currentTime = TimeOfDay.now();
      final setAlarms = alarms.where((alarm) => alarm.switchValue).toList();

      for (var alarm in setAlarms) {
        if (currentTime.hour + currentTime.minute ==
                alarm.alarmTime.hour + alarm.alarmTime.minute &&
            !isAlarmRinging) {
          print("アラームがなります");
          playSound();
        }
      }
    });
  }

  Future<void> playSound() async {
    try {
      final player = audioPlayer;
      await player.play(AssetSource("ringtone-126505.mp3"));
      player.setReleaseMode(ReleaseMode.loop);
      isAlarmRinging = true;
      print("アラーム音が再生しました");
      _showNotification();
    } catch (e) {
      print("アラーム音の再生中にエラーが発生しました");
      isAlarmRinging = false;
    }
  }

  void stopSound() {
    audioPlayer.stop();
    isAlarmRinging = false;
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
    print("通知準備");
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'your channel id',
      'your channel name',
      channelDescription: 'your channel description',
      importance: Importance.max,
      priority: Priority.high,
      icon: "tokei_clock_icon_2066",
      fullScreenIntent: true,
      enableVibration: false,
      ticker: 'ticker',
      actions: <AndroidNotificationAction>[
        AndroidNotificationAction(
          'stop_action',
          'ストップ',
          icon: DrawableResourceAndroidBitmap('tokei_clock_icon_2066'),
          contextual: true,
        ),
      ],
    );

    const String darwinNotificationCategoryPlain = 'plainCategory';

    const DarwinNotificationDetails iosNotificationDetails =
        DarwinNotificationDetails(
      categoryIdentifier: darwinNotificationCategoryPlain,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails, iOS: iosNotificationDetails);

    await flutterLocalNotificationsPlugin.show(
      0,
      'アラーム',
      'アラームを止めますか？',
      notificationDetails,
      payload: 'stop_action',
    );
  }

  void _notificationOnSelect(NotificationResponse? payload) async {
    String payloadValue = payload?.payload ?? '';
    print("通知がタップされました。Payload: $payloadValue");
    if (payloadValue == 'stop_action' && isAlarmRinging) {
      print("アラームストップメソッド呼び出し");
      stopSound();
    }
  }
}
