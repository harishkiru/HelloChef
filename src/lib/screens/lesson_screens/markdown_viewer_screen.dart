import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter/material.dart';
import 'package:src/classes/lesson_item.dart';

class MarkdownViewerScreen extends StatelessWidget {
  final String markdown;
  final LessonItem lessonItem;

  const MarkdownViewerScreen({
    super.key,
    required this.markdown,
    required this.lessonItem,
  });

  void _onComplete(context) {
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.green, actions: [
          
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Markdown(
                data: markdown,
                imageBuilder: (uri, title, alt) {
                  return Image.asset(uri.toString());
                },
              ),
            ),
            Container(
              width: double.infinity,
              margin: EdgeInsets.fromLTRB(8, 8, 8, 40),
              child: ElevatedButton(
                onPressed: () => _onComplete(context),
                child: Text('Complete', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
