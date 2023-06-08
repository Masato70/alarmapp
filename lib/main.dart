import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/cupertino.dart';
import 'package:weekday_selector/weekday_selector.dart';

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
  List<AlarmCard> _alarms = [];
  late SharedPreferences _prefs;

  @override
  void initState() {
    super.initState();
     _loadAlarms();
  }






  _timePickerLinks(BuildContext context, int cardIndex) async {
    _prefs = await SharedPreferences.getInstance();

    final TimeOfDay? timePicked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: 6, minute: 0),
    );

    if (timePicked != null) {
      print("Alarm added: ${_formatTime(timePicked)}");
      final String formattedTime = _formatTime(timePicked);

      // カードの情報を取得
      final AlarmCard selectedCard = _alarms[cardIndex];

      // alarmTimeLinksに新しい時間を追加
      final List<TimeOfDay> alarmTimeLinks = selectedCard.alarmTimeLinks ?? [];
      alarmTimeLinks.add(timePicked);

      // switchValueLinksに新しいスイッチの値を追加
      final List<bool> switchValueLinks = selectedCard.switchValueLinks ?? [];
      switchValueLinks.add(true);

      // カードの情報を更新
      selectedCard.alarmTimeLinks = alarmTimeLinks;
      selectedCard.switchValueLinks = switchValueLinks;

      // SharedPreferencesに保存
      await _saveAlarms();
      await _loadAlarms();

      setState(() {
        print("セット完了");
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black38,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text("目覚まし"),
      ),
      body: ListView.builder(
        itemCount: _alarms.length,
        itemBuilder: (BuildContext context, int index) {
          final alarm = _alarms[index];
          final switchValue = alarm.switchValue;
          final switchValueLinks = alarm.switchValueLinks ?? [];
          final weekdaysValues = alarm.weekdaysValues ?? [];

          return Card(
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
                              _formatTime(alarm.alarmTime),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: switchValue ? 50 : 49,
                                color: switchValue ? Colors.white : Colors.grey,
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
                            TextButton.icon(
                              onPressed: () {
                                _timePickerLinks(context, index);
                              },
                              icon: Icon(Icons.add),
                              label: Text("時間を追加する"),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: switchValue,
                        onChanged: (bool value) {
                          setState(() {
                            _alarms[index].switchValue = value;
                          });
                          _saveAlarms();
                        },
                      ),
                    ],
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: alarm.alarmTimeLinks?.length ?? 0,
                    itemBuilder: (BuildContext context, int linkIndex) {
                      final linksTime = alarm.alarmTimeLinks![linkIndex];
                      final linkSwitchValue = switchValueLinks[linkIndex];
                      return Row(
                        children: [
                          Expanded(
                            child: ListTile(
                              title: Text(
                                _formatTime(linksTime),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 30,
                                ),
                              ),
                            ),
                          ),
                          Switch(
                            value: linkSwitchValue,
                            onChanged: (bool value) {
                              setState(() {
                                _alarms[index].switchValueLinks![linkIndex] = value;
                              });
                              _saveAlarms();
                            },
                          ),
                        ],
                      );
                    },
                  ),
                ],
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
              _timePicker(context);
            },
            backgroundColor: Colors.cyan,
            child: Icon(Icons.add),
          ),
        ),
      ),
    );
  }

}
