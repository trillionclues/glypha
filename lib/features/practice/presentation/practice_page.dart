import 'package:flutter/material.dart';

class PracticePage extends StatelessWidget {
  static const String route = '/practice';
  const PracticePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lessons'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: const Center(
        child: Text('Lessons/Practice Page - Coming Soon'),
      ),
    );
  }
}
