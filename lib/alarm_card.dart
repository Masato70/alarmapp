import 'package:flutter/material.dart';

class AlarmCard {
  int id;
  TimeOfDay alarmTime;
  bool switchValue;
  List<TimeOfDay>? linkAlarmTime;
  List<bool>? linkSwitchValue;
  List<bool>? weekdaysValues;

  AlarmCard({
    required this.id,
    required this.alarmTime,
    required this.switchValue,
    this.linkAlarmTime,
    this.linkSwitchValue,
    this.weekdaysValues,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'alarmTime': {
        'hour': alarmTime.hour,
        'minute': alarmTime.minute,
      },
      'switchValue': switchValue,
      'alarmTimeLinks': linkAlarmTime?.map((time) => {
        'hour': time.hour,
        'minute': time.minute,
      }).toList(),
      'switchValueLinks': linkSwitchValue,
      'weekdaysValues': weekdaysValues,
    };
  }

  @override
  String toString() {
    return 'AlarmCard(id: $id, alarmTime: $alarmTime, switchValue: $switchValue, alarmTimeLinks: $linkAlarmTime, switchValueLinks: $linkSwitchValue)';
  }
}






