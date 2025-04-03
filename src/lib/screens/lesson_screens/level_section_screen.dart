import 'package:flutter/material.dart';
import 'package:src/classes/level.dart';
import 'package:src/components/lesson_components/lesson_section_card.dart';
import 'package:src/screens/lesson_screens/level_section_overview_screen.dart';
import 'package:src/services/db_helper.dart';
import 'package:src/classes/level_section.dart';

class LevelSectionScreen extends StatefulWidget {
  final Level level;

  const LevelSectionScreen({super.key, required this.level});

  @override
  State<LevelSectionScreen> createState() => _LevelSectionScreenState();
}

class _LevelSectionScreenState extends State<LevelSectionScreen> {
  final dbHelper = DBHelper.instance();
  late Future<List<LevelSection>> _sectionsFuture;

  @override
  void initState() {
    super.initState();
    _refreshSections();
  }

  // Function to refresh sections data
  void _refreshSections() {
    setState(() {
      _sectionsFuture = getAllSectionsFromLevel(widget.level.id);
    });
  }

  Future<List<LevelSection>> getAllSectionsFromLevel(int levelId) async {
    List<Map<String, dynamic>> sections = await dbHelper
        .getAllSectionsFromLevel(levelId);
    List<LevelSection> levelSections =
        sections.map((section) {
          return LevelSection(
            id: section['id'],
            title: section['title'],
            subtitle: section['subtitle'],
            imagePath: section['imagePath'],
            completedLessons: section['completedLessons'],
            totalLessons: section['totalLessons'],
          );
        }).toList();

    return levelSections;
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    // Adaptive colors
    final Color subtitleBgColor = isDarkMode 
        ? Color(0xFF1A3020) // Dark green background for dark mode
        : Colors.green.shade50;
    
    final Color subtitleTextColor = isDarkMode
        ? Colors.green.shade300 // Lighter green text for dark mode
        : Colors.green.shade800;
        
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.level.title,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 24, color: Colors.white),
        ),
        backgroundColor: Colors.green,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context, true);
          },
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              color: subtitleBgColor,
              child: Text(
                widget.level.subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18, 
                  color: subtitleTextColor
                ),
              ),
            ),
            Expanded(
              child: FutureBuilder(
                future: _sectionsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error: ${snapshot.error}',
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Text(
                        'No sections available.',
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                    );
                  } else {
                    List<LevelSection> sections = snapshot.data!;
                    return ListView.builder(
                      itemCount: sections.length,
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).padding.bottom,
                      ),
                      itemBuilder: (context, index) {
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 1300),
                          curve: Curves.easeIn,
                          child: LessonSectionCard(
                            section: sections[index],
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => LevelSectionOverviewScreen(
                                        section: sections[index],
                                      ),
                                ),
                              ).then((_) {
                                // Always refresh when returning from lesson section
                                _refreshSections();
                              });
                            },
                          ),
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
