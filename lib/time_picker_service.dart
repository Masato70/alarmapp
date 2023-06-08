import 'dart:convert';
import 'package:alarm_clock/preferences_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'alarm_card.dart';

class TimePickerService {
  late SharedPreferences _prefs;
  List<AlarmCard> _alarms = [];

  _timePicker(BuildContext context) async {
    _prefs = await SharedPreferences.getInstance();

    final TimeOfDay? timePicked = await showTimePicker(
        context: context, initialTime: TimeOfDay(hour: 6, minute: 0)
    );

    if (timePicked != null) {
      final String formatedTime = _formatTime(timePicked);

      //SharedPreferenceにセット & _alarmsリストに追加
      _prefs.setString("alarmTime", formatedTime);
      AlarmCard newAlarmCard = AlarmCard(
        id: _alarms.length,
        alarmTime: timePicked,
        switchValue: true,
      );
      _alarms.add(newAlarmCard);

      PreferencesService preferencesService = PreferencesService();
      await preferencesService._loadAlarms();
    }
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod.toString().padLeft(2, "0");
    final minute = time.minute.toString().padLeft(2, "0");
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return "$hour:$minute $period";
  }
}