import 'package:flutter/material.dart';
import 'package:src/classes/lesson_item.dart';
import 'package:src/screens/markdown_viewer_screen.dart';
import 'package:src/screens/videoplayer_screen.dart';
import 'package:src/screens/quiz_screen.dart';

class LessonItemCard extends StatefulWidget {
  final LessonItem lessonItem;

  const LessonItemCard({super.key, required this.lessonItem});

  @override
  State<LessonItemCard> createState() => _LessonItemCardState();
}

class _LessonItemCardState extends State<LessonItemCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          switch (widget.lessonItem.type) {
            case 0: // Content
              if (widget.lessonItem.content != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MarkdownViewerScreen(
                      // title: widget.lessonItem.title!,
                      markdown: widget.lessonItem.content!,
                    ),
                  ),
                );
              }
              break;
            case 1: // Video
              if (widget.lessonItem.videoPath != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VideoPlayerScreen(
                      // title: widget.lessonItem.title,
                      videoUrl: widget.lessonItem.videoPath!,
                    ),
                  ),
                );
              }
              break;
            case 2: // Quiz
              if (widget.lessonItem.quiz != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => QuizScreen(
                      quiz: widget.lessonItem.quiz!,
                    ),
                  ),
                );
              }
              break;
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.asset(
                widget.lessonItem.imagePath,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            
            // Content
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    widget.lessonItem.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Type indicator
                  Row(
                    children: [
                      Icon(
                        widget.lessonItem.type == 0 
                            ? Icons.article 
                            : widget.lessonItem.type == 1 
                                ? Icons.play_circle_fill 
                                : Icons.quiz,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        widget.lessonItem.type == 0 
                            ? 'Reading' 
                            : widget.lessonItem.type == 1 
                                ? 'Video' 
                                : 'Quiz',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const Spacer(),
                      if (widget.lessonItem.isCompleted)
                        const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 20,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
