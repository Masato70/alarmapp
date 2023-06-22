import 'dart:convert';
import 'package:alarm_clock/main.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'alarm_card.dart';
import 'package:sqflite/sqflite.dart';


class PreferencesService {
  late SharedPreferences prefs;

  Future<Stream<List<AlarmCard>>> loadAlarms(List<AlarmCard> alarms) async {
    prefs = await SharedPreferences.getInstance();
    print('loadAlarms alarmls: $alarms');
    print("aa ${prefs.getStringList('alarmCards') ?? []}");
    final alarmCardsJson = prefs.getStringList('alarmCards') ?? [];


    final alarmCards = alarmCardsJson.map((json) {
      // final alarmList = alarms.map((alarm) {
      // final data = alarm.toJson();
      final data = jsonDecode(json);

      final alarmCardID = data['id'];

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
        id: alarmCardID,
        alarmTime: alarmTime,
        switchValue: switchValue,
        linkAlarmTime: linkAlarmTime,
        linkSwitchValue: linkSwitchValue,
      );
    }).toList();

    print("ii $alarmCards");
    alarms.clear();
    alarms.addAll(alarmCards);
    alarms.sort((a, b) {
      if (a.alarmTime.hour == b.alarmTime.hour) {
        return a.alarmTime.minute.compareTo(b.alarmTime.minute);
      }
      return a.alarmTime.hour.compareTo(b.alarmTime.hour);
    });

    print('alarms check $alarms');
    await prefs.getStringList('cardID');


    print("loadAlarms Finish");
    return Stream.value(alarms);

  }


  Future<void> saveAlarms(List<AlarmCard> alarms) async {
    print('saveAlarms alarm: $alarms');
    prefs = await SharedPreferences.getInstance();

    final alarmCardsJson = alarms.map((alarm) {
      return jsonEncode(alarm.toJson());
    }).toList();

    final alarmCardID = alarms.map((alarm) {
      return alarm.id;
    }).toList();

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


    await prefs.setStringList('alarmCards', alarmCardsJson);
    await prefs.setStringList('cardID', alarmCardID);
    await prefs.setStringList('alarms', alarmsJson);
    await prefs.setStringList('switchValues', switchValuesJson);
    final flattenedAlarmsLinkJson = linkAlarmsTimeJson.expand((list) => list).toList();
    await prefs.setStringList('alarmsLinks', flattenedAlarmsLinkJson);
    await prefs.setStringList('switchValuesLinks', linkSwitchValueJson);
    // await prefs.setStringList('weekdaysValues', weekdaysValuesJson.cast());

    print(alarmCardID);
    print("saveAlarms Finish");
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod.toString().padLeft(2, "0");
    final minute = time.minute.toString().padLeft(2, "0");
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return "$hour:$minute $period";
  }
}
