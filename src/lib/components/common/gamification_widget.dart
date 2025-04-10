import 'package:confetti/confetti.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:src/services/db_helper.dart';
import 'package:src/classes/lesson_item.dart';

class GamificationWidget extends StatefulWidget {
  bool? isQuiz;
  LessonItem lessonItem;
  int? score;
  int? totalQuestions;

  GamificationWidget({
    super.key,
    this.isQuiz = false,
    this.score = 0,
    this.totalQuestions = 0,
    required this.lessonItem,
  });

  @override
  State<GamificationWidget> createState() => _GamificationWidgetState();
}

class _GamificationWidgetState extends State<GamificationWidget>
    with SingleTickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AudioPlayer _levelPlayer;
  late AudioPlayer _rankUpPlayer;
  late AudioPlayer _achievementPlayer;
  late AnimationController _animationController;
  final dbHelper = DBHelper.instance();
  bool _inProgress = false;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 5),
    );
    _levelPlayer = AudioPlayer();
    _levelPlayer.setSource(AssetSource('sounds/level_complete.mp3'));
    _achievementPlayer = AudioPlayer();
    _achievementPlayer.setSource(
      AssetSource('sounds/achievement_unlocked.mp3'),
    );
    _rankUpPlayer = AudioPlayer();
    _rankUpPlayer.setSource(AssetSource('sounds/rank_up.mp3'));
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  void changeProgress() {
    setState(() {
      _inProgress = !_inProgress;
    });
  }

  Future<bool> _checkForQuizBadge(bool perfect) async {
    await dbHelper.addLessonToTotalLessonsCompleted();
    await dbHelper.addQuizToTotalQuizesCompleted();

    if (perfect) {
      await dbHelper.addPerfectQuizToTotalQuizesCompleted();
      final response = await dbHelper.checkIfPerfectQuizUnlocked();
      if (response) {
        return true; // Badge will be awarded
      }
    }
    return false;
  }

  Future<bool> _checkForHelloChefBadge() async {
    await dbHelper.addLessonToTotalLessonsCompleted();

    final response = await dbHelper.checkIfHelloChefBadgeUnlocked();
    if (response) {
      return true; // Badge will be awarded
    }
    return false;
  }

  Future<bool> _checkForMasterChefBadge() async {
    await dbHelper.addLessonToTotalLessonsCompleted();
    await dbHelper.addRecipeToTotalRecipesCreated();

    final response = await dbHelper.checkIfMasterChefBadgeUnlocked();
    if (response) {
      return true; // Badge will be awarded
    }
    return false;
  }

  Future<void> giveQuizBadge() async {
    await dbHelper.addBadge(2);

    _achievementPlayer.resume();

    if (mounted) {
      return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 8,
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 8),
                  const Text(
                    'Achievement Unlocked!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Quiz Master',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Image.asset(
                      'assets/images/badge_images/quiz_ace.png',
                      height: 120,
                      width: 120,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Quiz Master Badge',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'You\'ve scored perfect on your first try on all HelloChef quizzes!',
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 45),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Awesome!',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          );
        },
      );
    }
  }

  Future<void> giveMasterChefBadge() async {
    await dbHelper.addBadge(3);

    _achievementPlayer.resume();

    if (mounted) {
      return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 8,
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 8),
                  const Text(
                    'Achievement Unlocked!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Master Chef',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Image.asset(
                      'assets/images/badge_images/master_chef.png',
                      height: 120,
                      width: 120,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'MasterChef Badge',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'You\'ve prepared all tutorial recipes!',
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 45),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Awesome!',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          );
        },
      );
    }
  }

  Future<void> giveHelloChefBadge() async {
    await dbHelper.addBadge(4);

    _achievementPlayer.resume();

    if (mounted) {
      return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 8,
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 8),
                  const Text(
                    'Achievement Unlocked!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Hello Chef!',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Image.asset(
                      'assets/images/badge_images/hello_chef.png',
                      height: 120,
                      width: 120,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Hello Chef Badge',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'You\'ve completed all the HelloChef Lesson Content',
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 45),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Awesome!',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          );
        },
      );
    }
  }

  Future<void> _checkForRankUp() async {
    final response = await dbHelper.updateUserXP(10);

    if (response['rank'] != -1) {
      if (mounted) {
        _rankUpPlayer.resume();

        _confettiController.play();

        return showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return Stack(
              children: [
                // confetti effect on top of dialog
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
                      Color.fromARGB(255, 255, 215, 0),
                      Color.fromARGB(255, 255, 230, 128),
                      Color.fromARGB(255, 238, 221, 130),
                      Color.fromARGB(255, 212, 175, 55),
                      Color.fromARGB(255, 255, 223, 0),
                      Color.fromARGB(255, 205, 127, 50),
                      Color.fromARGB(255, 184, 134, 11),
                      Color.fromARGB(255, 237, 201, 175),
                      Color.fromARGB(255, 255, 204, 51),
                      Color.fromARGB(255, 250, 231, 181),
                    ],
                  ),
                ),
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

  void levelComplete(context) async {
    changeProgress();

    if (widget.lessonItem.isCompleted) {
      Navigator.pop(context, true);
      return;
    }

    await _checkForRankUp();

    bool badgeEarned = false;
    int badgeType = -1;

    if (widget.isQuiz == true) {
      badgeType = 2;
      badgeEarned = await _checkForQuizBadge(
        widget.score == widget.totalQuestions,
      );
    } else if (widget.lessonItem.title.contains('Recipe')) {
      badgeType = 3;
      badgeEarned = await _checkForMasterChefBadge();
    } else {
      badgeType = 4;
      badgeEarned = await _checkForHelloChefBadge();
    }

    // trigger haptic feedback
    HapticFeedback.heavyImpact();



    // play sound
    _levelPlayer.resume();

    // show badge popup first if earned, then show lesson completion popup
    if (badgeEarned) {
      if (badgeType == 2) {
        await giveQuizBadge();
      } else if (badgeType == 3) {
        await giveMasterChefBadge();
      } else if (badgeType == 4) {
        await giveHelloChefBadge();
      }

      if (!mounted) return;
    }

    // show lesson completion popup after badge popup (if any)
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Congratulations Dialog',
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation1, animation2) {
        return Container(); // Not used but required
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOut,
        );

        return ScaleTransition(
          scale: Tween<double>(begin: 0.5, end: 1.0).animate(curvedAnimation),
          child: FadeTransition(
            opacity: Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).animate(curvedAnimation),
            child: AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              backgroundColor: Colors.white,
              title: Column(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 50),
                  const SizedBox(height: 10),
                  const Text(
                    'Congratulations!',
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.isQuiz == true
                        ? 'You scored ${widget.score} out of ${widget.totalQuestions}'
                        : 'You have completed the lesson!',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 15),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.emoji_events, color: Colors.amber),
                        const SizedBox(width: 8),
                        const Text(
                          '+10 XP',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              actions: [
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context, true);
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10.0),
                      child: Text(
                        'Continue',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
    changeProgress();
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;

    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: SizedBox(
            width: double.infinity,
            height: screenHeight * 0.06,
            child: ElevatedButton(
              onPressed:
                  _inProgress == false ? () => levelComplete(context) : null,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    _inProgress == false
                        ? Colors.green
                        : const Color.fromARGB(255, 158, 158, 158),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child:
                  _inProgress == false
                      ? Text('Complete', style: TextStyle(color: Colors.white))
                      : SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _levelPlayer.dispose();
    _animationController.dispose();
    _achievementPlayer.dispose();
    _rankUpPlayer.dispose();
    super.dispose();
  }
}
