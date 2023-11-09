import 'dart:async';
import 'dart:io';
import 'package:alarm_clock/alarm_data_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
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
    initializeNotifications();
  }

  void initializeNotifications() {
    final AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings('icon_115930_256');

    final InitializationSettings initializationSettings =
        InitializationSettings(
            android: androidInitializationSettings);

    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: _handleNotificationAction);
  }

  Future<void> requestPermissions() async {
    print("通知のパーミッションを要求する直後");
    if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
      flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      await androidImplementation?.requestPermission();
    }
  }

  Future<void> playAlarm() async {
    try {
      if (!isAlarmRinging) {
        isAlarmRinging = true;
        _showNotification();
        _activateAlerts();
        print("アラーム音が再生しました");
        // UI更新
        // final AlarmCard alarmToOf = alarms.firstWhere((alarm) => alarm.id == alarmId);
        // alarmToOf.switchValue = false;
        // await alarmDataService.saveAlarms();
        // await alarmDataService.loadAlarms(() {});
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

  Future<void> deactivateAlerts() async {
    print("deactivateAlerts start");
    await stopAlarmSound();
    await stopVibration();
  }

  void _startAlarmSound() {
    FlutterRingtonePlayer.playAlarm(looping: true);
    print("アラームを再生中");
  }

  Future<void> stopAlarmSound() async {
    await FlutterRingtonePlayer.stop();
    print("アラームを停止");
  }

  void _startVibration() async {
    print("スタートバイブレーションです");
    vibrationTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      Vibration.vibrate(duration: 500);
      print("バイブレーションスタート");
    });
  }

  Future<void> stopVibration() async {
    try {
      await Vibration.cancel();
      vibrationTimer?.cancel();
      print("バイブレーションを停止");
    } catch (e) {
      print("バイブレーション停止中にエラーが発生しました: $e");
    }
  }

  Future<void> _showNotification() async {
    print("_showNotification Start 0");
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'your channel id',
      'your channel name',
      channelDescription: 'your channel description',
      importance: Importance.max,
      priority: Priority.high,
      icon: "icon_115930_256",
      fullScreenIntent: true,
      enableVibration: true,
      ticker: 'ticker',
    );
    print("_showNotification Start 1");

    const NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails);

    print("_showNotification Start 2");
    await flutterLocalNotificationsPlugin.show(
      0,
      'アラーム',
      'ストップ',
      notificationDetails,
      payload: 'stop_action:',
    );
    print("_showNotification Start 3");
  }

  Future<void> _handleNotificationAction(NotificationResponse? payload) async {
    String payloadValue = payload?.payload ?? '';
    print("通知がタップされました。Payload: $payloadValue");

    if (payloadValue.startsWith('stop_action:')) {
      print("ストップ");
      await deactivateAlerts();
    }
  }
}
