import 'dart:convert';
import 'package:alarm_clock/main.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'alarm_card.dart';

class PreferencesService {
  late SharedPreferences prefs;

  Future<void> initPrefs() async {
    prefs = await SharedPreferences.getInstance();
  }

  Future<void> loadAlarms(List<AlarmCard> alarms) async {
    prefs = await SharedPreferences.getInstance();
    print('loadAlarms alarmls: $alarms');

    final alarmList = alarms.map((alarm) {
      final data = alarm.toJson();

      final alarmTime = TimeOfDay(
        hour: data['alarmTime']['hour'],
        minute: data['alarmTime']['minute'],
      );

      final switchValue = data['switchValue'];

      final linkAlarmTime = (data['linkAlarmTime'] as List<dynamic>?)?.map((linkData) {
        return TimeOfDay(
          hour: linkData['hour'],
          minute: linkData['minute'],
        );
      }).toList();

      final linkSwitchValue = (data['linkSwitchValue'] as List<dynamic>?)?.map((value) {
        return value as bool;
      }).toList();

      // final weekdaysValues = (data['weekdaysValues'] as List<dynamic>?)?.map((value) {
      //   return value as bool;
      // }).toList();

      return AlarmCard(
        id: data['id'],
        alarmTime: alarmTime,
        switchValue: switchValue,
        linkAlarmTime: linkAlarmTime,
        linkSwitchValue: linkSwitchValue,
        // weekdaysValues: weekdaysValues,
      );
    }).toList();

    alarms = alarmList;
    alarms.sort((a, b) {
      if (a.alarmTime.hour == b.alarmTime.hour) {
        return a.alarmTime.minute.compareTo(b.alarmTime.minute);
      }
      return a.alarmTime.hour.compareTo(b.alarmTime.hour);
    });
    print("loadAlarms Finish");
  }


  Future<void> saveAlarms(List<AlarmCard> alarms) async {
    print('saveAlarms alarm: $alarms');
    await initPrefs();
    prefs = await SharedPreferences.getInstance();

    final alarmsJson = alarms.map((alarm) {
      return _formatTime(alarm.alarmTime);
    }).toList();

    final switchValuesJson = alarms.map((alarm) {
      return alarm.switchValue.toString();
    }).toList();

    final linkAlarmsTimeJson = alarms.map((alarm) {
      return alarm.linkAlarmTime?.map((time) {
        return _formatTime(time);
      }).toList() ?? [];
    }).toList();

    final linkSwitchValueJson = alarms.map((alarm) {
      return alarm.linkSwitchValue?.toString() ?? "";
    }).toList();

    // final weekdaysValuesJson = alarms.map((alarm) {
    //   return alarm.weekdaysValues ?? [];
    // }).toList();

    await prefs.setStringList('alarms', alarmsJson);
    await prefs.setStringList('switchValues', switchValuesJson);
    final flattenedAlarmsLinkJson = linkAlarmsTimeJson.expand((list) => list).toList();
    await prefs.setStringList('alarmsLinks', flattenedAlarmsLinkJson);
    await prefs.setStringList('switchValuesLinks', linkSwitchValueJson);
    // await _prefs.setStringList('weekdaysValues', weekdaysValuesJson.cast());
    print("saveAlarms Finish");
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod.toString().padLeft(2, "0");
    final minute = time.minute.toString().padLeft(2, "0");
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return "$hour:$minute $period";
  }
}
