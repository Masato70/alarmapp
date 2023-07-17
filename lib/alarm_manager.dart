import 'dart:async';
import 'alarm_card.dart';
import 'package:flutter/material.dart';

class AlarmManager {

  Future<void> startAlarmTimer(BuildContext context, List<AlarmCard> alarms) async {
    Timer alarmTimer;

    alarmTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      final currentTime = TimeOfDay.now();
      final setAlarms = alarms.where((alarm) => alarm.switchValue).toList();



    });
    
    
  }
}