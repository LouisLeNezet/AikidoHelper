import 'package:flutter/material.dart';

class CenteredActionScreenLayout extends StatelessWidget {
  final Widget center;
  final Widget? bottom;

  const CenteredActionScreenLayout({
    super.key,
    required this.center,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Center(child: center),
        if (bottom != null)
          Positioned(
            left: 0,
            right: 0,
            bottom: 24,
            child: Center(child: bottom),
          ),
      ],
    );
  }
}
