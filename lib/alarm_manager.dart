import 'dart:async';
import 'alarm_card.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';


class AlarmManager {
  AudioPlayer audioPlayer = AudioPlayer();
  bool isAlarmRinging = false;
  Timer? alarmTimer;

  Future<void> startAlarmTimer(BuildContext context, List<AlarmCard> alarms) async {
    alarmTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      final currentTime = TimeOfDay.now();
      final setAlarms = alarms.where((alarm) => alarm.switchValue).toList();

      for (var alarm in setAlarms) {
        print(currentTime.hour + currentTime.minute == alarm.alarmTime.hour + alarm.alarmTime.minute && !isAlarmRinging);
        print(alarms.where((alarm) => alarm.switchValue).toList());
        if (currentTime.hour + currentTime.minute == alarm.alarmTime.hour + alarm.alarmTime.minute && !isAlarmRinging) {
          print("い?");
          playSound();
          print("う?");
          break;
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
}
