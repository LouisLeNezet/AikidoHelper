import 'package:flutter/material.dart';

class CenteredScreenLayout extends StatelessWidget {
  final Widget child;
  final Widget? bottom;
  final EdgeInsets padding;

  const CenteredScreenLayout({
    super.key,
    required this.child,
    this.bottom,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            // CONTENT (always bounded)
            SizedBox(
              width: constraints.maxWidth,
              height: constraints.maxHeight,
              child: Padding(
                padding: padding,
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: SingleChildScrollView(
                      child: child,
                    ),
                  ),
                ),
              ),
            ),

            // BOTTOM BAR (safe because Stack now has finite size)
            if (bottom != null)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: SafeArea(
                  top: false,
                  child: bottom!,
                ),
              ),
          ],
        );
      },
    );
  }
}
