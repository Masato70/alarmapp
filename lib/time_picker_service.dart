import 'dart:convert';
import 'package:alarm_clock/main.dart';
import 'package:alarm_clock/preferences_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'alarm_card.dart';

class TimePickerService {
  List<AlarmCard> alarms = [];

  Future<void> timePicker(BuildContext context, List<AlarmCard> alarms) async {
    final TimeOfDay? timePicked = await showTimePicker(
        context: context, initialTime: TimeOfDay(hour: 6, minute: 0)
    );

    if (timePicked != null) {
      //_alarmsリストに追加
      AlarmCard newAlarmCard = AlarmCard(
        id: alarms.length.toString(),
        alarmTime: timePicked,
        switchValue: true,
        // weekdaysValues:
      );
      print(newAlarmCard);
      alarms.add(newAlarmCard);

      print('timePicker time: $alarms');
      PreferencesService preferencesService = PreferencesService();
      await preferencesService.saveAlarms(alarms);
      await preferencesService.loadAlarms(alarms);
    }
  }

  Future<void> timePickerLinks(BuildContext context, int cardIndex) async {
    final TimeOfDay? timePicked = await showTimePicker(
      context: context, initialTime: TimeOfDay(hour: 6, minute: 0),
    );

    if (timePicked != null) {
      final AlarmCard selectedCard = alarms[cardIndex];

      final List<TimeOfDay> alarmTimeLinks = selectedCard.linkAlarmTime ?? [];
      alarmTimeLinks.add(timePicked);

      final List<bool> switchValueLinks = selectedCard.linkSwitchValue ?? [];
      switchValueLinks.add(true);

      selectedCard.linkAlarmTime = alarmTimeLinks;
      selectedCard.linkSwitchValue = switchValueLinks;

      print('timePickerLinks time: $alarms');
      PreferencesService preferencesService = PreferencesService();
      await preferencesService.saveAlarms(alarms);
      await preferencesService.loadAlarms(alarms);
    }
  }
}