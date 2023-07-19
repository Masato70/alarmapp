import 'dart:async';
import 'dart:io';
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
    //アラームを流すとき
    try {
      final player = audioPlayer;
      await player.play(AssetSource("ringtone-126505.mp3"));
      player.setReleaseMode(ReleaseMode.loop);
      isAlarmRinging = true;
      print("アラーム音が再生しました");
    } catch (e) {
      print("アラーム音の再生中にエラーが発生しました");
      isAlarmRinging = false;
    }
  }

  void stopSound() {
    //アラームをストップするとき
    audioPlayer.stop();
    isAlarmRinging = false;
  }

  Future<void> requestPermissions() async {
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
