import 'package:flutter/material.dart';
import 'package:src/classes/lesson_item.dart';
import 'package:src/classes/level_section.dart';
import 'package:src/screens/lesson_screens/level_section_screen.dart';
import 'package:src/classes/level.dart';
import 'package:src/components/lesson_components/lesson_level_card.dart';
import 'package:src/components/home_components/user_profile.dart';
import 'package:src/classes/quiz.dart';
import 'package:src/services/db_helper.dart';
import 'package:src/components/common/safe_bottom_padding.dart';

class LessonScreen extends StatefulWidget {
  const LessonScreen({super.key});

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  final dbHelper = DBHelper.instance();

  Future<List<Level>> getAllLevels() async {
    final List<Map<String, dynamic>> unprocessedLevels =
        await dbHelper.getAllLevels();
    List<Level> levels = [];
    for (var level in unprocessedLevels) {
      levels.add(
        Level(
          id: level['id'],
          level: level['level'],
          title: level['title'],
          subtitle: level['subtitle'],
          imagePath: level['imagePath'],
          isCompleted: level['isCompleted'] == 1,
        ),
      );
    }
    return levels;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lessons', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green,
        automaticallyImplyLeading: false,
        actions: const [UserProfileIcon()],
      ),
      endDrawer: const UserProfileDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: FutureBuilder(
                future: getAllLevels(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return const Center(child: Text('Error loading levels'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No levels available'));
                  } else {
                    final List<Level> levels = snapshot.data!;
                    return ListView.builder(
                      itemCount: levels.length,
                      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
                      itemBuilder: (context, index) {
                        return LessonLevelCard(
                          level: levels[index],
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LevelSectionScreen(level: levels[index]),
                              ),
                            ).then((value) {
                              if (value != null && value) {
                                setState(() {});
                              }
                            });
                          },
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
