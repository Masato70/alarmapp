import 'package:flutter/material.dart';

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
  _timePicker(BuildContext context) async {
    final TimeOfDay? timePicked = await showTimePicker(
        context: context, initialTime: const TimeOfDay(hour: 6, minute: 0));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black12,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("アラーム"),
      ),
      body: Column(),
      floatingActionButton: FloatingActionButton.large(
        onPressed: () {
          _timePicker(context);
        },
        backgroundColor: Colors.cyan,
        child: const Icon(Icons.add),
      ),
    );
  }
}
