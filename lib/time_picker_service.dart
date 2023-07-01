import 'dart:convert';
import 'package:alarm_clock/main.dart';
import 'package:alarm_clock/preferences_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'alarm_card.dart';
import 'package:uuid/uuid.dart';

class TimePickerService {

  Future<void> parentTimePicker(BuildContext context, List<AlarmCard> alarms) async {
    final TimeOfDay? timePicked = await showTimePicker(
        context: context, initialTime: TimeOfDay(hour: 6, minute: 0));

    if (timePicked != null) {
      var uuid = Uuid();
      var newId = uuid.v4();
      while (alarms.any((userData) => userData.id == newId)) {
        newId = uuid.v4();
      }

      AlarmCard newAlarmCard = AlarmCard(
        id: newId,
        isParent: true,
        alarmTime: timePicked,
        switchValue: true,
        // weekdaysValues:
      );
      print("parentTimePicker newCard $newAlarmCard");

      alarms.add(newAlarmCard);
      print('parentTimePicker alarms: $alarms');

      PreferencesService preferencesService = PreferencesService();
      await preferencesService.saveAlarms(alarms);
      await preferencesService.loadAlarms(alarms);

      // await preferencesService.loadAlarms(alarms);
    }
  }

  Future<void> childTimePicker(BuildContext context, int cardIndex, List<AlarmCard> alarms) async {
    final TimeOfDay? timePicked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: 6, minute: 0),
    );

    if (timePicked != null) {

      final AlarmCard selectedCard = alarms[cardIndex];
      final parentId = selectedCard.id;

      var uuid = Uuid();
      var childId = uuid.v4();
      while (alarms.any((userData) => userData.id == childId)) {
        childId = uuid.v4();
      }


      AlarmCard newAlarmCard = AlarmCard(
        id: parentId,
        isParent: false,
        childId: childId,
        alarmTime: timePicked,
        switchValue: true,
        // weekdaysValues:
      );
      print("childTimePicker newCard $newAlarmCard");

      alarms.add(newAlarmCard);
      print('childTimePicker alarms: $alarms');


      PreferencesService preferencesService = PreferencesService();
      await preferencesService.saveAlarms(alarms);
      // await preferencesService.loadAlarms(alarms);
    }
  }
}
