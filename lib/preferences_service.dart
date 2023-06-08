import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'alarm_card.dart';

class PreferencesService {
  late SharedPreferences _prefs;
  List<AlarmCard> _alarms = [];

  Future<void> _loadAlarms() async {
    _prefs = await SharedPreferences.getInstance();

    final alarmList = _alarms.map((alarm) {
      final data = alarm.toJson();

      final alarmTime = TimeOfDay(
        hour: data['alarmTime']['hour'],
        minute: data['alarmTime']['minute'],
      );

      final switchValue = data['switchValue'];

      final linkAlarmTime = (data['alarmTimeLinks'] as List<dynamic>?)?.map((linkData) {
        return TimeOfDay(
          hour: linkData['hour'],
          minute: linkData['minute'],
        );
      }).toList();

      final linkSwitchValue = (data['switchValueLinks'] as List<dynamic>?)?.map((value) {
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

    _alarms = alarmList;
    _alarms.sort((a, b) {
      if (a.alarmTime.hour == b.alarmTime.hour) {
        return a.alarmTime.minute.compareTo(b.alarmTime.minute);
      }
      return a.alarmTime.hour.compareTo(b.alarmTime.hour);
    });

    print("_loadAlarms Finish");
  }


  Future<void> _saveAlarms() async {

    final alarmsJson = _alarms.map((alarm) {
      return _formatTime(alarm.alarmTime);
    }).toList();

    final switchValuesJson = _alarms.map((alarm) {
      return alarm.switchValue.toString();
    }).toList();

    final linkAlarmsTimeJson = _alarms.map((alarm) {
      return alarm.linkAlarmTime?.map((time) {
        return _formatTime(time);
      }).toList() ?? [];
    }).toList();

    final linkSwitchValueJson = _alarms.map((alarm) {
      return alarm.linkSwitchValue?.toString() ?? "";
    }).toList();

    // final weekdaysValuesJson = _alarms.map((alarm) {
    //   return alarm.weekdaysValues ?? [];
    // }).toList();

    await _prefs.setStringList('alarms', alarmsJson);
    await _prefs.setStringList('switchValues', switchValuesJson);
    final flattenedAlarmsLinkJson = linkAlarmsTimeJson.expand((list) => list).toList();
    await _prefs.setStringList('alarmsLinks', flattenedAlarmsLinkJson);
    await _prefs.setStringList('switchValuesLinks', linkSwitchValueJson);
    // await _prefs.setStringList('weekdaysValues', weekdaysValuesJson.cast());
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod.toString().padLeft(2, "0");
    final minute = time.minute.toString().padLeft(2, "0");
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return "$hour:$minute $period";
  }
}
