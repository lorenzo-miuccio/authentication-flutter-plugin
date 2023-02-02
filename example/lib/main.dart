import 'package:flutter/material.dart';
import 'package:salami_unlock_example/unlock_button.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: const Center(
          child: UnlockButton(),
        ),
      ),
    );
  }
}
