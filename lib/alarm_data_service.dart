import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'alarm_card.dart';

class AlarmDataService {
  late SharedPreferences prefs;

  Future<void> loadAlarms(List<AlarmCard> alarms, Function callback) async {
    print("start loadAlarms");
    prefs = await SharedPreferences.getInstance();

    if (alarms != null && alarms.isNotEmpty) {
      sortAlarms(alarms);
      callback();
      print("alarms != null $alarms");
    } else if (alarms.isEmpty) {
      //呼び出される時はアプリを開いた時のみ
      print("alarms null");
      final alarmCards = await getAlarmCardsFromSharedPreferences();
      sortAlarms(alarmCards);
      alarms.clear();
      alarms.addAll(alarmCards);
      print(alarms);
      callback();
    }
    print("loadAlarms Finish");
  }

  Future<List<AlarmCard>> getAlarmCardsFromSharedPreferences() async {
    final getCardId = prefs.getStringList("cardID");
    final getIsParent = prefs.getStringList("isParent");
    final getChildId = prefs.getStringList("childId");
    final getAlarms = prefs.getStringList("alarmTime");
    final getSwitchValues = prefs.getStringList("switchValues");

    print("loadAlarms shared get $getCardId $getIsParent $getChildId $getAlarms $getSwitchValues");

    if (getCardId != null && getIsParent != null && getChildId != null && getAlarms != null && getSwitchValues != null) {
      final alarmCards = getCardId.map((cardId) {
        final index = getCardId.indexOf(cardId);
        final isParent = getIsParent[index] == 'true';
        final childId = getChildId[index];

        final alarmTimeString = getAlarms[index].replaceAll('TimeOfDay(', '').replaceAll(')', '');
        final alarmTimeParts = alarmTimeString.split(':');
        final hour = int.parse(alarmTimeParts[0]);
        final minute = int.parse(alarmTimeParts[1].split(' ')[0]);
        final alarmTime = TimeOfDay(hour: hour, minute: minute);
        final switchValue = getSwitchValues[index] == 'true';

        return AlarmCard(
          id: cardId,
          isParent: isParent,
          childId: childId,
          alarmTime: alarmTime,
          switchValue: switchValue,
        );
      }).toList();

      return alarmCards;
    }
    // デフォルトの空リストを返す
    return [];
  }

  void sortAlarms(List<AlarmCard> alarms) {
    alarms.sort((a, b) {
      if (a.alarmTime.hour == b.alarmTime.hour) {
        return a.alarmTime.minute.compareTo(b.alarmTime.minute);
      }
      return a.alarmTime.hour.compareTo(b.alarmTime.hour);
    });
  }

  Future<void> saveAlarms(List<AlarmCard> alarms) async {
    print("start saveAlarms");
    prefs = await SharedPreferences.getInstance();

    final id = alarms.map((alarm) => alarm.id.toString()).toList();
    final isParent = alarms.map((alarm) => alarm.isParent.toString()).toList();
    final childId = alarms.map((alarm) => alarm.childId.toString()).toList();
    final alarmTime = alarms.map((alarm) => alarm.alarmTime.toString()).toList();
    final switchValues = alarms.map((alarm) => alarm.switchValue.toString()).toList();

    print("saveAlarms final check $id $isParent $childId $alarmTime $switchValues");

    await prefs.setStringList('cardID', id);
    await prefs.setStringList('isParent', isParent);
    await prefs.setStringList('childId', childId);
    await prefs.setStringList('alarmTime', alarmTime);
    await prefs.setStringList('switchValues', switchValues);
    // await prefs.setStringList('weekdaysValues', weekdaysValuesJson);

    print("saveAlarms Finish");
  }
}