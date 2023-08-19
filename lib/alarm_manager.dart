import 'dart:async';
import 'dart:io';
import 'package:alarm_clock/alarm_data_service.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'alarm_card.dart';
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

  Future<void> playAlarmSound() async {
    print("よばれ");

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
    print(alarmId);
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

  void sensunaikedo() async {
    print("せんすないけど");
    List<AlarmCard> alarmSet = [];
    await alarmDataService.initSharedPreferences();

    print("更新前のalarmSet: ${alarmSet}");
    final aa = await alarmDataService.getAlarmCardsFromSharedPreferences();
    print("お試しaa: ${aa}");
    alarmSet.clear();
    alarmSet.addAll(aa);
    // final setAlarms = alarmSet.where((alarm) => alarm.switchValue).toList();
    List<AlarmCard> setAlarms = alarmSet.where((alarm) => alarm.switchValue).toList(); // 更新する部分を追加

    final now = DateTime.now();
    print("現在時刻 ${now}");
    print("更新後のalarmSet: ${alarmSet}");
    print("有効なアラーム ${setAlarms}");


    for (var alarm in setAlarms) {
      print("for文");
      if (now.hour == alarm.alarmTime.hour &&
          now.minute == alarm.alarmTime.minute) {
        print("実行されます");
        await playAlarmSound();
      }
    }
  }


  // void sensunaikedo() async {
  //   print("せんすないけど");
  //   final setAlarms = alarms.where((alarm) => alarm.switchValue).toList();
  //   final now = DateTime.now();
  //   print(now);
  //   print(alarms);
  //   print(setAlarms);
  //
  //   for (var alarm in setAlarms) {
  //     print("for文");
  //     if (now.hour == alarm.alarmTime.hour &&
  //         now.minute == alarm.alarmTime.minute) {
  //       print("実行されます");
  //       await playAlarmSound();
  //     }
  //   }
  // }
}
