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
  List<TimeOfDay> _alarms = [];
  List<TimeOfDay> _alarmsLinks = [];
  List<bool> _switchValues = [];
  List<bool> _switchValuesLinks = [];
  List<bool> _weekdaysValues = List.filled(7, false);

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
    final alarmsJson = _prefs.getStringList('alarms') ?? [];
    final alarmsLinkJson = _prefs.getStringList("alarmsLinks") ?? [];
    final switchValuesJson = _prefs.getStringList('switchValues') ?? [];
    final switchValues = switchValuesJson.map((json) => json == "true").toList();
    final switchValuesLinksJson = _prefs.getStringList('switchValuesLinks') ?? [];
    final switchValuesLinks = switchValuesLinksJson.map((json) => json == "true").toList();

    final weekdaysValuesJson = _prefs.getStringList("weekdaysValues") ?? List.filled(7, "false");
    final weekdaysValues = weekdaysValuesJson.map((json) => json == "true").toList();


    print("alarms Link ${alarmsLinkJson}");
    print("alarm ${alarmsJson}");

    setState(() {
      _alarms = alarmsJson.map((time) {
        final parts = time.split(':');
        return TimeOfDay(
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1]),
        );
      }).toList();

      _alarms.sort((a, b) {
        if (a.hour == b.hour) {
          return a.minute.compareTo(b.minute);
        }
        return a.hour.compareTo(b.hour);
      });

      _alarmsLinks = alarmsLinkJson.map((timeLinks) {
        final parts = timeLinks.split(":");
        return TimeOfDay(
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1]),
        );
      }).toList();

      _alarmsLinks.sort((a, b) {
        if(a.hour == b.hour) {
          return a.minute.compareTo(b.minute);
        }
        return a.hour.compareTo(b.hour);
      });

      _switchValues = switchValues.toList();
      while (_alarms.length > _switchValues.length) {
        _switchValues.add(true);
      }

      _switchValuesLinks = switchValuesLinks.toList();
      while (_alarmsLinks.length >  _switchValuesLinks.length) {
        _switchValuesLinks.add(true);
      }

      _weekdaysValues = weekdaysValues.toList();
    });
    print("_loadAlarms Finish");
  }

  Future<void> _saveAlarms() async {
    print("_saveAlarms Start");
    print(_weekdaysValues);
    final alarmsJson = _alarms.map((time) {
      return '${time.hour}:${time.minute}';
    }).toList();
    final switchValuesJson = _switchValues.map((value) {
      return value.toString();
    }).toList();
    final alarmsLinkJson = _alarmsLinks.map((timeLinks) {
      return "${timeLinks.hour}:${timeLinks.minute}";
    }).toList();
    final switchValuesLinksJson = _switchValuesLinks.map((value) {
      return value.toString();
    }).toList();
    final weekdaysVluesJson = _weekdaysValues.map((value) {
      return value.toString();
    }).toList();

    await _prefs.setStringList('alarms', alarmsJson);
    await _prefs.setStringList("alarmsLinks", alarmsLinkJson);
    await _prefs.setStringList("switchValues", switchValuesJson);
    await _prefs.setStringList("switchValuesLinks", switchValuesLinksJson);
    await _prefs.setStringList("weekdaysValues", weekdaysVluesJson);
    print("_saveAlarms Finish");
  }

  _timePicker(BuildContext context) async {
    final TimeOfDay? timePicked = await showTimePicker(
        context: context, initialTime: TimeOfDay(hour: 6, minute: 0));
    if (timePicked != null) {
      print("Alarm added: ${_formatTime(timePicked)}");
      setState(() {
        _alarms.add(timePicked);
        _switchValues.add(true);
        // _weekdaysValues.add(false);
        print("セット完了");
      });
      print("次の処理");
      await _saveAlarms();
      await _loadAlarms();
    }
  }

  _timePickerLinks(BuildContext context) async {
    final TimeOfDay? timePicked = await showTimePicker(
        context: context, initialTime: TimeOfDay(hour: 6, minute: 0));
    if (timePicked != null) {
      print("Alarm link added: ${_formatTime(timePicked)}");
      setState(() {
        _alarmsLinks.add(timePicked);
        _switchValuesLinks.add(true);
      });
      await _saveAlarms();
      await _loadAlarms();
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
          final time = _alarms[index];
          final switchValue = _switchValues[index];
          final switchValueLinks = _switchValuesLinks.length > index ? _switchValuesLinks[index] : false;
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
                              _formatTime(time),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: switchValue ? 50 : 49,
                                color: switchValue ? Colors.white : Colors.grey,
                              ),
                            ),
                            WeekdaySelector(
                              onChanged: (int day) {
                                setState(() {
                                  final index = day % 7;
                                  _weekdaysValues[index] = !_weekdaysValues[index];
                                });
                                _saveAlarms();
                              },
                              values: _weekdaysValues,
                            ),
                            TextButton.icon(
                              onPressed: () {
                                _timePickerLinks(context);
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
                            _switchValues[index] = value;
                          });
                          _saveAlarms();
                        },
                      ),
                    ],
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: _alarmsLinks.length,
                    itemBuilder: (BuildContext context, int linkIndex) {
                      final linksTime = _alarmsLinks[linkIndex];
                      final linkSwitchValue = _switchValuesLinks[linkIndex];
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
                                _switchValuesLinks[linkIndex] = value;
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
