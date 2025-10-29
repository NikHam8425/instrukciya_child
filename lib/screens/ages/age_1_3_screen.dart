import 'package:flutter/material.dart';

class Age1to3Screen extends StatelessWidget {
  const Age1to3Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('1–3 года')),
      body: const Center(child: Text('Контент для 1–3 лет')),
    );
  }
}
