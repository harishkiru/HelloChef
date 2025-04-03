import 'package:flutter/material.dart';
import 'package:src/classes/lesson_item.dart';
import 'package:src/screens/lesson_screens/markdown_viewer_screen.dart';
import 'package:src/screens/lesson_screens/videoplayer_screen.dart';
import 'package:src/screens/lesson_screens/quiz_screen.dart';
import 'package:src/screens/lesson_screens/interactive_image_screen.dart';
import 'package:src/services/db_helper.dart';
import 'package:src/classes/quiz.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:confetti/confetti.dart';

class LessonItemCard extends StatefulWidget {
  final LessonItem lessonItem;
  final VoidCallback? onCompleted;

  const LessonItemCard({super.key, required this.lessonItem, this.onCompleted});

  @override
  State<LessonItemCard> createState() => _LessonItemCardState();
}

class _LessonItemCardState extends State<LessonItemCard> {
  final dbHelper = DBHelper.instance();
  late AudioPlayer _player;
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 5),
    );
  }

  @override
  void dispose() {
    _player.dispose();
    _confettiController.dispose();
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

  // Update lesson completion state and notify parent
  void _markLessonCompleted() async {
    if (widget.lessonItem.isCompleted) {
      return; // Lesson already completed
    }

    setState(() {
      widget.lessonItem.isCompleted = true;
    });

    await dbHelper.completeLesson(widget.lessonItem.id);

    if (widget.onCompleted != null) {
      widget.onCompleted!();
    }
    final response = await dbHelper.updateUserXP(10);

    if (response['rank'] != -1) {
      if (mounted) {
        // Play sound
        _player.play(AssetSource('sounds/rank_up.mp3'));

        // Start confetti animation
        _confettiController.play();

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return Stack(
              children: [
                // Confetti effect on top of dialog
                Align(
                  alignment: Alignment.topCenter,
                  child: ConfettiWidget(
                    confettiController: _confettiController,
                    blastDirectionality: BlastDirectionality.explosive,
                    emissionFrequency: 0.05,
                    numberOfParticles: 50,
                    maxBlastForce: 200,
                    minBlastForce: 50,
                    gravity: 0.3,
                    particleDrag: 0.05,
                    colors: const [
                      Color.fromARGB(255, 255, 215, 0), // Gold
                      Color.fromARGB(255, 255, 230, 128), // Light Gold
                      Color.fromARGB(255, 238, 221, 130), // Pale Gold
                      Color.fromARGB(255, 212, 175, 55), // Rich Gold
                      Color.fromARGB(255, 255, 223, 0), // Golden Yellow
                      Color.fromARGB(255, 205, 127, 50), // Metallic Bronze
                      Color.fromARGB(255, 184, 134, 11), // Deep Gold
                      Color.fromARGB(255, 237, 201, 175), // Shimmering Sand
                      Color.fromARGB(255, 255, 204, 51), // Warm Yellow
                      Color.fromARGB(255, 250, 231, 181), // Champagne Gold
                    ],
                  ),
                ),
                // Enhanced dialog
                AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  backgroundColor: Colors.green.shade50,
                  title: Column(
                    children: [
                      const Icon(
                        Icons.workspace_premium,
                        color: Colors.amber,
                        size: 50,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'RANK UP!',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade800,
                        ),
                      ),
                    ],
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Congratulations!',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'You have achieved rank:',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 15),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 25,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.shade700,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Text(
                          '${response['rank']}',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Keep up the great work!',
                        style: TextStyle(
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                          color: Colors.green.shade600,
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade700,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: const Text(
                          'AWESOME!',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      }
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
                color: Colors.grey.shade200,
                image:
                    widget.lessonItem.imagePath.isNotEmpty
                        ? DecorationImage(
                          image: AssetImage(widget.lessonItem.imagePath),
                          fit: BoxFit.cover,
                          colorFilter: ColorFilter.mode(
                            Colors.black.withValues(alpha: 0.3),
                            BlendMode.darken,
                          ),
                        )
                        : null,
              ),
              child:
                  widget.lessonItem.imagePath.isEmpty
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
