import 'package:sqflite/sqflite.dart';
import 'package:src/services/db_helper.dart';

Future<void> insertInitialData(
  Database db,
  List<Map<String, dynamic>> levels,
) async {
  // Add marker to first run table to signify that the app has been run before

  await db.execute('''
      INSERT INTO FirstRun (isFirstRun)
      VALUES (0)
    ''');

  for (var level in levels) {
    // Insert Level
    await db.execute(
      '''
      INSERT INTO Levels (level, title, subtitle, imagePath, isCompleted)
      VALUES (?, ?, ?, ?, ?)
    ''',
      [
        level['level'],
        level['title'],
        level['subtitle'],
        level['imagePath'],
        level['isCompleted'] ? 1 : 0,
      ],
    );

    // Get the last inserted levelId
    var levelIdResult = await db.rawQuery('SELECT last_insert_rowid()');
    int levelId = levelIdResult.first['last_insert_rowid()'] as int;

    for (var section in level['sections']) {
      // Insert Section
      await db.execute(
        '''
        INSERT INTO Sections (levelId, title, subtitle, imagePath, completedLessons, totalLessons)
        VALUES (?, ?, ?, ?, ?, ?)
      ''',
        [
          levelId,
          section['title'],
          section['subtitle'],
          section['imagePath'],
          section['completedLessons'],
          section['totalLessons'],
        ],
      );

      // Get the last inserted sectionId
      var sectionIdResult = await db.rawQuery('SELECT last_insert_rowid()');
      int sectionId = sectionIdResult.first['last_insert_rowid()'] as int;

      for (var lesson in section['lessons']) {
        // Insert Lesson
        await db.execute(
          '''
          INSERT INTO Lessons (sectionId, title, type, imagePath, isCompleted, content, videoPath, quizId)
          VALUES (?, ?, ?, ?, ?, ?, ?, ?)
        ''',
          [
            sectionId,
            lesson['title'],
            lesson['type'],
            lesson['imagePath'],
            lesson['isCompleted'] ? 1 : 0,
            lesson['content'],
            lesson['videoPath'],
            null, // quizId is initially null
          ],
        );

        // Get the last inserted lessonId
        var lessonIdResult = await db.rawQuery('SELECT last_insert_rowid()');
        int lessonId = lessonIdResult.first['last_insert_rowid()'] as int;

        // Insert InteractiveButtons if they exist
        if (lesson['buttonDetails'] != null) {
          for (var button in lesson['buttonDetails']) {
            await db.execute(
              '''
              INSERT INTO InteractiveButtons (lessonId, name, position_x, position_y, width, height, onPressed)
              VALUES (?, ?, ?, ?, ?, ?, ?)
            ''',
              [
                lessonId,
                button['name'],
                button['position_x'],
                button['position_y'],
                button['width'],
                button['height'],
                button['onPressed'],
              ],
            );
          }
        }

        // Insert Quiz and QuizQuestions if they exist
        if (lesson['quiz'] != null) {
          var quiz = lesson['quiz'];

          // Insert Quiz
          await db.execute(
            '''
            INSERT INTO Quizzes (title, description)
            VALUES (?, ?)
          ''',
            [quiz['title'], quiz['description']],
          );

          // Get the last inserted quizId
          var quizIdResult = await db.rawQuery('SELECT last_insert_rowid()');
          int quizId = quizIdResult.first['last_insert_rowid()'] as int;

          // Update the lesson with the quizId
          await db.execute(
            '''
            UPDATE Lessons SET quizId = ? WHERE id = ?
          ''',
            [quizId, lessonId],
          );

          // Insert QuizQuestions
          for (var question in quiz['questions']) {
            await db.execute(
              '''
              INSERT INTO QuizQuestions (quizId, question, options, imagePath, videoPath, correctAnswerIndex)
              VALUES (?, ?, ?, ?, ?, ?)
            ''',
              [
                quizId,
                question['question'],
                question['options'].join(
                  ',',
                ), // Convert list to comma-separated string
                question['imagePath'],
                question['videoPath'],
                question['correctAnswerIndex'],
              ],
            );
          }
        }
      }
    }
  }
}

