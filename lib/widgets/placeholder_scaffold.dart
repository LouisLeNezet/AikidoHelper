import 'package:flutter/material.dart';

class PlaceholderScaffold extends StatelessWidget {
  final String title;
  const PlaceholderScaffold({required this.title, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text(
          title,
          style: const TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
