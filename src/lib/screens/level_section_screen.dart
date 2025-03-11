import 'package:flutter/material.dart';
import 'package:src/classes/level.dart';
import 'package:src/classes/lesson_item.dart';
import 'package:src/screens/level_section_overview_screen.dart';
import 'package:src/components/user_profile.dart';

class LevelSectionScreen extends StatefulWidget {
  final Level level;

  const LevelSectionScreen({super.key, required this.level});

  @override
  State<LevelSectionScreen> createState() => _LevelSectionScreenState();
}

class _LevelSectionScreenState extends State<LevelSectionScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.level.title, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.green,
        actions: const [UserProfileIcon()],
      ),
      endDrawer: const UserProfileDrawer(),
      body: ListView.builder(
        itemCount: widget.level.sections.length,
        itemBuilder: (context, sectionIndex) {
          final section = widget.level.sections[sectionIndex];
          
          return Card(
            margin: const EdgeInsets.all(16.0),
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: InkWell(
              onTap: () {
                // Navigate to the section overview screen when tapped
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LevelSectionOverviewScreen(section: section),
                  ),
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section image
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    child: Image.asset(
                      section.imagePath,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  
                  // Section header
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          section.title,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          section.subtitle,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
