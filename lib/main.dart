import 'dart:convert';
import 'dart:math';
import 'package:alarm_clock/preferences_service.dart';
import 'package:alarm_clock/time_picker_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/cupertino.dart';
import 'package:alarm_clock/alarm_card.dart'; // alarm_card.dartファイルのインポート
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
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
  List<AlarmCard> alarms = [];

  @override
  void initState() {
    super.initState();
    PreferencesService preferencesService = PreferencesService();
    preferencesService.loadAlarms(alarms);
  }

  @override
  Widget build(BuildContext context) {
    PreferencesService preferencesService = PreferencesService();
    TimePickerService timePickerService = TimePickerService();
    print("main: $alarms");
    return Scaffold(
      backgroundColor: Colors.black38,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text("目覚まし"),
      ),
      // body: ListView.builder(
      //   itemCount: alarms.length,
      //   itemBuilder: (BuildContext context, int index) {
      //     final alarm = alarms[index];
      //     final switchValue = alarm.switchValue;
      //     // final weekdaysValues = alarm.weekdaysValues ?? [];
      //
      //     return Card(
      //       color: Colors.grey.shade900,
      //       child: Padding(
      //         padding: EdgeInsets.all(35),
      //         child: Column(
      //           children: [
      //             Row(
      //               children: [
      //                 Expanded(
      //                   child: Column(
      //                     crossAxisAlignment: CrossAxisAlignment.start,
      //                     children: [
      //                       //親アラーム時間
      //                       Text(
      //                         _formatTime(alarm.alarmTime),
      //                         style: TextStyle(
      //                           fontWeight: FontWeight.bold,
      //                           fontSize: switchValue ? 50 : 49,
      //                           color: switchValue ? Colors.white : Colors.grey,
      //                         ),
      //                       ),
      //                       // WeekdaySelector(
      //                       //   onChanged: (int day) {
      //                       //     setState(() {
      //                       //       final index = day % 7;
      //                       //       weekdaysValues[index] = !weekdaysValues[index];
      //                       //     });
      //                       //     _saveAlarms();
      //                       //   },
      //                       //   values: weekdaysValues,
      //                       // ),
      //                       TextButton.icon(
      //                         onPressed: () {
      //                           timePickerService.childTimePicker(
      //                               context, index);
      //                         },
      //                         icon: Icon(Icons.add),
      //                         label: Text("時間を追加する"),
      //                       ),
      //                     ],
      //                   ),
      //                 ),
      //                 Switch(
      //                   value: switchValue,
      //                   onChanged: (bool value) {
      //                     setState(() {
      //                       alarms[index].switchValue = value;
      //                     });
      //                     preferencesService.saveAlarms(alarms);
      //                   },
      //                 ),
      //               ],
      //             ),
      //             ListView.builder(
      //               shrinkWrap: true,
      //               physics: NeverScrollableScrollPhysics(),
      //               itemCount: alarm.linkAlarmTime?.length ?? 0,
      //               itemBuilder: (BuildContext context, int linkIndex) {
      //                 final linksTime = alarm.linkAlarmTime![linkIndex];
      //                 final linkSwitchValue = switchValueLinks[linkIndex];
      //                 return Row(
      //                   children: [
      //                     Expanded(
      //                       child: ListTile(
      //                         title: Text(
      //                           _formatTime(linksTime),
      //                           style: TextStyle(
      //                             color: Colors.white,
      //                             fontSize: 30,
      //                           ),
      //                         ),
      //                       ),
      //                     ),
      //                     Switch(
      //                       value: linkSwitchValue,
      //                       onChanged: (bool value) {
      //                         setState(() {
      //                           alarms[index].linkSwitchValue![linkIndex] =
      //                               value;
      //                         });
      //                         preferencesService;
      //                       },
      //                     ),
      //                   ],
      //                 );
      //               },
      //             ),
      //           ],
      //         ),
      //       ),
      //     );
      //   },
      // ),
      bottomNavigationBar: Container(
        height: 100,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: FloatingActionButton.large(
            onPressed: () {
              timePickerService.parentTimePicker(context, alarms);
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
