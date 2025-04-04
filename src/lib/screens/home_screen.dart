import 'package:flutter/material.dart';
import 'package:src/classes/lesson_item.dart';
import 'package:src/classes/progress.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:src/components/home_components/user_profile.dart';
import 'package:src/services/db_helper.dart';
import 'package:src/services/navigation_service.dart';
import 'package:src/components/common/safe_bottom_padding.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:src/components/lesson_components/lesson_item_card.dart';
import 'package:audioplayers/audioplayers.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  void checkAuth() {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      Navigator.pushNamed(context, '/');
    }
  }

  late Future<String> _tipOfTheWeek;
  late LessonItem lessonItem;
  late AudioPlayer _player;
  final dbHelper = DBHelper.instance();

  @override
  void initState() {
    super.initState();
    checkAuth();
    _player = AudioPlayer();
    _player.setSource(AssetSource('sounds/achievement_unlocked.mp3'));
    _tipOfTheWeek = _getTipOfTheWeek();
    defaultBadge(context);
  }

  Future<void> defaultBadge(BuildContext context) async {
    final response = await dbHelper.checkIfGivenDefaultBadge();

    if (response) {
      return;
    }

    await dbHelper.setDefaultBadgeGiven();

    _player.resume();

    if (context.mounted) {
      showDialog(
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
                children: [
                  const SizedBox(height: 8),
                  const Text(
                    'Achievement Unlocked!',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Welcome to HelloChef!',
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
                      'assets/images/badge_images/home_cook.png',
                      height: 120,
                      width: 120,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Home Cook Badge',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'You\'ve taken your first step on your culinary journey!',
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

  Future<LessonItem> getLessonItem() async {
    lessonItem = await dbHelper.getNextUpLesson();
    return lessonItem;
  }

  // Function to get the current week number (1-52)
  int _getCurrentWeekNumber() {
    final now = DateTime.now();
    final startOfYear = DateTime(now.year, 1, 1);
    final firstMonday =
        startOfYear.weekday == DateTime.monday
            ? startOfYear
            : startOfYear.add(Duration(days: (8 - startOfYear.weekday) % 7));

    final daysDifference = now.difference(firstMonday).inDays;
    final weekNumber = (daysDifference / 7).floor() + 1;

    // Ensure the week number is between 1 and 52
    return (weekNumber > 0 && weekNumber <= 52) ? weekNumber : 1;
  }

  // Function to load the appropriate tip based on week number
  Future<String> _getTipOfTheWeek() async {
    try {
      // Load the tips from the JSON file
      final String response = await rootBundle.loadString(
        'assets/data/tips.json',
      );
      final List<dynamic> tips = json.decode(response);

      // Get current week number (0-based index for the array)
      final int weekIndex = _getCurrentWeekNumber() - 1;

      // Return the tip for this week
      return tips[weekIndex];
    } catch (e) {
      return "Always taste your food as you cook and adjust seasoning as needed.";
    }
  }

  void _refresh() {
    setState(() {
      _tipOfTheWeek = _getTipOfTheWeek();
    });
  }

  Future<Progress> getProgress() async {
    final progress = await dbHelper.getCurrentLevelProgress();
    return progress;
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Hello Chef',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.green,
          automaticallyImplyLeading: false,
          actions: const [UserProfileIcon()],
        ),
        endDrawer: const UserProfileDrawer(),
        body: RefreshIndicator(
          onRefresh: () async {
            _refresh();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Greeting with user's name
                  FutureBuilder<Map<String, dynamic>?>(
                    future: DBHelper.instance().getUserDetails(),
                    builder: (context, snapshot) {
                      String firstName = "Chef";
                      if (snapshot.hasData && snapshot.data != null) {
                        firstName = snapshot.data!['first_name'] ?? "Chef";
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hi, $firstName!',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color:
                                  Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Ready to cook something amazing today?',
                            style: TextStyle(
                              fontSize: 16,
                              color:
                                  isDarkMode
                                      ? Colors.grey[400]
                                      : Colors.grey[600],
                            ),
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  FutureBuilder(
                    future: getProgress(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            'Error loading progress',
                            style: TextStyle(
                              color:
                                  Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                          ),
                        );
                      } else if (!snapshot.hasData || snapshot.data == null) {
                        return Center(
                          child: Text(
                            'No progress available',
                            style: TextStyle(
                              color:
                                  Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                          ),
                        );
                      } else {
                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 4,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Current Level',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color:
                                            Theme.of(
                                              context,
                                            ).textTheme.bodyLarge?.color,
                                      ),
                                    ),
                                    Text(
                                      'Level ${snapshot.data!.level.level}',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  snapshot.data!.level.subtitle,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color:
                                        Theme.of(
                                          context,
                                        ).textTheme.bodyLarge?.color,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Progress: ${snapshot.data!.numSectionsCompleted} / ${snapshot.data!.numSections} Sections',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color:
                                        Theme.of(
                                          context,
                                        ).textTheme.bodyMedium?.color,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                LinearProgressIndicator(
                                  value: snapshot.data!.progressPercentage,
                                  backgroundColor:
                                      isDarkMode
                                          ? Colors.grey[800]
                                          : Colors.grey[300],
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                        Colors.green,
                                      ),
                                  minHeight: 8,
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                    },
                  ),

                  // Quick Access Cards
                  // Current level progress
                  const SizedBox(height: 24),

                  // Continue Learning
                  Text(
                    'Continue Learning',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 12),
                  FutureBuilder(
                    future: getLessonItem(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            'Error loading lesson',
                            style: TextStyle(
                              color:
                                  Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                          ),
                        );
                      } else if (!snapshot.hasData || snapshot.data == null) {
                        return Center(
                          child: Text(
                            'No lessons available',
                            style: TextStyle(
                              color:
                                  Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                          ),
                        );
                      } else {
                        return LessonItemCard(
                          lessonItem: lessonItem,
                          onCompleted: _refresh,
                          isOnHomeScreen: true,
                        );
                      }
                    },
                  ),

                  const SizedBox(height: 24),

                  // Tip of the Week (updated from Tip of the Day)
                  FutureBuilder<String>(
                    future: _tipOfTheWeek,
                    builder: (context, snapshot) {
                      String tip = "Always taste your food as you cook!";
                      if (snapshot.hasData && snapshot.data != null) {
                        tip = snapshot.data!;
                      }

                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                        color:
                            isDarkMode
                                ? Color(0xFF1A3020) // Dark green for dark mode
                                : Colors.green.shade50,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.lightbulb,
                                    color: Colors.amber.shade700,
                                  ),
                                  const SizedBox(width: 8),
                                  Row(
                                    children: [
                                      Text(
                                        'Tip of the Week',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color:
                                              Theme.of(
                                                context,
                                              ).textTheme.bodyLarge?.color,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.green,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Text(
                                          'Week ${_getCurrentWeekNumber()}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                tip,
                                style: TextStyle(
                                  fontSize: 16,
                                  color:
                                      Theme.of(
                                        context,
                                      ).textTheme.bodyLarge?.color,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  // Add SafeBottomPadding at the end of the SingleChildScrollView content
                  SafeBottomPadding(
                    extraPadding: 8.0,
                    child: SizedBox(
                      height: 16,
                    ), // Smaller SizedBox instead of the const SizedBox(height: 24)
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAccessCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(icon, color: Colors.green, size: 36),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
