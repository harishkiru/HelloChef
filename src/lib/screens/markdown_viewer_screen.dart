import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter/material.dart';

class MarkdownViewerScreen extends StatelessWidget {
  final String markdown;

  const MarkdownViewerScreen({super.key, required this.markdown});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Markdown Viewer')),
      body: Markdown(data: markdown),
    );
  }
}
