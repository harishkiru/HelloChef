import 'package:flutter/material.dart';
import 'package:src/classes/lesson_item.dart';
import 'package:src/screens/markdown_viewer_screen.dart';
import 'package:src/screens/videoplayer_screen.dart';

class LessonItemCard extends StatefulWidget {
  final LessonItem lessonItem;

  const LessonItemCard({super.key, required this.lessonItem});

  @override
  State<LessonItemCard> createState() => _LessonItemCardState();
}

class _LessonItemCardState extends State<LessonItemCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 5, 0, 5),
      child: ListTile(
        contentPadding: EdgeInsets.fromLTRB(5, 5, 10, 5),

        leading: Icon(
          widget.lessonItem.type == 0
              ? Icons.article
              : widget.lessonItem.type == 1
              ? Icons.video_library
              : widget.lessonItem.type == 2
              ? Icons.transcribe
              : Icons.error,
          color: Colors.white,
          size: 40,
        ),
        title: Text(
          widget.lessonItem.title,
          style: const TextStyle(fontSize: 18, color: Colors.white),
        ),
        trailing:
            (widget.lessonItem.isCompleted)
                ? const Icon(
                  Icons.check_circle,
                  color: Color.fromARGB(255, 0, 247, 255),
                )
                : (!widget.lessonItem.isCompleted)
                ? const Icon(Icons.circle, color: Colors.grey)
                : null,
        tileColor: Colors.green,
        onTap: () {
          switch (widget.lessonItem.type) {
            case 0:
              final response = Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => MarkdownViewerScreen(
                        markdown: widget.lessonItem.content!,
                        lessonItem: widget.lessonItem,
                      ),
                ),
              );
              response.then((value) {
                if (value != null && value) {
                  setState(() {
                    widget.lessonItem.isCompleted = true;
                  });
                }
              });
              break;
            case 1:
              final response = Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => VideoPlayerScreen(
                        videoUrl: widget.lessonItem.videoPath!,
                        lessonItem: widget.lessonItem,
                      ),
                ),
              );
              response.then((value) {
                if (value != null && value) {
                  setState(() {
                    widget.lessonItem.isCompleted = true;
                  });
                }
              });
              break;

            case 2:
              final response = Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => MarkdownViewerScreen(
                        markdown: widget.lessonItem.content!,
                        lessonItem: widget.lessonItem,
                      ),
                ),
              );
              response.then((value) {
                if (value != null && value) {
                  setState(() {
                    widget.lessonItem.isCompleted = true;
                  });
                }
              });
              break;
          }
        },
      ),
    );
  }
}