Future<bool> checkIfFirstRun(Database db) async {
  // Check if the FirstRun table exists
  List<Map<String, dynamic>> result = await db.rawQuery(
    'SELECT name FROM sqlite_master WHERE type = "table" AND name = "FirstRun"',
  );

  if (result.isEmpty) {
    // If the table doesn't exist, it means this is the first run
    return true;
  } else {
    // If the table exists, check if it's empty
    List<Map<String, dynamic>> firstRunResult = await db.rawQuery(
      'SELECT * FROM FirstRun',
    );
    return firstRunResult.isEmpty;
  }
}

Future<void> AppFirstRun() async {
  // Get the database helper and ensure tables exist first
  final dbHelper = DBHelper.instance();
  //await dbHelper.ensureTablesExist();

  // Only after tables are confirmed to exist, get the database and insert data
  final db = await dbHelper.sqliteDatabase;

  // Your JSON data
  List<Map<String, dynamic>> levels = [
    {
      "id": 0,
      "level": 0,
      "title": "Level 0",
      "subtitle": "Kitchen Foundations",
      "imagePath": "assets/images/level_images/level_0.png",
      "isCompleted": false,
      "sections": [
        {
          "id": 0,
          "title": "Before You Start",
          "subtitle": "Learn common tools, equipment, and ingredients.",
          "imagePath":
              "assets/images/level_section_images/level_0/section_0.png",
          "lessons": [
            {
              "id": 0,
              "title": "Common Kitchen Tools",
              "type": 0,
              "imagePath":
                  "assets/images/level_section_images/level_0/section_0.png",
              "isCompleted": false,
              "content":
                  "# Common Kitchen Tools\n![Photo](assets/images/lesson_markdown_images/level_0/section_0/lesson_0/0.png)\n\n## Introduction\nBefore getting started in the kitchen there is a variety of tools you should have on hand inorder to make learning how to cook easier. You will likely have most of these items already so you will probably only have to worry about picking up a couple items. You do not need to invest in them all at once but as you get more comfortable in the kitchen you will find that having the right tools will make your life easier. I have for the convenience broken down these items into sections based on importance.\n\n## Essential Tools\n- Medium to large sized frying pan\n- Medium to large sized pot\n- Baking sheet\n- Eating Utensils \n- Cutting Board\n- Plates and Bowls\n- A Sharp Knife\n- A meat thermometer of some kind\n- A can opener\n- A Spatual\n- A Sponge\n\nThese are the most important tools to have in your kitchen. You will use these tools on a daily basis and they are essential to cooking. You can get by without the other tools but these are a must have.\n\n## Recommended Tools\n- Multiple sized pots and pans\n- An instant read thermometer\n- Tongs\n- Multiple baking sheets\n- Vegetable peeler\n- Garlic press\n- Multiple sized food storage containers\n- Reusable salt and pepper shakers\n- Reusable spice and herb containers\n- Multiple cutting boards\n- Measuring cups and spoons\n- A whisk\n- A blender\n- A colander\n- A range of knives\n\nThese are tools that are not essential but are very helpful to have in the kitchen. You will find that having these tools will make your life easier and will make cooking more enjoyable.\n",
            },
            {
              "id": 1,
              "title": "Common Ingredients",
              "type": 0,
              "imagePath":
                  "assets/images/lesson_images/level_0/section_0/lesson_2.png",
              "isCompleted": false,
              "content":
                  "# Common Ingredients\n![Photo](assets/images/lesson_markdown_images/level_0/section_0/lesson_1/0.png)\n\n## Introduction\nWhen you are first starting out in the kitchen it can be hard to know what ingredients you should have on hand. Just like music, recipes borrow alot of ingredients from one another so having a stock of common ingredients can make cooking dishes on demand much easier. This list is a great starting point for anyone who is just starting out in the kitchen. You will find that having these ingredients on hand will make cooking easier and more enjoyable. Just like with the tools list I have compiled these ingredients into two different lists based on their importance.\n\n## Essential Ingredients\n- Salt\n- Pepper\n- Some kind of oil (vegetable, olive, Avocado)\n- Garlic Powder\n- Onion Powder\n- Flour\n- Sugar\n\nThese ingredients are in almost every recipe you will find in some form so it is highly recommended you buy larger containers of these items to save time and money.\n\n## Recommended Ingredients\n- Eggs\n- Milk\n- Butter\n- Baking Powder\n- Baking Soda\n- Vanilla Extract\n- Soy Sauce\n- Worcestershire Sauce\n- Ketchup\n- Mustard\n- Mayonnaise\n- White and balsamic vinegar\n- Dried Rosemary\n- Dried Thyme\n- Dried Oregano\n- Dried Basil\n- Dried Parsley\n- Cumin\n- Chili Powder\n- Ground Mustard Seed\n- Cayenne Pepper\n- Chicken/beef/vegetable stock and/or bouillon\n- White Rice\n- Dried Pasta\n- Lemon Juice\n- Lime Juice\n- Sliced Bread\n\nThese ingredients are commonly used in recipes and are recommended to have on hand. Its important to note some of these ingredients are perishable so you may not want to buy them in large quantities or without a plan.\n\n\n\n                  ",
            },
            {
              "id": 2,
              "title": "Kitchen Setup & Cleanup",
              "type": 1,
              "imagePath":
                  "assets/images/lesson_images/level_0/section_0/lesson_1.png",
              "isCompleted": false,
              "videoPath": "assets/videos/level_0/section_0/video_0.mp4",
              "content:": "[Placeholder]",
            },
            {
              "id": 4,
              "title": "The Kitchen",
              "type": 4,
              "imagePath":
                  "assets/images/interactive_images/level_0/section_0/interactive_0/0.png",
              "isCompleted": false,
              "buttonDetails": [
                {
                  "name": "Fridge",
                  "position_x": 0,
                  "position_y": 0.125,
                  "width": 0.14,
                  "height": 0.275,
                  "onPressed": "Used to store food meant to be kept cold",
                },
                {
                  "name": "Pantry",
                  "position_x": 0.15,
                  "position_y": 0.09,
                  "width": 0.1,
                  "height": 0.2,
                  "onPressed": "Used to store food that is shelf-stable",
                },
                {
                  "name": "Mixer",
                  "position_x": 0.28,
                  "position_y": 0.155,
                  "width": 0.045,
                  "height": 0.04,
                  "onPressed": "Used to mix baking ingredients together",
                },
                {
                  "name": "Coffee Maker",
                  "position_x": 0.33,
                  "position_y": 0.155,
                  "width": 0.045,
                  "height": 0.04,
                  "onPressed": "Used to make coffee",
                },
                {
                  "name": "Toaster",
                  "position_x": 0.37,
                  "position_y": 0.16,
                  "width": 0.04,
                  "height": 0.04,
                  "onPressed": "Used to toast bread",
                },
                {
                  "name": "Stove/Oven",
                  "position_x": 0.415,
                  "position_y": 0.19,
                  "width": 0.14,
                  "height": 0.05,
                  "onPressed": "Used to cook fry and bake food",
                },
                {
                  "name": "Toaster Oven",
                  "position_x": 0.525,
                  "position_y": 0.165,
                  "width": 0.09,
                  "height": 0.033,
                  "onPressed": "Used to bake and toast food",
                },
                {
                  "name": "Kettle",
                  "position_x": 0.64,
                  "position_y": 0.16,
                  "width": 0.04,
                  "height": 0.035,
                  "onPressed": "Used to boil water for beverages",
                },
                {
                  "name": "Sink",
                  "position_x": 0.7,
                  "position_y": 0.16,
                  "width": 0.1,
                  "height": 0.06,
                  "onPressed": "Used to wash dishes and hands",
                },
                {
                  "name": "Dishwasher",
                  "position_x": 0.77,
                  "position_y": 0.22,
                  "width": 0.1,
                  "height": 0.08,
                  "onPressed": "Used to wash dishes",
                },
                {
                  "name": "Blender",
                  "position_x": 0.835,
                  "position_y": 0.15,
                  "width": 0.05,
                  "height": 0.05,
                  "onPressed": "Used to blend food and drinks",
                },
                {
                  "name": "Microwave",
                  "position_x": 0.4,
                  "position_y": 0.125,
                  "width": 0.15,
                  "height": 0.035,
                  "onPressed": "Used to heat food quickly",
                },
              ],
            },
          ],
          "completedLessons": 0,
          "totalLessons": 4,
        },
        {
          "id": 1,
          "title": "Kitchen Safety",
          "subtitle": "Learn how to safely use kitchen tools and equipment.",
          "imagePath":
              "assets/images/level_section_images/level_0/section_1.png",
          "lessons": [
            {
              "id": 0,
              "title": "Food Safety",
              "type": 1,
              "imagePath":
                  "assets/images/lesson_images/level_0/section_0/lesson_1.png",
              "isCompleted": false,
              "videoPath": "assets/videos/level_0/section_1/video_0.mp4",
              "content:": "[Placeholder]",
            },
            {
              "id": 2,
              "title": "Heat Safety",
              "type": 1,
              "imagePath":
                  "assets/images/lesson_images/level_0/section_0/lesson_1.png",
              "isCompleted": false,
              "videoPath": "assets/videos/level_0/section_1/video_1.mp4",
              "content:": "[Placeholder]",
            },
          ],
          "completedLessons": 0,
          "totalLessons": 2,
        },
        {
          "id": 2,
          "title": "Knowledge Section",
          "subtitle": "Test what you've learned.",
          "imagePath":
              "assets/images/level_section_images/level_0/section_2.png",
          "lessons": [
            {
              "id": 0,
              "title": "Kitchen Safety Quiz",
              "type": 3,
              "imagePath":
                  "assets/images/lesson_images/level_0_section_0_lesson_2.png",
              "isCompleted": false,
              "quiz": {
                "title": "Kitchen Basics Quiz",
                "description": "Test your knowledge of kitchen basics!",
                "questions": [
                  {
                    "question":
                        "When should you refrigerate leftovers after cooking?",
                    "options": [
                      "Within 24 hours",
                      "Within 4 hours",
                      "Immediately ",
                      "You don't need to refridgerate leftovers",
                    ],
                    "correctAnswerIndex": 2,
                  },
                  {
                    "question":
                        "Why should you use a separate cutting board for raw meat?",
                    "options": [
                      "To make cleaning up easier",
                      "To prevent cross contamination",
                      "To make the meat taste better",
                      "To make the meat cook faster",
                    ],
                    "correctAnswerIndex": 1,
                  },
                  {
                    "question":
                        "What food safety infraction is displayed in the image?",
                    "options": [
                      "Using a wooden cutting board for raw meat",
                      "Using the same cutting board for raw meat and vegetables",
                      "Not seasoning the meat",
                      "Using a dirty table to rest ingredients on",
                    ],
                    "correctAnswerIndex": 1,
                    "imagePath":
                        "assets/images/quiz_images/level_0/section_2/quiz_0/0.png",
                  },
                  {
                    "question":
                        "Why should you not use a damp cloth to remove hot items from the oven?",
                    "options": [
                      "The moisture can conduct heat",
                      "The moisture can turn into steam and burn you",
                      "The moisture can cause the cloth to catch fire",
                      "Both A and B",
                    ],
                    "correctAnswerIndex": 3,
                  },
                  {
                    "question":
                        "Why should you stand to the side when straining boiling water?",
                    "options": [
                      "To avoid water burns",
                      "To avoid spilling the water",
                      "To avoid steam burns",
                      "To avoid getting wet",
                    ],
                    "correctAnswerIndex": 2,
                  },
                  {
                    "question":
                        "What is the safest way to determine if meat is cooked?",
                    "options": [
                      "By cutting it open",
                      "By smelling it",
                      "By checking the internal temperature",
                      "By looking at the color",
                    ],
                    "correctAnswerIndex": 2,
                  },
                  {
                    "question":
                        "What should you do if something becomes stuck in the toaster?",
                    "options": [
                      "Immediately remove it with your hands to avoid a fire",
                      "Unplug the toaster and use a wooden or plastic utensil",
                      "Use a damp cloth to remove it",
                      "Use WD-40 to lubricate the toaster; toaster maintenance is important for preventing jams",
                    ],
                    "correctAnswerIndex": 1,
                  },
                  {
                    "question":
                        "What reference should you use to determine the shelf life of raw meat?",
                    "options": [
                      "The best before date provided on the packaging",
                      "The one week rule",
                      "The touch test",
                      "The estimated time provided by the FDA",
                    ],
                    "correctAnswerIndex": 0,
                  },
                ],
              },
            },
          ],
          "completedLessons": 0,
          "totalLessons": 1,
        },
      ],
    },
    {
      "id": 1,
      "level": 1,
      "title": "Level 1",
      "subtitle": "Introduction to Cooking",
      "imagePath": "assets/images/level_images/level_1.jpg",
      "isCompleted": false,
      "sections": [
        {
          "id": 0,
          "title": "Knife Training",
          "subtitle":
              "Learn about the different types of knives and how to use them.",
          "imagePath":
              "assets/images/level_section_images/level_0/section_1.png",
          "lessons": [
            {
              "id": 0,
              "title": "Knife Identification",
              "type": 0,
              "imagePath":
                  "assets/images/lesson_images/level_0/section_0/lesson_1.png",
              "isCompleted": false,
              "content": "[Placeholder]",
            },
            {
              "id": 1,
              "title": "Safe Knife Handling",
              "type": 1,
              "imagePath":
                  "assets/images/lesson_images/level_0/section_0/lesson_1.png",
              "isCompleted": false,
              "videoPath": "assets/videos/level_0/section_1/video_1.mp4",
              "content:": "[Placeholder]",
            },
            {
              "id": 2,
              "title": "Cutting Techniques",
              "type": 1,
              "imagePath":
                  "assets/images/lesson_images/level_0/section_0/lesson_1.png",
              "isCompleted": false,
              "videoPath": "assets/videos/level_0/section_1/video_1.mp4",
              "content:": "[Placeholder]",
            },
            {
              "id": 3,
              "title": "Knife Quiz",
              "type": 3,
              "imagePath":
                  "assets/images/lesson_images/level_0/section_0/lesson_1.png",
              "isCompleted": false,
              "quiz": {
                "title": "Knife Quiz",
                "description": "Test your knowledge of knife skills.",
                "questions": [
                  {
                    "question": "What is the best way to hold a knife?",
                    "options": [
                      "By the blade",
                      "By the handle",
                      "By the tip",
                      "By the spine",
                    ],
                    "correctAnswerIndex": 1,
                  },
                ],
              },
            },
          ],
          "completedLessons": 0,
          "totalLessons": 4,
        },
        {
          "id": 1,
          "title": "Introduction to Breakfast",
          "subtitle": "Learn how to prepare fundamental breakfast ingredients.",
          "imagePath":
              "assets/images/level_section_images/level_0/section_1.png",
          "lessons": [
            {
              "id": 0,
              "title": "Eggs 101",
              "type": 1,
              "imagePath":
                  "assets/images/lesson_images/level_0/section_0/lesson_1.png",
              "isCompleted": false,
              "videoPath": "assets/videos/level_0/section_1/video_0.mp4",
              "content:": "[Placeholder]",
            },
            {
              "id": 1,
              "title": "Bacon 101",
              "type": 1,
              "imagePath":
                  "assets/images/lesson_images/level_0/section_0/lesson_1.png",
              "isCompleted": false,
              "videoPath": "assets/videos/level_0/section_1/video_1.mp4",
              "content:": "[Placeholder]",
            },
            {
              "id": 2,
              "title": "American Breakfast Simulation",
              "type": 0,
              "imagePath":
                  "assets/images/lesson_images/level_0/section_0/lesson_1.png",
              "isCompleted": false,
              "content": "[Placeholder]",
            },
            {
              "id": 3,
              "title": "American Breakfast Recipe",
              "type": 0,
              "imagePath":
                  "assets/images/lesson_images/level_0/section_0/lesson_1.png",
              "isCompleted": false,
              "content": "[Placeholder]",
            },
          ],
          "completedLessons": 0,
          "totalLessons": 4,
        },
        {
          "id": 2,
          "title": "Introduction to Dinner",
          "subtitle":
              "Learn how to prepare some quick and easy dinner recipes and ingredients.",
          "imagePath":
              "assets/images/level_section_images/level_0/section_1.png",
          "lessons": [
            {
              "id": 0,
              "title": "How to Cook Rice",
              "type": 0,
              "imagePath":
                  "assets/images/lesson_images/level_0/section_0/lesson_1.png",
              "isCompleted": false,
              "content": "[Placeholder]",
            },
            {
              "id": 1,
              "title": "How to Cook Pasta",
              "type": 0,
              "imagePath":
                  "assets/images/lesson_images/level_0/section_0/lesson_1.png",
              "isCompleted": false,
              "content": "[Placeholder]",
            },
            {
              "id": 2,
              "title": "Chicken Stirfry",
              "type": 1,
              "imagePath":
                  "assets/images/lesson_images/level_0/section_0/lesson_1.png",
              "isCompleted": false,
              "videoPath": "assets/videos/level_0/section_1/video_1.mp4",
              "content:": "[Placeholder]",
            },
            {
              "id": 3,
              "title": "Chicken Stirfry Recipe",
              "type": 0,
              "imagePath":
                  "assets/images/lesson_images/level_0/section_0/lesson_1.png",
              "isCompleted": false,
              "content": "[Placeholder]",
            },
            {
              "id": 4,
              "title": "Tomato Beef Pasta",
              "type": 1,
              "imagePath":
                  "assets/images/lesson_images/level_0/section_0/lesson_1.png",
              "isCompleted": false,
              "videoPath": "assets/videos/level_0/section_1/video_1.mp4",
              "content:": "[Placeholder]",
            },
            {
              "id": 5,
              "title": "Tomato Beef Pasta Recipe",
              "type": 0,
              "imagePath":
                  "assets/images/lesson_images/level_0/section_0/lesson_1.png",
              "isCompleted": false,
              "content": "[Placeholder]",
            },
          ],
          "completedLessons": 0,
          "totalLessons": 6,
        },
      ],
    },
    {
      "id": 2,
      "level": 2,
      "title": "Level 2",
      "subtitle": "Intermediate Cooking",
      "imagePath": "assets/images/level_images/level_2.jpg",
      "isCompleted": false,
      "sections": [
        {
          "id": 2,
          "title": "Useful Knowledge and Skills",
          "subtitle": "Tips and tricks for in the kitchen",
          "imagePath":
              "assets/images/level_section_images/level_0/section_1.png",
          "lessons": [
            {
              "id": 2,
              "title": "Carryover Cooking",
              "type": 1,
              "imagePath":
                  "assets/images/lesson_images/level_0/section_0/lesson_1.png",
              "isCompleted": false,
              "videoPath": "assets/videos/level_0/section_1/video_1.mp4",
              "content:": "[Placeholder]",
            },
            {
              "id": 1,
              "title": "Wet Brines vs Dry Brines",
              "type": 0,
              "imagePath":
                  "assets/images/lesson_images/level_0/section_0/lesson_1.png",
              "isCompleted": false,
              "content": "[Placeholder]",
            },
            {
              "id": 4,
              "title": "The Chicken",
              "type": 4,
              "imagePath":
                  "assets/images/interactive_images/level_0/section_0/interactive_0/0.png",
              "isCompleted": false,
              "buttonDetails": [
                {
                  "name": "Fridge",
                  "position_x": 0,
                  "position_y": 0.125,
                  "width": 0.14,
                  "height": 0.275,
                  "onPressed": "Used to store food meant to be kept cold",
                },
              ],
            },
            {
              "id": 4,
              "title": "Spatchcocking",
              "type": 1,
              "imagePath":
                  "assets/images/lesson_images/level_0/section_0/lesson_1.png",
              "isCompleted": false,
              "videoPath": "assets/videos/level_0/section_1/video_1.mp4",
              "content:": "[Placeholder]",
            },
            {
              "id": 0,
              "title": "Kitchen Tips Quiz",
              "type": 3,
              "imagePath":
                  "assets/images/lesson_images/level_0_section_0_lesson_2.png",
              "isCompleted": false,
              "quiz": {
                "title": "Kitchen Basics Quiz",
                "description": "Test your knowledge of section content",
                "questions": [
                  {
                    "question":
                        "When should you refrigerate leftovers after cooking?",
                    "options": [
                      "Within 24 hours",
                      "Within 4 hours",
                      "Immediately ",
                      "You don't need to refridgerate leftovers",
                    ],
                    "correctAnswerIndex": 2,
                  },
                ],
              },
            },
          ],
          "completedLessons": 0,
          "totalLessons": 5,
        },
        {
          "id": 2,
          "title": "Beef: Intermediate",
          "subtitle":
              "Learn how to prepare some quick and easy dinner recipes and ingredients.",
          "imagePath":
              "assets/images/level_section_images/level_0/section_1.png",
          "lessons": [
            {
              "id": 0,
              "title": "Different cuts of beef and their uses",
              "type": 0,
              "imagePath":
                  "assets/images/lesson_images/level_0/section_0/lesson_1.png",
              "isCompleted": false,
              "content": "[Placeholder]",
            },
            {
              "id": 2,
              "title": "Cooking Steak",
              "type": 1,
              "imagePath":
                  "assets/images/lesson_images/level_0/section_0/lesson_1.png",
              "isCompleted": false,
              "videoPath": "assets/videos/level_0/section_1/video_1.mp4",
              "content:": "[Placeholder]",
            },
            {
              "id": 3,
              "title": "What is a Smash Burger?",
              "type": 0,
              "imagePath":
                  "assets/images/lesson_images/level_0/section_0/lesson_1.png",
              "isCompleted": false,
              "content": "[Placeholder]",
            },
            {
              "id": 4,
              "title": "Smash Burgers",
              "type": 1,
              "imagePath":
                  "assets/images/lesson_images/level_0/section_0/lesson_1.png",
              "isCompleted": false,
              "videoPath": "assets/videos/level_0/section_1/video_1.mp4",
              "content:": "[Placeholder]",
            },
          ],
          "completedLessons": 0,
          "totalLessons": 4,
        },
        {
          "id": 2,
          "title": "Introduction to Baking",
          "subtitle": "Learn the fundamentals of baking",
          "imagePath":
              "assets/images/level_section_images/level_0/section_1.png",
          "lessons": [
            {
              "id": 0,
              "title": "Wet vs Dry Ingredients",
              "type": 0,
              "imagePath":
                  "assets/images/lesson_images/level_0/section_0/lesson_1.png",
              "isCompleted": false,
              "content": "[Placeholder]",
            },

            {
              "id": 2,
              "title": "Chocolate Chip Oatmeal Cookies",
              "type": 1,
              "imagePath":
                  "assets/images/lesson_images/level_0/section_0/lesson_1.png",
              "isCompleted": false,
              "videoPath": "assets/videos/level_0/section_1/video_1.mp4",
              "content:": "[Placeholder]",
            },
            {
              "id": 3,
              "title": "Chocolate Chip Oatmeal Recipe",
              "type": 0,
              "imagePath":
                  "assets/images/lesson_images/level_0/section_0/lesson_1.png",
              "isCompleted": false,
              "content": "[Placeholder]",
            },
            {
              "id": 4,
              "title": "Blueberry Muffins",
              "type": 1,
              "imagePath":
                  "assets/images/lesson_images/level_0/section_0/lesson_1.png",
              "isCompleted": false,
              "videoPath": "assets/videos/level_0/section_1/video_1.mp4",
              "content:": "[Placeholder]",
            },
            {
              "id": 5,
              "title": "Blueberry Muffins Simulation",
              "type": 0,
              "imagePath":
                  "assets/images/lesson_images/level_0/section_0/lesson_1.png",
              "isCompleted": false,
              "content": "[Placeholder]",
            },
            {
              "id": 5,
              "title": "Blueberry Muffins Recipe",
              "type": 0,
              "imagePath":
                  "assets/images/lesson_images/level_0/section_0/lesson_1.png",
              "isCompleted": false,
              "content": "[Placeholder]",
            },
          ],
          "completedLessons": 0,
          "totalLessons": 6,
        },
        {
          "id": 2,
          "title": "Cooking a Roast Dinner",
          "subtitle": "Learn how to prepare a hearty roast dinner",
          "imagePath":
              "assets/images/level_section_images/level_0/section_1.png",
          "lessons": [
            {
              "id": 2,
              "title": "Roast Chicken Dinner",
              "type": 1,
              "imagePath":
                  "assets/images/lesson_images/level_0/section_0/lesson_1.png",
              "isCompleted": false,
              "videoPath": "assets/videos/level_0/section_1/video_1.mp4",
              "content:": "[Placeholder]",
            },
            {
              "id": 0,
              "title": "Cooking a Roast Dinner Simulation",
              "type": 0,
              "imagePath":
                  "assets/images/lesson_images/level_0/section_0/lesson_1.png",
              "isCompleted": false,
              "content": "[Placeholder]",
            },
            {
              "id": 1,
              "title": "Roast Chicken Recipe",
              "type": 0,
              "imagePath":
                  "assets/images/lesson_images/level_0/section_0/lesson_1.png",
              "isCompleted": false,
              "content": "[Placeholder]",
            },
          ],
          "completedLessons": 0,
          "totalLessons": 3,
        },
      ],
    },
  ];

  // Call the function to insert data

  try {
    // Check if this is the first run
    if (await checkIfFirstRun(db)) {
      print("This is the first run of the app");
      await insertInitialData(db, levels);
      print("Data was inserted successfully");
    } else {
      print("This is not the first run of the app");
      return;
    }
  } catch (e) {
    print('Error inserting data: $e');
  }
}
