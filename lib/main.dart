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

class AlarmCard {
  int id;
  TimeOfDay alarmTime;
  bool switchValue;
  List<TimeOfDay>? alarmTimeLinks;
  List<bool>? switchValueLinks;
  List<bool>? weekdaysValues;

  AlarmCard({
    required this.id,
    required this.alarmTime,
    required this.switchValue,
    this.alarmTimeLinks,
    this.switchValueLinks,
    this.weekdaysValues,
  });

  Map<String, dynamic> toJson() {
    return {
      'id' : id,
      'alarmTime': {
        'hour': alarmTime.hour,
        'minute': alarmTime.minute,
      },
      'switchValue': switchValue,
      'alarmTimeLinks': alarmTimeLinks?.map((time) => {
        'hour': time.hour,
        'minute': time.minute,
      }).toList(),
      'switchValueLinks': switchValueLinks,
      'weekdaysValues': weekdaysValues,
    };
  }
}

class AlarmPage extends State<MyHomePage> {
  List<AlarmCard> _alarms = [];
  late SharedPreferences _prefs;

  @override
  void initState() {
    super.initState();
    _initPrefs();
    print("_initPrefs called");
  }

  Future<void> _initPrefs() async {
    _loadAlarms();
  }

  //アプリ開いたらまずココ
  Future<void> _loadAlarms() async {
    print("_loadAlarms Start");
    _prefs = await SharedPreferences.getInstance();

    final alarmList = _alarms.map((json) {
      final data = jsonDecode(json as String);
      final alarmTime = TimeOfDay(
        hour: data['alarmTime']['hour'],
        minute: data['alarmTime']['minute'],
      );

      final alarmTimeLinks = (data['alarmTimeLinks'] as List<dynamic>?)?.map((linkData) {
        return TimeOfDay(
          hour: linkData['hour'],
          minute: linkData['minute'],
        );
      }).toList();

      final switchValue = data['switchValue'];

      final switchValueLinks = (data['switchValueLinks'] as List<dynamic>?)?.map((value) {
        return value as bool;
      }).toList();

      final weekdaysValues = (data['weekdaysValues'] as List<dynamic>?)?.map((value) {
        return value as bool;
      }).toList();

      return AlarmCard(
        id: data['id'],
        alarmTime: alarmTime,
        switchValue: switchValue,
        alarmTimeLinks: alarmTimeLinks,
        switchValueLinks: switchValueLinks,
        weekdaysValues: weekdaysValues,
      );
    }).toList();

    setState(() {
      _alarms = alarmList;

      _alarms.sort((a, b) {
        if (a.alarmTime.hour == b.alarmTime.hour) {
          return a.alarmTime.minute.compareTo(b.alarmTime.minute);
        }
        return a.alarmTime.hour.compareTo(b.alarmTime.hour);
      });
    });
    print("_loadAlarms Finish");
  }

  Future<void> _saveAlarms() async {
    print("_saveAlarms Start");
    _prefs = await SharedPreferences.getInstance();
    print("1");

    final alarmsJson = _alarms.map((alarm) {
      print("alarmsJson Start");
      return '${alarm.alarmTime.hour}:${alarm.alarmTime.minute}';
    }).toList();

    print("2");

    final switchValuesJson = _alarms.map((alarm) {
      return alarm.switchValue.toString();
    }).toList();

    final alarmsLinkJson = _alarms.map((alarm) {
      print("alarmsLinkJson Start");
      return alarm.alarmTimeLinks?.map((time) {
        return '${time.hour}:${time.minute}';
      }).toList() ?? [];
    }).toList();

    final switchValuesLinksJson = _alarms.map((alarm) {
      return alarm.switchValueLinks?.toString() ?? "";
    }).toList();

    final weekdaysValuesJson = _alarms.map((alarm) {
      return alarm.weekdaysValues ?? [];
    }).toList();
    
    print("4");
    await _prefs.setStringList('alarms', alarmsJson);
    print("5");
    await _prefs.setStringList('switchValues', switchValuesJson);
    print("6");
    print(alarmsLinkJson);
    final flattenedAlarmsLinkJson = alarmsLinkJson.expand((list) => list).toList();
    await _prefs.setStringList('alarmsLinks', flattenedAlarmsLinkJson);
    print("7");
    await _prefs.setStringList('switchValuesLinks', switchValuesLinksJson);
    print("8");
    await _prefs.setStringList('weekdaysValues', weekdaysValuesJson.cast());
    print("_saveAlarms finish");
  }


  _timePicker(BuildContext context) async {
    _prefs = await SharedPreferences.getInstance();

    final TimeOfDay? timePicked = await showTimePicker(
        context: context, initialTime: TimeOfDay(hour: 6, minute: 0)
    );

    if (timePicked != null) {
      print("Alarm added: ${_formatTime(timePicked)}");
      final String formatedTime = _formatTime(timePicked);
      //SharedPreferenceにセット & _alarmsリストに追加
      _prefs.setString("alarmTime", formatedTime);
      AlarmCard newAlarmCard = AlarmCard(
        id: _alarms.length,
        alarmTime: timePicked,
        switchValue: true,
      );
      _alarms.add(newAlarmCard);

      setState(() {
        print("セット完了");
      });
      await _saveAlarms();
      await _loadAlarms();
    }
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
  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod.toString().padLeft(2, "0");
    final minute = time.minute.toString().padLeft(2, "0");
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return "$hour:$minute $period";
  }
}
