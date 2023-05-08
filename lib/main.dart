import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  List<bool> _switchValues = [];
  late SharedPreferences _prefs;

  @override
  void initState() {
    super.initState();
    _initPrefs();
  }

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    _loadAlarms();
  }

  Future<void> _loadAlarms() async {
    print("_loadAlarms called");
    _prefs = await SharedPreferences.getInstance();
    final alarmsJson = _prefs.getStringList('alarms') ?? [];
    final switchValuesJson = _prefs.getStringList('switchValues') ?? [];
    final switchValues =
        switchValuesJson.map((json) => json == "true").toList();

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

      _switchValues = switchValues.toList();
      while (_alarms.length > _switchValues.length) {
        _switchValues.add(true);
      }
    });
  }

  Future<void> _saveAlarms() async {
    final alarmsJson = _alarms.map((time) {
      return '${time.hour}:${time.minute}';
    }).toList();
    final switchValuesJson = _switchValues.map((value) {
      return value.toString();
    }).toList();
    await _prefs.setStringList('alarms', alarmsJson);
    await _prefs.setStringList("switchValues", switchValuesJson);
  }

  _timePicker(BuildContext context) async {
    final TimeOfDay? timePicked = await showTimePicker(
        context: context, initialTime: TimeOfDay(hour: 6, minute: 0));
    if (timePicked != null) {
      print("Alarm added: ${_formatTime(timePicked)}");
      setState(() {
        _alarms.add(timePicked);
        _switchValues.add(true);
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
          return Card(
            color: Colors.grey.shade900,
            child: Padding(
                padding: EdgeInsets.all(36),
                child: Row(
                  children: [
                    Expanded(
                      child: ListTile(
                        title: Text(
                          _formatTime(time),
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: switchValue ? 32 : 30,
                              color: switchValue ? Colors.white : Colors.grey),
                        ),
                        trailing: Switch(
                          value: switchValue,
                          onChanged: (bool value) {
                            setState(() {
                              _switchValues[index] = value;
                            });
                            _saveAlarms();
                          },
                        ),
                      ),
                    )
                  ],
                )),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.large(
        onPressed: () {
          _timePicker(context);
        },
        backgroundColor: Colors.cyan,
        child: Icon(Icons.add),
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
