import 'package:flutter/material.dart';
import '../../widgets/markdown_viewer.dart';

class MoreInfoScreen extends StatelessWidget {
  const MoreInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('More infos')),
      body: const MarkdownViewer(
        assetPath: 'assets/markdowns/more_infos.md',
        imageWidth: 100,
        imageHeight: 100,
      ),
    );
  }
}
