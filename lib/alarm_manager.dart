import 'dart:async';
import 'dart:io';
import 'package:alarm_clock/alarm_data_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'alarm_card.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';

class AlarmManager {
  static const MethodChannel _channel = const MethodChannel('Alarm');

  // static Future<void> startAlarmAndVibration() async {
  //   await _channel.invokeMethod('startAlarmAndVibration');
  // }
  static Future<void> startAlarmAndVibration(DateTime alarmTime) async {
    await _channel.invokeMethod('startAlarmAndVibration',
        {'alarmTime': alarmTime.millisecondsSinceEpoch});
  }

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

  Future<void> startAlarmTimer(
      BuildContext context, List<AlarmCard> alarms, Function callback) async {
    alarmTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      final currentTime = TimeOfDay.now();
      final setAlarms = alarms.where((alarm) => alarm.switchValue).toList();

      for (var alarm in setAlarms) {
        if (currentTime.hour == alarm.alarmTime.hour &&
            currentTime.minute == alarm.alarmTime.minute &&
            !isAlarmRinging) {
          print("アラームがなります - アラームID: ${alarm.id}");
          print(alarms);
          _playAlarmSound(alarm.id);
          alarm.switchValue = false;
          alarmDataService.saveAlarms(alarms);
          alarmDataService.loadAlarms(alarms, callback);
        }
      }
    });
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
}
