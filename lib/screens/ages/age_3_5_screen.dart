import 'package:flutter/material.dart';

class Age3to5Screen extends StatelessWidget {
  const Age3to5Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('3–5 лет')),
      body: const Center(child: Text('Контент для 3–5 лет')),
    );
  }
}
