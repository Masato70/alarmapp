import 'package:flutter/material.dart';

class AlarmStopScreen extends StatelessWidget {
  AlarmStopScreen(void Function() stopSound);

  @override
  Widget build(BuildContext context) {
    print("すとっぷがめん！！");
    return Scaffold(
      appBar: AppBar(
        title: Text("ああ"),
      ),
    );
  }
}