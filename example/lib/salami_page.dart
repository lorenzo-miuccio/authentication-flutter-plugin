import 'package:flutter/material.dart';

class SalamiPage extends StatelessWidget {
  const SalamiPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('This Salami is for you'),
      ),
      body: Center(child: Image.asset('assets/salami.jpg')),
    );
  }
}
