import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:salami_unlock/salami_unlock.dart';
import 'package:salami_unlock_example/salami_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  final _salamiUnlockPlugin = SalamiUnlock();

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      platformVersion =
          await _salamiUnlockPlugin.getPlatformVersion() ?? 'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  void _authCallback(bool authResult) {
    authResult ? Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => const SalamiPage())) : ScaffoldMessenger
        .of(
        context).showSnackBar(const SnackBar(content: Text('error')));
  }

  Future<void> _requireAuth() => _salamiUnlockPlugin.require(message: 'Unlock to get a present', onResult: _authCallback);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            children: [
              Text('Running on: $_platformVersion\n'),
              ElevatedButton(
                  onPressed: _requireAuth,
                  child: const Text('unlock'))
            ],
          ),
        ),
      ),
    );
  }
}
