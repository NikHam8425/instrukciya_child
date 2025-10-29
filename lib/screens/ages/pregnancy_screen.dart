import 'package:flutter/material.dart';

class PregnancyScreen extends StatelessWidget {
  const PregnancyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Подготовка к родам')),
      body: const Center(child: Text('Контент для подготовки к родам')),
    );
  }
}
