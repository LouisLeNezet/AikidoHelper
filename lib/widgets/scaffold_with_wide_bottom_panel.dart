import 'package:flutter/material.dart';
import '../../widgets/wide_bottom_panel.dart';
import '../../widgets/custom_app_bar.dart';

class ScaffoldWithWideBottomPanel extends StatelessWidget {
  final PreferredSizeWidget appBar;
  final Widget body;
  final bool isScrollable;
  final bool showWidePanel;

  const ScaffoldWithWideBottomPanel({
    super.key,
    this.appBar = const CustomAppBar(),
    required this.body,
    this.isScrollable = false,
    this.showWidePanel = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: showWidePanel ? 140 : 0),
            child: isScrollable
                ? SingleChildScrollView(child: body)
                : body,
          ),
          if (showWidePanel)
            const Positioned(
              left: 32,
              right: 32,
              bottom: 40,
              child: WideBottomPanel(),
            ),
        ],
      ),
    );
  }
}
