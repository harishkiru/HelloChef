import 'package:flutter/material.dart';
import 'package:src/classes/lesson_item.dart';
import 'package:src/screens/lesson_screens/markdown_viewer_screen.dart';
import 'package:src/screens/lesson_screens/videoplayer_screen.dart';
import 'package:src/screens/lesson_screens/quiz_screen.dart';
import 'package:src/screens/lesson_screens/interactive_image_screen.dart';
import 'package:src/services/db_helper.dart';
import 'package:src/classes/quiz.dart';

class LessonItemCard extends StatefulWidget {
  final LessonItem lessonItem;

  const LessonItemCard({super.key, required this.lessonItem});

  @override
  State<LessonItemCard> createState() => _LessonItemCardState();
}

class _LessonItemCardState extends State<LessonItemCard> {
  final dbHelper = DBHelper.instance();

  Future<Quiz> getQuizFromLesson() async {
    List<Map<String, dynamic>> quizDetails = await dbHelper.getQuizFromQuizId(
      widget.lessonItem.quizId!,
    );

    List<Map<String, dynamic>> quizQuestions = await dbHelper
        .getQuizQuestionsFromQuizId(widget.lessonItem.quizId!);

    List<QuizQuestion> questions =
        quizQuestions.map((question) {
          return QuizQuestion(
            question: question['question'],
            imagePath: question['imagePath'],
            options: question['options'].split(','),
            correctAnswerIndex: question['correctAnswerIndex'],
          );
        }).toList();

    return Quiz(
      title: quizDetails[0]['title'],
      description: quizDetails[0]['description'],
      questions: questions,
    );
  }

  Future<List<Map<String, dynamic>>> getButtonDetails() async {
    List<Map<String, dynamic>> buttonDetailsUnprocessed = await dbHelper
        .getInteractiveButtonsFromLessonId(widget.lessonItem.id);

    List<Map<String, dynamic>> buttonDetails = [];
    for (var button in buttonDetailsUnprocessed) {
      Map<String, dynamic> buttonDetail = {
        'name': button['name'],
        'position_x': button['position_x'],
        'position_y': button['position_y'],
        'width': button['width'],
        'height': button['height'],
        'onPressed': button['onPressed'],
      };
      buttonDetails.add(buttonDetail);
    }
    return buttonDetails;
  }

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
      case 4:
        return Icons.image;
      default:
        return Icons.article;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.lessonItem.type < 3) {
      return textVideoandImageContent();
    } else if (widget.lessonItem.type == 3) {
      return quizContent();
    } else {
      return interactiveImageContent();
    }
  }

  Widget textVideoandImageContent() {
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
                  dbHelper.completeLesson(widget.lessonItem.id);
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
                  dbHelper.completeLesson(widget.lessonItem.id);
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
                  dbHelper.completeLesson(widget.lessonItem.id);
                }
              });
          }
        },
      ),
    );
  }

  Widget quizContent() {
    return FutureBuilder(
      future: getQuizFromLesson(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error loading quiz ${snapshot.error}'));
        } else if (!snapshot.hasData) {
          return const Center(child: Text('No quiz available'));
        } else {
          Quiz quiz = snapshot.data!;
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
                final response = Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => QuizScreen(
                          quiz: quiz,
                          lessonItem: widget.lessonItem,
                        ),
                  ),
                );
                response.then((value) {
                  if (value != null && value) {
                    setState(() {
                      widget.lessonItem.isCompleted = true;
                    });
                    dbHelper.completeLesson(widget.lessonItem.id);
                  }
                });
              },
            ),
          );
        }
      },
    );
  }

  Widget interactiveImageContent() {
    return FutureBuilder(
      future: getButtonDetails(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('Error loading interactive image'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No interactive image available'));
        } else {
          List<Map<String, dynamic>> buttonDetails = snapshot.data!;
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
                final response = Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => InteractiveImageScreen(
                          imagePath: widget.lessonItem.imagePath,
                          buttonDetails: buttonDetails,
                          lessonItem: widget.lessonItem,
                        ),
                  ),
                );
                response.then((value) {
                  if (value != null && value) {
                    setState(() {
                      widget.lessonItem.isCompleted = true;
                    });
                    dbHelper.completeLesson(widget.lessonItem.id);
                  }
                });
              },
            ),
          );
        }
      },
    );
  }
}
