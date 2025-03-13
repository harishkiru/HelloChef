import 'package:flutter/material.dart';
import 'package:src/classes/lesson_item.dart';
import 'package:src/screens/lesson_screens/markdown_viewer_screen.dart';
import 'package:src/screens/lesson_screens/videoplayer_screen.dart';
import 'package:src/screens/lesson_screens/quiz_screen.dart';

class LessonItemCard extends StatefulWidget {
  final LessonItem lessonItem;

  const LessonItemCard({super.key, required this.lessonItem});

  @override
  State<LessonItemCard> createState() => _LessonItemCardState();
}

class _LessonItemCardState extends State<LessonItemCard> {
  IconData _getIconForLessonType(int type) {
    switch (type) {
      case 0:
        return Icons.article;
      case 1:
        return Icons.video_library;
      case 2:
        return Icons.transcribe;
      case 3:
        return Icons.quiz;
      default:
        return Icons.article;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 5, 0, 5),
      child: ListTile(
        contentPadding: const EdgeInsets.fromLTRB(5, 5, 10, 5),

        leading: Icon(
          _getIconForLessonType(widget.lessonItem.type),
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
            case 3: // Quiz
              if (widget.lessonItem.quiz != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => QuizScreen(quiz: widget.lessonItem.quiz!),
                  ),
                );
              }
          }
        },
      ),
    );
  }
}
