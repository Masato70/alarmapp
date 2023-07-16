
import 'package:alarm_clock/alarm_data_service.dart';
import 'package:flutter/material.dart';
import 'alarm_card.dart';
import 'package:uuid/uuid.dart';

class TimePickerService {
  Future<void> parentTimePicker(
      BuildContext context, List<AlarmCard> alarms, Function callback) async {
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

      AlarmDataService alarmDataService = AlarmDataService();
      await alarmDataService.saveAlarms(alarms);
      await alarmDataService.loadAlarms(alarms, callback);
    }
  }

  Future<void> childTimePicker(BuildContext context, int cardIndex,
      List<AlarmCard> alarms, Function callback) async {
    final TimeOfDay? timePicked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: 6, minute: 0),
    );

    if (timePicked != null) {
      final List<AlarmCard> parentAlarms = alarms.where((alarm) => alarm.isParent).toList();
      final AlarmCard selectedCard = parentAlarms[cardIndex];
      final parentId = selectedCard.id;

      print(alarms[cardIndex]);
      print(parentId);

      var uuid = Uuid();
      var cardID = uuid.v4();
      while (alarms.any((userData) => userData.id == cardID)) {
        cardID = uuid.v4();
      }

      AlarmCard newAlarmCard = AlarmCard(
        id: cardID,
        isParent: false,
        childId: parentId,
        alarmTime: timePicked,
        switchValue: true,
        // weekdaysValues:
      );
      print("childTimePicker newCard $newAlarmCard");

      alarms.add(newAlarmCard);
      print('childTimePicker alarms: $alarms');

      AlarmDataService alarmDataService = AlarmDataService();
      await alarmDataService.saveAlarms(alarms);
      await alarmDataService.loadAlarms(alarms, callback);
    }
  }
}
