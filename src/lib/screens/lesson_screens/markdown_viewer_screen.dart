import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter/material.dart';
import 'package:src/classes/lesson_item.dart';
import 'package:src/components/common/safe_bottom_padding.dart'; // Add this import

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
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text(
          lessonItem.title,
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
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
              // Replace fixed margin with SafeBottomPadding
              SafeBottomPadding(
                extraPadding: 16.0,
                child: Container(
                  width: double.infinity,
                  margin: EdgeInsets.fromLTRB(8, 8, 8, 0), // Changed bottom margin from 40 to 0
                  child: ElevatedButton(
                    onPressed: () => _onComplete(context),
                    child: Text('Complete', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
