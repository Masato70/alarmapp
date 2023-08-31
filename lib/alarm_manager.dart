import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:alarm_clock/alarm_data_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'alarm_card.dart';
import 'package:alarm_clock/main.dart';
import 'package:vibration/vibration.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';

class AlarmManager {
  bool isAlarmRinging = false;
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

  Future<void> playAlarm(String alarmId) async {
    try {
      if (!isAlarmRinging) {
        isAlarmRinging = true;
        _showNotification();
        _activateAlerts();
        print("アラーム音が再生しました");
        // UI更新
        final AlarmCard alarmToOf = alarms.firstWhere((alarm) => alarm.id == alarmId);
        alarmToOf.switchValue = false;
        await alarmDataService.saveAlarms();
        await alarmDataService.loadAlarms(() {});
        await alarmDataService.initSharedPreferences();
        alarms.clear();
        alarms.addAll(await alarmDataService.getAlarmCardsFromSharedPreferences());
        print("あらーむす　${alarms}");
      }
    } catch (e) {
      print("アラーム音の再生中にエラーが発生しました $e");
      isAlarmRinging = false;
    }
  }

  void _activateAlerts() {
    print("_activateAlerts start");
    _startAlarmSound();
    _startVibration();
  }

  void deactivateAlerts() {
    print("deactivateAlerts start");
    stopAlarmSound();
    stopVibration();
  }

  void _startAlarmSound() {
    FlutterRingtonePlayer.playAlarm(looping: true);
    print("アラームを再生中");
  }

  void stopAlarmSound() async {
    FlutterRingtonePlayer.stop();
    print("アラームを停止");
  }

  void _startVibration() async {
    vibrationTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      Vibration.vibrate(duration: 500);
      print("バイブレーションスタート");
    });
  }

  void stopVibration() async {
    vibrationTimer?.cancel();
    Vibration.cancel();
    print("バイブレーションを停止");
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
      print("ストップ");
      IsolateNameServer.lookupPortByName("myUniquePortName")?.send("stop");
      IsolateNameServer.removePortNameMapping("myUniquePortName");
    }
  }

  Future<void> checkAndTriggerAlarms() async {
    await alarmDataService.initSharedPreferences();
    final now = DateTime.now();

    print("更新前のalarmSet: ${alarms}");
    alarms.clear();
    alarms.addAll(await alarmDataService.getAlarmCardsFromSharedPreferences());
    List<AlarmCard> switchOnAlarms = alarms.where((alarm) => alarm.switchValue).toList();

    for (var alarm in switchOnAlarms) {
      if (now.hour == alarm.alarmTime.hour && now.minute == alarm.alarmTime.minute) {
        print("実行されます");
        playAlarm(alarm.id);
      }
    }
  }
}
