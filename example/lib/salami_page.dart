import 'package:flutter/material.dart';

class SalamiPage extends StatelessWidget {
  const SalamiPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Beccate sto salame'),
      ),
      body: Center(child: Image.asset('assets/salami.jpg')),
    );
  }
}
