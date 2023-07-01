import 'dart:convert';
import 'dart:math';
import 'package:alarm_clock/main.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'alarm_card.dart';

class PreferencesService {
  late SharedPreferences prefs;

  Future<void> loadAlarms(List<AlarmCard> alarms) async {
    print("start loadAlarms");
    prefs = await SharedPreferences.getInstance();

    if (alarms != null && alarms.isNotEmpty) {
      //UIを更新するコードを書く
      print("alarms != null $alarms");


    } else if (alarms.isEmpty) {
      //SharedPreferencesから全て取得して、全てalarmsに収納
      //呼び出される時はアプリを開いた時のみ?
      //UIを更新
      print("alarms null");

      final getCardId = prefs.getStringList("cardID");
      final getIsParent = prefs.getStringList("isParent");
      final getChildId = prefs.getStringList("childId");
      final getAlarms = prefs.getStringList("alarmTime");
      final getSwitchValues = prefs.getStringList("switchValues");

      print("loadAlarms shared get $getChildId $getIsParent $getChildId $getAlarms $getSwitchValues");
      // final AlarmCards = AlarmCard(
      //   id: getCardId.toString(),
      //   isParent: getIsParent,
      //   childId: getChildId.toString(),
      //   alarmTime: getAlarms,
      //   switchValue: getSwitchValues,
      // );

      if(getCardId == null) {
        print("まだ何もSharedPreferencesに保存されていない");
      } {
      final AlarmCards = AlarmCard(
        id: getCardId.toString(),
        isParent: getIsParent != null ? getIsParent![0] == 'true' : false,
        childId: getChildId.toString(),
        alarmTime: TimeOfDay(
          hour: int.parse(getAlarms![0].split(':')[0]),
          minute: int.parse(getAlarms[0].split(':')[1]),
        ),
        switchValue: getSwitchValues != null ? getSwitchValues![0] == 'true' : false,
      );

      print("loadAlarms AlarmCard $AlarmCards");

      alarms.sort((a, b) {
        if (a.alarmTime.hour == b.alarmTime.hour) {
          return a.alarmTime.minute.compareTo(b.alarmTime.minute);
        }
        return a.alarmTime.hour.compareTo(b.alarmTime.hour);
      });

      alarms.clear();
      final alarmCards = [AlarmCards];
      alarms.addAll(alarmCards);
      print(alarms);

      }
    }

    // print("loadAlarms  ${prefs.getStringList('alarmCards') ?? []}");
    // final alarmCardsJson = prefs.getStringList('alarmCards') ?? [];
    //
    // final alarmCards = alarmCardsJson.map((json) {
    //   final data = jsonDecode(json);
    //
    //   final alarmCardID = data['id'];
    //   final isParent = data['isParent'];
    //
    //   final alarmTime = TimeOfDay(
    //     hour: data['alarmTime']['hour'],
    //     minute: data['alarmTime']['minute'],
    //   );
    //
    //   final switchValue = data['switchValue'];
    //
    //   final weekdaysValues = (data['weekdaysValues'] as List<dynamic>?)?.map((value) {
    //     return value as bool;
    //   }).toList();
    //
    // }).toList();

    // alarms.addAll(aa);
    print("loadAlarms Finish");
  }

  Future<void> saveAlarms(List<AlarmCard> alarms) async {
    print("start saveAlarms");
    prefs = await SharedPreferences.getInstance();

    // これなに・・・？
    // final alarmCardsJson = alarms.map((alarm) {
    //   return jsonEncode(alarm.toJson());
    // }).toList();

    final id = alarms.map((alarm) {
      return alarm.id;
    }).toList();

    final isParent = alarms.map((alarm) {
      return alarm.isParent.toString();
    }).toList();

    final childId = alarms.map((alarm) {
      return alarm.childId.toString();
    }).toList();

    final alarmTime = alarms.map((alarm) {
      return _formatTime(alarm.alarmTime);
    }).toList();

    final switchValues = alarms.map((alarm) {
      return alarm.switchValue.toString();
    }).toList();

    print("saveAlarms final check $id $isParent $childId $alarmTime $switchValues");

    // final weekdaysValuesJson = alarms.map((alarm) {
    //   return alarm.weekdaysValues ?? [];
    // }).toList();

    // await prefs.setStringList('alarmCards', alarmCardsJson);
    await prefs.setStringList('cardID', id);
    await prefs.setStringList('isParent', isParent);
    await prefs.setStringList('childId', childId);
    await prefs.setStringList('alarmTime', alarmTime);
    await prefs.setStringList('switchValues', switchValues);
    // await prefs.setStringList('weekdaysValues', weekdaysValuesJson.cast());

    print("saveAlarms Finish");
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod.toString().padLeft(2, "0");
    final minute = time.minute.toString().padLeft(2, "0");
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return "$hour:$minute $period";
  }
}
