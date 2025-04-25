import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';

class MarkdownViewer extends StatelessWidget {
  final String assetPath;
  final double imageWidth;
  final double imageHeight;

  const MarkdownViewer({
    super.key,
    required this.assetPath,
    required this.imageWidth,
    required this.imageHeight,
  });

  Future<String> _loadMarkdown() async {
    try {
      return await rootBundle.loadString(assetPath);
    } catch (e) {
      return 'Error loading markdown file: $e';
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _loadMarkdown(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError || !snapshot.hasData) {
          return Center(child: Text('Failed to load markdown.'));
        } else {
          return Markdown(
            data: snapshot.data!,
            onTapLink: (text, href, title) async {
              if (href != null) {
                final uri = Uri.parse(href);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Could not launch $href')),
                  );
                }
              }
            },
            imageBuilder: (uri, title, alt) {
              return Center(
                child: Image.asset(
                  uri.toString(),
                  width: imageWidth,
                  height: imageHeight,
                ),
              );
            },
            styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
              p: const TextStyle(fontSize: 16),
            ),
          );
        }
      },
    );
  }
}
