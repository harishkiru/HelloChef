import 'package:flutter/material.dart';
import 'package:src/classes/level_section.dart';
import 'package:src/classes/lesson_item.dart';
import 'package:src/screens/markdown_viewer_screen.dart';
import 'package:src/screens/videoplayer_screen.dart';
import 'package:src/screens/quiz_screen.dart';
import 'package:src/components/user_profile.dart';

class LevelSectionOverviewScreen extends StatefulWidget {
  final LevelSection section;

  const LevelSectionOverviewScreen({super.key, required this.section});

  @override
  State<LevelSectionOverviewScreen> createState() =>
      _LevelSectionOverviewScreenState();
}

class _LevelSectionOverviewScreenState
    extends State<LevelSectionOverviewScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.section.title,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
        actions: const [UserProfileIcon()],
      ),
      endDrawer: const UserProfileDrawer(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Section header
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              widget.section.subtitle,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
          ),
          const Divider(),
          // Lessons list
          Expanded(
            child: ListView.builder(
              itemCount: widget.section.lessons.length,
              itemBuilder: (context, index) {
                return _buildLessonListItem(widget.section.lessons[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLessonListItem(LessonItem lesson) {
    // Choose icon based on lesson type
    IconData iconData;
    String typeText;
    
    switch (lesson.type) {
      case 0:
        iconData = Icons.article;
        typeText = 'Reading';
        break;
      case 1:
        iconData = Icons.play_circle_filled;
        typeText = 'Video';
        break;
      case 2:
        iconData = Icons.quiz;
        typeText = 'Quiz';
        break;
      default:
        iconData = Icons.article;
        typeText = 'Reading';
    }
    
    return ListTile(
      leading: Icon(iconData, color: Colors.green),
      title: Text(lesson.title),
      subtitle: Text(typeText),
      trailing: lesson.isCompleted
          ? const Icon(Icons.check_circle, color: Colors.green)
          : null,
      onTap: () {
        // Navigate to appropriate screen based on lesson type
        switch (lesson.type) {
          case 0: // Content
            if (lesson.content != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MarkdownViewerScreen(
                    //title: lesson.title,
                    markdown: lesson.content!,
                  ),
                ),
              );
            }
            break;
          case 1: // Video
            if (lesson.videoPath != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VideoPlayerScreen(
                    //title: lesson.title,
                    videoUrl: lesson.videoPath!,
                  ),
                ),
              );
            }
            break;
          case 2: // Quiz
            if (lesson.quiz != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => QuizScreen(
                    quiz: lesson.quiz!,
                  ),
                ),
              );
            }
            break;
        }
      },
    );
  }
}
