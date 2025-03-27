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
  final VoidCallback? onCompleted;

  const LessonItemCard({super.key, required this.lessonItem, this.onCompleted});

  @override
  State<LessonItemCard> createState() => _LessonItemCardState();
}

class _LessonItemCardState extends State<LessonItemCard> {
  final dbHelper = DBHelper.instance();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
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

  String _getLessonTypeText(int type) {
    switch (type) {
      case 0:
        return 'Reading Material';
      case 1:
        return 'Video Lesson';
      case 2:
        return 'Transcription';
      case 3:
        return 'Interactive Quiz';
      case 4:
        return 'Interactive Image';
      default:
        return 'Lesson';
    }
  }

  Color _getCardColor(int type) {
    switch (type) {
      case 0:
        return Colors.green.shade700;
      case 1:
        return Colors.blue.shade700;
      case 2:
        return Colors.orange.shade700;
      case 3:
        return Colors.purple.shade700;
      case 4:
        return Colors.teal.shade700;
      default:
        return Colors.green.shade700;
    }
  }

  // Update lesson completion state and notify parent
  void _markLessonCompleted() {
    if (widget.lessonItem.isCompleted) {
      return; // Lesson already completed
    }

    dbHelper.completeLesson(widget.lessonItem.id);

    setState(() {
      widget.lessonItem.isCompleted = true;
    });

    // Notify parent to refresh progress
    if (widget.onCompleted != null) {
      widget.onCompleted!();
    }
  }

  Widget _buildCardContent(BuildContext context, {VoidCallback? onTap}) {
    final double screenHeight = MediaQuery.of(context).size.height;

    return Card(
      margin: const EdgeInsets.symmetric(
        vertical: 10.0,
        horizontal: 30.0,
      ), // Reduced vertical margin
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(
          color:
              widget.lessonItem.isCompleted
                  ? Colors.green.shade300
                  : Colors.transparent,
          width: widget.lessonItem.isCompleted ? 2.0 : 0,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image section (reduced height)
            Container(
              height: screenHeight * 0.15,
              decoration: BoxDecoration(
                color: _getCardColor(widget.lessonItem.type),
                image:
                    widget.lessonItem.imagePath != null &&
                            widget.lessonItem.imagePath!.isNotEmpty
                        ? DecorationImage(
                          image: AssetImage(widget.lessonItem.imagePath!),
                          fit: BoxFit.cover,
                          colorFilter: ColorFilter.mode(
                            Colors.black.withOpacity(0.3),
                            BlendMode.darken,
                          ),
                        )
                        : null,
              ),
              child:
                  widget.lessonItem.imagePath == null ||
                          widget.lessonItem.imagePath!.isEmpty
                      ? Center(
                        child: Icon(
                          _getIconForLessonType(widget.lessonItem.type),
                          size: 40.0,
                          color: Colors.white,
                        ),
                      )
                      : null,
            ),

            // Content section with green background
            Stack(
              children: [
                Container(
                  color: Colors.green.shade600,
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.lessonItem.title,
                        style: const TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4.0),
                      Row(
                        children: [
                          Icon(
                            _getIconForLessonType(widget.lessonItem.type),
                            size: 16.0,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 6.0),
                          Text(
                            _getLessonTypeText(widget.lessonItem.type),
                            style: const TextStyle(
                              fontSize: 12.0,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                      // Added extra space at bottom for the icon
                      const SizedBox(height: 6.0),
                    ],
                  ),
                ),

                // Completion status indicator in bottom right corner
                Positioned(
                  bottom: 8.0,
                  right: 8.0,
                  child: Container(
                    padding: const EdgeInsets.all(2.0),
                    child: Icon(
                      widget.lessonItem.isCompleted
                          ? Icons
                              .check_circle // Checkmark in circle for completed
                          : Icons
                              .circle_outlined, // Just a circle for incomplete
                      color: Colors.white,
                      size: 30.0,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget textVideoandImageContent() {
    return _buildCardContent(
      context,
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
                _markLessonCompleted();
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
                _markLessonCompleted();
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
                _markLessonCompleted();
              }
            });
        }
      },
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
          return _buildCardContent(
            context,
            onTap: () {
              final response = Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) =>
                          QuizScreen(quiz: quiz, lessonItem: widget.lessonItem),
                ),
              );
              response.then((value) {
                if (value != null && value) {
                  _markLessonCompleted();
                }
              });
            },
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
          return _buildCardContent(
            context,
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
                  _markLessonCompleted();
                }
              });
            },
          );
        }
      },
    );
  }
}
