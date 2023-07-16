import 'package:flutter/material.dart';


class AlarmCard {

  String id;
  bool isParent;
  String? childId;
  TimeOfDay alarmTime;
  bool switchValue;
  // List<bool>? weekdaysValues;

  AlarmCard ({
    required this.id,
    required this.isParent,
    this.childId,
    required this.alarmTime,
    required this.switchValue,
    // this.weekdaysValues,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'isParent': isParent,
      'childId' : childId,
      'alarmTime': {
        'hour': alarmTime.hour,
        'minute': alarmTime.minute,
      },
      'switchValue': switchValue,
      // 'weekdaysValues': weekdaysValues,
    };
  }

  @override
  String toString() {
    return 'AlarmCard(id: $id, isParent: $isParent, childId: $childId, alarmTime: $alarmTime, switchValue: $switchValue)';
  }
}