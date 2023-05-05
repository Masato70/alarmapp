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

  late SharedPreferences _prefs;

  @override
  void initState() {
    super.initState();
    _loadAlarms();
  }

  Future<void> _loadAlarms() async {
    _prefs = await SharedPreferences.getInstance();
    final alarmsJson = _prefs.getStringList('alarms') ?? [];
    setState(() {
      _alarms = alarmsJson.map((time) {
        final parts = time.split(':');
        return TimeOfDay(
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1]),
        );
      }).toList();
    });
  }

  Future<void> _saveAlarms() async {
    final alarmsJson = _alarms.map((time) {
      return '${time.hour}:${time.minute}';
    }).toList();
    await _prefs.setStringList('alarms', alarmsJson);
  }

  _timePicker(BuildContext context) async {
    final TimeOfDay? timePicked = await showTimePicker(
        context: context, initialTime: TimeOfDay(hour: 6, minute: 0));
    if (timePicked != null) {
      setState(() {
        _alarms.add(timePicked);
      });
      await _saveAlarms();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black12,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text("アラーム"),
      ),
      body: ListView.builder(
        itemCount: _alarms.length,
        itemBuilder: (BuildContext context, int index) {
          final time = _alarms[index];
          return Card(
            child: ListTile(
              title: Text(_formatTime(time)),
            ),
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
