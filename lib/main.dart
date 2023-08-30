import 'dart:isolate';
import 'dart:ui';

import 'package:alarm_clock/alarm_data_service.dart';
import 'package:alarm_clock/alarm_manager.dart';
import 'package:alarm_clock/time_picker_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:alarm_clock/alarm_card.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';

List<AlarmCard> alarms = [];

@pragma('vm:entry-point')
void backgroundAlarmCallback() async {
  print("_backgroundAlarmCallbackよばれた");
  AlarmManager alarmManager = AlarmManager();
  if (!alarmManager.isAlarmRinging) {

    final String portName = 'myUniquePortName';
    final ReceivePort port = ReceivePort();
    IsolateNameServer.registerPortWithName(port.sendPort, portName);
    port.listen((message) async {
      if (message == "stop") {
        alarmManager.stopAlarmSound();
      }
    });

    alarmManager.checkAndTriggerAlarms();
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());

  const alarmId = 0;
  const duration = Duration(seconds: 10);
  AndroidAlarmManager.periodic(
    duration,
    alarmId,
    backgroundAlarmCallback,
    exact: true,
    wakeup: true,
    allowWhileIdle: true,
    rescheduleOnReboot: true,
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final AlarmManager alarmManager = AlarmManager();
    alarmManager.requestPermissions();

    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => AlarmPage();
}

class AlarmPage extends State<MyHomePage> {
  AlarmDataService alarmDataService = AlarmDataService();
  AlarmManager alarmManager = AlarmManager();

  @override
  void initState() {
    super.initState();
    AndroidAlarmManager.initialize();

    alarmDataService.loadAlarms(() {
      setState(() {});
    });

    // backgroundAlarmCallback();
    alarmManager.checkAndTriggerAlarms();
  }

  @override
  Widget build(BuildContext context) {
    AlarmDataService alarmDataService = AlarmDataService();
    TimePickerService timePickerService = TimePickerService();
    print("main: $alarms");
    return Scaffold(
      backgroundColor: Colors.black38,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text("アラーム"),
      ),
      body: ListView.builder(
        itemCount: alarms.where((alarm) => alarm.isParent).length,
        itemBuilder: (BuildContext context, int parentIndex) {
          final parentAlarms = alarms
              .where((alarm) => alarm.isParent)
              .toList()
              .elementAt(parentIndex);
          final switchValue = parentAlarms.switchValue;
          final childAlarms = alarms
              .where((alarm) => alarm.childId == parentAlarms.id)
              .toList();

          return Dismissible(
            key: UniqueKey(),
            direction: DismissDirection.startToEnd,
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.only(left: 20.0),
                child: Icon(Icons.delete, color: Colors.white),
              ),
            ),
            onDismissed: (direction) {
              setState(() {
                alarms.removeWhere((alarm) =>
                    alarm.id == parentAlarms.id ||
                    alarm.childId == parentAlarms.id);
              });
              alarmDataService.saveAlarms();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("削除しました")),
              );
            },
            child: Card(
              color: Colors.grey.shade900,
              child: Padding(
                padding: EdgeInsets.all(35),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _formatTime(parentAlarms.alarmTime),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: switchValue ? 50 : 49,
                                  color:
                                      switchValue ? Colors.white : Colors.grey,
                                ),
                              ),
                              // WeekdaySelector(
                              //   onChanged: (int day) {
                              //     setState(() {
                              //       final index = day % 7;
                              //       weekdaysValues[index] = !weekdaysValues[index];
                              //     });
                              //     _saveAlarms();
                              //   },
                              //   values: weekdaysValues,
                              // ),
                            ],
                          ),
                        ),
                        Transform.scale(
                          scale: 1.1,
                          child: Switch(
                            value: switchValue,
                            onChanged: (bool value) {
                              setState(() {
                                parentAlarms.switchValue = value;
                                if (value) {
                                  alarms
                                      .where((alarm) =>
                                          alarm.childId == parentAlarms.id)
                                      .forEach(
                                          (alarm) => alarm.switchValue = true);
                                } else {
                                  alarms
                                      .where((alarm) =>
                                          alarm.childId == parentAlarms.id)
                                      .forEach(
                                          (alarm) => alarm.switchValue = false);
                                }
                              });
                              alarmDataService.saveAlarms();
                            },
                          ),
                        )
                      ],
                    ),
                    Row(
                      children: [
                        TextButton.icon(
                          onPressed: () {
                            timePickerService.childTimePicker(
                              context,
                              parentIndex,
                              () {
                                setState(() {});
                              },
                            );
                          },
                          icon: Icon(Icons.add, color: Colors.blue),
                          // アイコンの色を白色に設定
                          label: Text("時間を追加する"),
                        ),
                      ],
                    ),
                    ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: childAlarms.length,
                        itemBuilder: (BuildContext context, int childIndex) {
                          final childAlarm = childAlarms[childIndex];
                          final childSwitchValue = childAlarm.switchValue;

                          return Dismissible(
                              key: UniqueKey(),
                              direction: DismissDirection.startToEnd,
                              background: Container(
                                color: Colors.red,
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding: EdgeInsets.only(left: 10.0),
                                  child:
                                      Icon(Icons.delete, color: Colors.white),
                                ),
                              ),
                              onDismissed: (direction) {
                                setState(() {
                                  alarms.removeWhere(
                                      (alarm) => alarm.id == childAlarm.id);
                                });
                                alarmDataService.saveAlarms();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("削除しました")),
                                );
                              },
                              child: Row(
                                children: [
                                  Expanded(
                                    child: ListTile(
                                      title: Text(
                                        _formatTime(childAlarm.alarmTime),
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                          color: childAlarm.switchValue
                                              ? Colors.white
                                              : Colors.grey,
                                          fontSize: 40,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Switch(
                                    value: childSwitchValue,
                                    onChanged: (bool value) {
                                      if (switchValue) {
                                        setState(() {
                                          childAlarm.switchValue = value;
                                        });
                                      }
                                      alarmDataService.saveAlarms();
                                    },
                                  ),
                                ],
                              ));
                        }),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: Container(
        height: 100,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: FloatingActionButton.large(
            onPressed: () {
              timePickerService.parentTimePicker(context, () {
                setState(() {});
              });
            },
            backgroundColor: Colors.cyan,
            child: Icon(Icons.add),
          ),
        ),
      ),
    );
  }
}

String _formatTime(TimeOfDay time) {
  final hour = time.hourOfPeriod.toString().padLeft(2, "0");
  final minute = time.minute.toString().padLeft(2, "0");
  final period = time.period == DayPeriod.am ? 'AM' : 'PM';
  return "$hour:$minute $period";
}
