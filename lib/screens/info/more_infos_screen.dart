import 'package:flutter/material.dart';
import '../../widgets/markdown_viewer.dart';
import '../../widgets/scaffold_with_wide_bottom_panel.dart';

class MoreInfoScreen extends StatelessWidget {
  const MoreInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScaffoldWithWideBottomPanel(
      isScrollable: true,
      body: const MarkdownViewer(
        assetPath: 'assets/markdowns/more_infos.md',
        imageWidth: 100,
        imageHeight: 100,
      ),
    );
  }
}
