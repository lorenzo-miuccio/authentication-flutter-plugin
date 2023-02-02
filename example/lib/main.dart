import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:salami_unlock/salami_unlock.dart';
import 'package:salami_unlock_example/salami_page.dart';
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
        body: Center(
          child: UnlockButton(),
        ),
      ),
    );
  }
}
