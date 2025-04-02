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

Future<void> appFirstRun() async {
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
                  "assets/images/lesson_images/level_0/section_0/lesson_0.png",
              "isCompleted": false,
              "content":
                  "# Common Kitchen Tools\n![Photo](assets/images/lesson_markdown_images/level_0/section_0/lesson_0/0.png)\n\n## Introduction\nBefore getting started in the kitchen there is a variety of tools you should have on hand inorder to make learning how to cook easier. You will likely have most of these items already so you will probably only have to worry about picking up a couple items. You do not need to invest in them all at once but as you get more comfortable in the kitchen you will find that having the right tools will make your life easier. I have for the convenience broken down these items into sections based on importance.\n\n## Essential Tools\n- Medium to large sized frying pan\n- Medium to large sized pot\n- Baking sheet\n- Eating Utensils \n- Cutting Board\n- Plates and Bowls\n- A Sharp Knife\n- A meat thermometer of some kind\n- A can opener\n- A Spatual\n- A Sponge\n\nThese are the most important tools to have in your kitchen. You will use these tools on a daily basis and they are essential to cooking. You can get by without the other tools but these are a must have.\n\n## Recommended Tools\n- Multiple sized pots and pans\n- An instant read thermometer\n- Tongs\n- Multiple baking sheets\n- Vegetable peeler\n- Garlic press\n- Multiple sized food storage containers\n- Reusable salt and pepper shakers\n- Reusable spice and herb containers\n- Multiple cutting boards\n- Measuring cups and spoons\n- A whisk\n- A blender\n- A colander\n- A range of knives\n\nThese are tools that are not essential but are very helpful to have in the kitchen. You will find that having these tools will make your life easier and will make cooking more enjoyable.\n",
            },
            {
              "id": 1,
              "title": "Common Ingredients",
              "type": 0,
              "imagePath":
                  "assets/images/lesson_images/level_0/section_0/lesson_1.png",
              "isCompleted": false,
              "content":
                  "# Common Ingredients\n![Photo](assets/images/lesson_markdown_images/level_0/section_0/lesson_1/0.png)\n\n## Introduction\nWhen you are first starting out in the kitchen it can be hard to know what ingredients you should have on hand. Just like music, recipes borrow alot of ingredients from one another so having a stock of common ingredients can make cooking dishes on demand much easier. This list is a great starting point for anyone who is just starting out in the kitchen. You will find that having these ingredients on hand will make cooking easier and more enjoyable. Just like with the tools list I have compiled these ingredients into two different lists based on their importance.\n\n## Essential Ingredients\n- Salt\n- Pepper\n- Some kind of oil (vegetable, olive, Avocado)\n- Garlic Powder\n- Onion Powder\n- Flour\n- Sugar\n\nThese ingredients are in almost every recipe you will find in some form so it is highly recommended you buy larger containers of these items to save time and money.\n\n## Recommended Ingredients\n- Eggs\n- Milk\n- Butter\n- Baking Powder\n- Baking Soda\n- Vanilla Extract\n- Soy Sauce\n- Worcestershire Sauce\n- Ketchup\n- Mustard\n- Mayonnaise\n- White and balsamic vinegar\n- Dried Rosemary\n- Dried Thyme\n- Dried Oregano\n- Dried Basil\n- Dried Parsley\n- Cumin\n- Chili Powder\n- Ground Mustard Seed\n- Cayenne Pepper\n- Chicken/beef/vegetable stock and/or bouillon\n- White Rice\n- Dried Pasta\n- Lemon Juice\n- Lime Juice\n- Sliced Bread\n\nThese ingredients are commonly used in recipes and are recommended to have on hand. Its important to note some of these ingredients are perishable so you may not want to buy them in large quantities or without a plan.\n\n\n\n                  ",
            },
            {
              "id": 2,
              "title": "Kitchen Setup & Cleanup",
              "type": 1,
              "imagePath":
                  "assets/images/lesson_images/level_0/section_0/lesson_2.png",
              "isCompleted": false,
              "videoPath": "assets/videos/level_0/section_0/video_0.mp4",
              "content:": "[Placeholder]",
            },
            {
              "id": 4,
              "title": "The Kitchen",
              "type": 4,
              "imagePath":
                  "assets/images/lesson_images/level_0/section_0/lesson_3.png",
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
                  "assets/images/lesson_images/level_0/section_1/lesson_0.png",
              "isCompleted": false,
              "videoPath": "assets/videos/level_0/section_1/video_0.mp4",
              "content:": "[Placeholder]",
            },
            {
              "id": 2,
              "title": "Heat Safety",
              "type": 1,
              "imagePath":
                  "assets/images/lesson_images/level_0/section_1/lesson_1.png",
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
                  "assets/images/lesson_images/level_0/section_2/lesson_0.png",
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
      "imagePath": "assets/images/level_images/level_1.png",
      "isCompleted": false,
      "sections": [
        {
          "id": 0,
          "title": "Knife Training",
          "subtitle":
              "Learn about the different types of knives and how to use them.",
          "imagePath":
              "assets/images/level_section_images/level_1/section_0.png",
          "lessons": [
            {
              "id": 0,
              "title": "Knife Identification",
              "type": 0,
              "imagePath":
                  "assets/images/lesson_images/level_1/section_0/lesson_0.png",
              "isCompleted": false,
              "content": '''# Essential Kitchen Knives

A guide to five essential kitchen knives, their purposes, and common uses.

---

## 1. Chef's Knife  

![Photo](assets/images/lesson_markdown_images/level_1/section_0/lesson_0/0.png)

**Purpose:**  
A versatile, all-purpose knife designed for chopping, slicing, dicing, and mincing. It has a broad, curved blade (typically 6-10 inches long) that allows for a rocking motion while cutting.  

**Common Uses:**  
- Chopping vegetables like onions, carrots, and bell peppers  
- Slicing meats such as chicken or beef  
- Mincing garlic and herbs  
- Dicing fruits like apples and melons  

---

## 2. Santoku Knife  

![Photo](assets/images/lesson_markdown_images/level_1/section_0/lesson_0/1.png)

**Purpose:**  
A Japanese-style knife with a shorter, straighter blade than a chef’s knife, often featuring a Granton edge (small divots) to reduce food sticking. It excels in precise slicing, dicing, and chopping.  

**Common Uses:**  
- Slicing fish and boneless meats  
- Dicing vegetables like cucumbers and zucchini  
- Cutting cheeses and soft foods  
- Preparing sushi and sashimi  

---

## 3. Utility Knife  

![Photo](assets/images/lesson_markdown_images/level_1/section_0/lesson_0/2.png)

**Purpose:**  
A mid-sized knife (between a chef's and paring knife) used for a variety of smaller cutting tasks where a larger knife might be cumbersome.  

**Common Uses:**  
- Slicing sandwiches and smaller loaves of bread  
- Cutting fruits like oranges and lemons  
- Trimming fat from meats  
- Slicing small vegetables like cherry tomatoes  

---

## 4. Paring Knife  

![Photo](assets/images/lesson_markdown_images/level_1/section_0/lesson_0/3.png)

**Purpose:**  
A small knife (usually 3-4 inches) designed for precision tasks such as peeling, trimming, and detailed cutting work.  

**Common Uses:**  
- Peeling apples, potatoes, and citrus fruits  
- Deveining shrimp  
- Hulling strawberries  
- Creating garnishes  

---

## 5. Bread Knife  

![Photo](assets/images/lesson_markdown_images/level_1/section_0/lesson_0/4.png)

**Purpose:**  
A serrated knife designed to slice through crusty bread and delicate pastries without crushing them. The serrated edge saws through foods rather than applying downward pressure.  

**Common Uses:**  
- Slicing loaves of bread (baguettes, sourdough, etc.)  
- Cutting cakes without compressing them  
- Slicing tomatoes and other soft fruits  
- Cutting sandwiches evenly  

---

*For best results, keep your knives sharp and use the appropriate knife for each task to improve efficiency and safety in the kitchen.*
''',
            },
            {
              "id": 1,
              "title": "Safe Knife Handling",
              "type": 1,
              "imagePath":
                  "assets/images/lesson_images/level_1/section_0/lesson_1.png",
              "isCompleted": false,
              "videoPath": "assets/videos/level_0/section_1/video_1.mp4",
              "content:": "[Placeholder]",
            },
            {
              "id": 2,
              "title": "Cutting Techniques",
              "type": 1,
              "imagePath":
                  "assets/images/lesson_images/level_1/section_0/lesson_2.png",
              "isCompleted": false,
              "videoPath": "assets/videos/level_0/section_1/video_1.mp4",
              "content:": "[Placeholder]",
            },
            {
              "id": 3,
              "title": "Knife Quiz",
              "type": 3,
              "imagePath":
                  "assets/images/lesson_images/level_1/section_0/lesson_3.png",
              "isCompleted": false,
              "quiz": {
                "title": "Knife Quiz",
                "description": "Test your knowledge of knife skills.",
                "questions": [
                  {
                    "question":
                        "Which knife is best for peeling fruits and vegetables?",
                    "options": [
                      "Utility Knife",
                      "Pairing Knife",
                      "Peeling Knife",
                      "French Knife",
                    ],
                    "correctAnswerIndex": 1,
                  },
                  {
                    "question": "What kind of knife is this?",
                    "options": [
                      "Serrated Knife",
                      "Sawing Knife",
                      "Bread Knife",
                      "French Knife",
                    ],
                    "correctAnswerIndex": 2,
                    "imagePath":
                        "assets/images/quiz_images/level_1/section_0/quiz_0/0.png",
                  },
                  {
                    "question": "What kind of knife is this?",
                    "options": [
                      "Chef's Knife",
                      "Japanese Knife",
                      "Kitchen Knife",
                      "Utility Knife",
                    ],
                    "correctAnswerIndex": 0,
                    "imagePath":
                        "assets/images/quiz_images/level_1/section_0/quiz_0/1.png",
                  },
                  {
                    "question": "What kind of knife is this?",
                    "options": [
                      "Peeling Knife",
                      "3-inch Knife",
                      "Short Knife",
                      "Pairing Knife",
                    ],
                    "correctAnswerIndex": 3,
                    "imagePath":
                        "assets/images/quiz_images/level_1/section_0/quiz_0/2.png",
                  },
                  {
                    "question": "What kind of knife is this?",
                    "options": [
                      "Regular Knife",
                      "Utility Knife",
                      "Worker Knife",
                      "Bread Knife",
                    ],
                    "correctAnswerIndex": 1,
                    "imagePath":
                        "assets/images/quiz_images/level_1/section_0/quiz_0/3.png",
                  },
                  {
                    "question":
                        "Why is it important to use a sharp knife in the kitchen?",
                    "options": [
                      "Sharper knives are easier to clean",
                      "Dull knives ruin the taste of food",
                      "Sharp knives are safer to use",
                      "It's not important to use a sharp knife",
                    ],
                    "correctAnswerIndex": 2,
                  },
                  {
                    "question":
                        "Rank the types of cuts from most to least precise.",
                    "options": [
                      "Chopped > Diced > Minced > Sliced",
                      "Chopped > Sliced > Diced > Minced",
                      "Minced > Chopped > Diced > Sliced",
                      "Minced > Diced > Chopped > Sliced",
                    ],
                    "correctAnswerIndex": 3,
                  },
                  {
                    "question":
                        "What is the best alternative to using a knife to mince garlic?",
                    "options": [
                      "Cheese Grater",
                      "Blender",
                      "Garlic Press",
                      "Food Processor",
                    ],
                    "correctAnswerIndex": 2,
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
              "assets/images/level_section_images/level_1/section_1.png",
          "lessons": [
            {
              "id": 0,
              "title": "Eggs 101",
              "type": 1,
              "imagePath":
                  "assets/images/lesson_images/level_1/section_1/lesson_0.png",
              "isCompleted": false,
              "videoPath": "assets/videos/level_0/section_1/video_0.mp4",
              "content:": "[Placeholder]",
            },
            {
              "id": 2,
              "title": "American Breakfast Simulation",
              "type": 0,
              "imagePath":
                  "assets/images/lesson_images/level_1/section_1/lesson_2.png",
              "isCompleted": false,
              "content": "[Placeholder]",
            },
            {
              "id": 3,
              "title": "American Breakfast Recipe",
              "type": 0,
              "imagePath":
                  "assets/images/lesson_images/level_1/section_1/lesson_2.png",
              "isCompleted": false,
              "content": '''# American Style Breakfast  
![American Style Breakfast](assets/images/lesson_images/level_1/section_1/lesson_2.png)

---

## Ingredients:
- Eggs (as many as desired)  
- Bacon (4-6 slices, depending on preference)  
- Hashbrowns (frozen or fresh)  
- Bread (for toast, 2 slices per person)  
- Butter (for toast)  
- Salt and pepper (for seasoning)

---

## Instructions

### 1. Prepare the Bacon:
- Heat a large skillet over medium heat.  
- Place the bacon slices in the pan, ensuring they’re not overlapping.  
- Cook for about 4-6 minutes per side, or until crispy and golden brown.  
- Remove the bacon and place on a paper towel-lined plate to drain excess fat.

### 2. Cook the Hashbrowns:
- If using frozen hashbrowns, follow package instructions (usually pan-fry in oil for about 4-6 minutes per side).  
- For fresh hashbrowns, grate potatoes and squeeze out excess water.  
- Cook in a heated pan with oil, seasoning with salt and pepper. Fry until golden and crispy, about 8-10 minutes, flipping occasionally.

### 3. Toast the Bread:
- While the bacon and hashbrowns are cooking, place bread in a toaster or on a skillet.  
- Toast until golden brown and crispy.  
- Spread butter on top of the toast while still warm.

### 4. Cook the Eggs:
- In a separate pan, heat a little butter or oil over medium heat.  
- Crack the eggs into the pan (either one at a time or as many as desired).  
- Season with salt and pepper.  
- Cook until the whites are set, and the yolks are done to your liking (sunny side up, scrambled, or over-easy).

### 5. Serve:
- Plate the eggs, bacon, hashbrowns, and toast.  
- Optionally, garnish with fresh herbs or a little extra salt and pepper to taste.

---''',
            },
          ],
          "completedLessons": 0,
          "totalLessons": 3,
        },
        {
          "id": 2,
          "title": "Introduction to Dinner",
          "subtitle":
              "Learn how to prepare some quick and easy dinner recipes and ingredients.",
          "imagePath":
              "assets/images/level_section_images/level_1/section_2.png",
          "lessons": [
            {
              "id": 0,
              "title": "How to Cook Rice",
              "type": 0,
              "imagePath":
                  "assets/images/lesson_images/level_1/section_2/lesson_0.png",
              "isCompleted": false,
              "content": '''# How to Cook Rice on the Stove

Cooking rice on the stove is a simple process, but getting the perfect texture requires the right water-to-rice ratio and cooking technique. Follow this guide to prepare fluffy, delicious rice every time.

---

## Ingredients & Tools

### Ingredients:
- **1 cup of rice** (white or brown)
- **2 cups of water** (adjust based on rice type)
- **1/2 teaspoon of salt** (optional)
- **1 teaspoon of oil or butter** (optional)

### Tools:
- Measuring cup
- Medium saucepan with lid
- Wooden spoon

---

## Step-by-Step Instructions

### Step 1: Measure and Rinse the Rice
Before cooking, measure the rice and rinse it with cold water. You can do this by putting it in a saucepan with a lid, using the lid to drain the water while keeping the rice in. This removes excess starch and prevents stickiness.  
![Photo](assets/images/lesson_markdown_images/level_1/section_2/lesson_0/0.png)

---

### Step 2: Boil the Water and Rice
In a medium saucepan, bring the measured water to a boil over medium-high heat. If using salt or oil, add it at this stage.  
![Photo](assets/images/lesson_markdown_images/level_1/section_2/lesson_0/1.png)

---

### Step 3: Cover and Simmer
Reduce the heat to low, cover the pot with a lid, and let the rice simmer.  
- **White rice:** 15-18 minutes  
- **Brown rice:** 35-40 minutes  
![Photo](assets/images/lesson_markdown_images/level_1/section_2/lesson_0/2.png)

---

### Step 4: Let It Rest
Once the cooking time is up, turn off the heat and let the rice sit, covered, for about **5-10 minutes**. This allows the rice to absorb any remaining moisture.  
![Photo](assets/images/lesson_markdown_images/level_1/section_2/lesson_0/3.png)

---

### Step 5: Serve
Your rice is now ready to serve!  
![Photo](assets/images/lesson_markdown_images/level_1/section_2/lesson_0/4.png)

---

## Tips for Perfect Rice
✅ **Use the right water-to-rice ratio:** Generally, use **2:1 for white rice** and **2.5:1 for brown rice**.  
✅ **Keep the lid on:** Lifting the lid releases steam and disrupts cooking.  
✅ **Try a rice cooker:** If you cook rice often, a rice cooker simplifies the process.  

Enjoy your perfectly cooked rice! 🍚''',
            },
            {
              "id": 1,
              "title": "How to Cook Pasta",
              "type": 0,
              "imagePath":
                  "assets/images/lesson_images/level_1/section_2/lesson_1.png",
              "isCompleted": false,
              "content": '''# How to Cook Pasta on the Stove
Cooking pasta is simple, but small details can make a big difference in texture and flavor. Follow this guide to prepare perfect pasta every time.

---

## Ingredients & Tools

### Ingredients:
- **8 oz (225g) of pasta** (spaghetti, penne, or any type)
- **4-6 cups of water** (enough to fully submerge the pasta)
- **1-2 teaspoons of salt** (for seasoning)
- **1 teaspoon of olive oil** (optional, to prevent sticking)

### Tools:
- Large pot
- Measuring cup
- Wooden spoon or tongs
- Colander (for draining)

---

## Step-by-Step Instructions

### Step 1: Boil the Water
Fill a large pot with **4-6 cups of water** and bring it to a rolling boil over high heat. Add salt to the water to enhance the pasta’s flavor.
![Photo](assets/images/lesson_markdown_images/level_1/section_2/lesson_1/0.png)

---

### Step 2: Add the Pasta
Once the water is boiling, add the pasta. Stir immediately to prevent sticking.
![Photo](assets/images/lesson_markdown_images/level_1/section_2/lesson_1/1.png)

---

### Step 3: Stir Occasionally
Let the pasta cook uncovered, stirring occasionally to ensure even cooking and prevent clumping.
![Photo](assets/images/lesson_markdown_images/level_1/section_2/lesson_1/2.png)

---

### Step 4: Check for Doneness
Cook according to the package instructions (usually **8-12 minutes** for most pasta). Taste a piece to check if it’s **"al dente"**—tender but slightly firm to the bite.
![Photo](assets/images/lesson_markdown_images/level_1/section_2/lesson_1/3.png)

---

### Step 5: Drain the Pasta
Once the pasta is done, carefully pour it into a colander to drain the water. **Do not rinse** unless making a cold pasta salad.
![Photo](assets/images/lesson_markdown_images/level_1/section_2/lesson_1/4.png)

---

### Step 6: Serve Immediately
Transfer the drained pasta to a bowl or pan, add your favorite sauce, and toss to coat evenly. Enjoy! 🍝
![Photo](assets/images/lesson_markdown_images/level_1/section_2/lesson_1/5.png)

---

## Tips for Perfect Pasta
✅ **Use plenty of water** to prevent sticking.  
✅ **Salt the water**—it enhances flavor.  
✅ **Do not add oil** unless you’re preventing sticking for storage.  
✅ **Save some pasta water** to mix into your sauce for a silkier texture.

Bon appétit! 🍽️
''',
            },
            {
              "id": 2,
              "title": "Chicken Stirfry",
              "type": 1,
              "imagePath":
                  "assets/images/lesson_images/level_1/section_2/lesson_2.png",
              "isCompleted": false,
              "videoPath": "assets/videos/level_0/section_1/video_1.mp4",
              "content:": "[Placeholder]",
            },
            {
              "id": 3,
              "title": "Chicken Stirfry Recipe",
              "type": 0,
              "imagePath":
                  "assets/images/lesson_images/level_1/section_2/lesson_3.png",
              "isCompleted": false,
              "content": '''# Teriyaki Chicken Stir-Fry  
![Teriyaki Chicken Stir-Fry](assets/images/lesson_images/level_1/section_2/lesson_3.png)

A simple, healthy, and versatile stir-fry dish that you can easily adapt by changing the protein, vegetables, or sauce.

---

## Ingredients

### For the Chicken:
- 2 chicken breasts, cubed  
- 1 tsp salt  
- ½ tsp black pepper  
- 1 tsp garlic powder  
- 1 tsp onion powder  

### For the Vegetables:
- 1 head broccoli, cut into bite-sized florets  
- 1 bell pepper, sliced  
- 3 cloves garlic, minced  
- 1 onion, sliced  
- 2 carrots, peeled and sliced into thin rounds  
- 1 tbsp cooking oil  
- Salt & pepper to taste  

### For the Rice:
- 1 cup rice  
- 2 cups chicken broth  
- ½ tsp salt  
- ½ tsp black pepper  
- 2 tbsp butter  

### For the Sauce:
- 1 cup teriyaki sauce (store-bought or homemade)

---

## Instructions

### Step 1: Prep the Chicken
- Cube the chicken into bite-sized pieces.  
- Season with salt, pepper, garlic powder, and onion powder. Toss to coat.  
- Wash hands and clean the cutting board.

### Step 2: Prep the Vegetables
- Wash the broccoli, bell pepper, and carrots.  
- Cut the broccoli into florets.  
- Slice the bell pepper into strips, removing the core and white flesh.  
- Mince the garlic (a garlic press can save time).  
- Peel and slice the onion into thin strips.  
- Peel and slice the carrots into even-sized rounds.

### Step 3: Cook the Chicken
- Heat oil in a large pan over medium heat.  
- Add the chicken and cook for about 10 minutes.  
- Check the internal temperature—it should be about 20-25°F below the safe cooking temp (165°F) since it will cook again later.  
- Remove from the pan and set aside.

### Step 4: Start the Rice
- Bring chicken broth to a boil.  
- Add rice, reduce heat, and cover.  
- Stir occasionally to prevent sticking.

### Step 5: Cook the Vegetables
- In the same pan, add onions and garlic. Stir and season with salt & pepper.  
- After 5-10 minutes, when onions are browned, add the broccoli, bell peppers, and carrots.  
- Season again with salt & pepper and cover with a lid.  
- Stir occasionally to ensure even cooking.

### Step 6: Finish the Rice
- Once the broth is mostly absorbed, add salt, pepper, and butter.  
- Taste test:  
  - If crunchy, add 1 more cup of water and increase heat.  
  - If too salty, add more pepper and butter.  
  - If bland, adjust seasoning.  
- Cover and remove from heat.

### Step 7: Combine Everything
- Once vegetables are tender, pour in the teriyaki sauce and stir.  
- Add the cooked chicken back into the pan and cover.  
- Cook on medium-low for 5-10 minutes.  
- Final taste test: adjust salt if needed.

### Step 8: Serve
- In a bowl or deep plate, spoon rice as the base.  
- Add stir-fry over the rice, making sure to include plenty of sauce.

---
''',
            },
            {
              "id": 4,
              "title": "Tomato Beef Pasta",
              "type": 1,
              "imagePath":
                  "assets/images/lesson_images/level_1/section_2/lesson_4.png",
              "isCompleted": false,
              "videoPath": "assets/videos/level_0/section_1/video_1.mp4",
              "content:": "[Placeholder]",
            },
            {
              "id": 5,
              "title": "Tomato Beef Pasta Recipe",
              "type": 0,
              "imagePath":
                  "assets/images/lesson_images/level_1/section_2/lesson_5.png",
              "isCompleted": false,
              "content": '''# Simple and Easy Creamy Beef Pasta

![Photo](assets/images/lesson_images/level_1/section_2/lesson_5.png)

## Ingredients:

- 1 onion, diced
- 3 cloves garlic, minced (or use a garlic press)
- 2 tbsp oil
- Salt and pepper, to taste
- 1 lb (450g) ground beef
- 1 tsp thyme
- 1 tsp rosemary
- 12 oz (340g) pasta (shell shape recommended)
- Water for boiling
- 2 cups store-bought pasta sauce
- 1/2 cup heavy cream
- Fresh parsley, for garnish (optional)
- Shredded cheese, for garnish (optional)

## Instructions:

### Prepare the Ingredients:
1. Dice the onion by cutting it in half, slicing lengthwise, then widthwise.
2. Mince the garlic or use a garlic press.

### Sauté the Aromatics:
1. Preheat a pan with oil over medium heat.
2. Once hot, add diced onion and minced garlic.
3. Season with salt and pepper.
4. Cook until the onions turn golden brown.

### Boil the Pasta:
1. Fill a pot with water and season it with salt.
2. Bring the water to a boil.

### Cook the Ground Beef:
1. Add ground beef to the pan with browned onions.
2. Season with salt, pepper, thyme, and rosemary.
3. Break up the meat into small, pebble-sized pieces.
4. Stir occasionally and cook until browned.

### Cook the Pasta:
1. Once the water is boiling, add the pasta.
2. Stir occasionally to prevent sticking.
3. Cook according to package instructions, tasting a piece near the end to check for doneness.
4. Strain the pasta about a minute before perfect doneness and return to the pot.

### Make the Sauce:
1. Once the ground beef is fully cooked, taste-test for seasoning.
2. Add store-bought pasta sauce, ensuring the meat is well coated.
3. Increase heat slightly if the sauce isn't bubbling.
4. Let simmer for 10-15 minutes to reduce excess water.

### Finish with Cream:
1. Add heavy cream to the meat sauce, stirring well.
2. The sauce should change from red to a creamy orange hue.

### Combine Pasta and Sauce:
1. Stir the pasta into the sauce until well combined.
2. Cover the pan and let it finish cooking for 5 minutes, stirring occasionally to prevent burning.

### Final Taste Test:
1. Adjust seasoning if necessary.

### Serve and Garnish:
1. Plate the pasta in a bowl.
2. Garnish with fresh parsley and shredded cheese.
3. Enjoy!

''',
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
      "imagePath": "assets/images/level_images/level_2.png",
      "isCompleted": false,
      "sections": [
        {
          "id": 2,
          "title": "Useful Knowledge and Skills",
          "subtitle": "Tips and tricks for in the kitchen",
          "imagePath":
              "assets/images/level_section_images/level_2/section_0.png",
          "lessons": [
            {
              "id": 2,
              "title": "Carryover Cooking",
              "type": 0,
              "imagePath":
                  "assets/images/lesson_images/level_2/section_0/lesson_0.png",
              "isCompleted": false,
              "content": '''# Understanding Carryover Cooking

Carryover cooking is the process where food continues to cook even after being removed from a heat source. This happens because residual heat retained in the food continues to distribute and raise the internal temperature.

---

## How Carryover Cooking Works

When you remove food from an oven, grill, or stovetop, the heat stored in the outer layers moves inward. This process causes the internal temperature of the food to **rise by 5-10°F (3-6°C)**, depending on the type and thickness of the food.

![Photo](assets/images/lesson_markdown_images/level_2/section_0/lesson_1/0.png)

---

## Foods That Experience Carryover Cooking

Certain foods retain heat more than others, affecting how much their temperature continues to rise after cooking.

### Meats:
- **Beef, pork, and lamb roasts** – Can increase **5-10°F** after resting
- **Steaks and chops** – Increase **3-5°F** after resting
- **Poultry** – Can increase **5-10°F**, especially larger birds

![Photo](assets/images/lesson_markdown_images/level_2/section_0/lesson_1/1.png)

---

## How to Use Carryover Cooking to Your Advantage

Understanding carryover cooking can help prevent **overcooking** and achieve **perfect doneness**.

### 1. Remove Food Early
Since food continues cooking off the heat, take it off **a few degrees before** your target temperature.

**Example:**
- If you want **medium-rare steak (130°F / 54°C)**, remove it at **125°F (52°C)** and let it rest.

![Photo](assets/images/lesson_markdown_images/level_2/section_0/lesson_1/2.png)

---

### 2. Let the Food Rest
Resting allows the heat to evenly distribute, keeping juices inside the meat rather than spilling out when cut.

- **Small cuts** (steaks, chops) → Rest **5-10 minutes**
- **Large roasts** → Rest **15-30 minutes**
- **Poultry (whole chickens, turkeys)** → Rest **20-40 minutes**

![Photo](assets/images/lesson_markdown_images/level_2/section_0/lesson_1/3.png)

---

## Conclusion

Carryover cooking is an essential concept in cooking that helps achieve **perfect doneness** while avoiding overcooked, dry food. By understanding **when to remove food from heat** and **how long to let it rest**, you can enhance your cooking skills and create better-tasting dishes!

Happy cooking! 🍽️
''',
            },
            {
              "id": 1,
              "title": "Wet Brines vs Dry Brines",
              "type": 0,
              "imagePath":
                  "assets/images/lesson_images/level_2/section_0/lesson_1.png",
              "isCompleted": false,
              "content": '''# Wet vs Dry Brining: A Comparison
Brining is a process of soaking meat in a solution of salt and water (wet brine) or just applying salt (dry brine) to improve flavor and moisture retention. Let's explore the key differences between the two techniques.

---

## What is Wet Brining?
Wet brining involves submerging meat in a water-salt solution. This method allows the meat to absorb moisture and flavor from the brine.

### Wet Brine Ingredients:
- **Water** (enough to cover the meat)
- **Salt** (usually 1 cup of salt for every gallon of water)
- **Optional**: Sugar, herbs, spices, garlic, or citrus

### How to Wet Brine:
1. Dissolve salt (and any optional ingredients) in water.
2. Submerge the meat completely in the brine.
3. Refrigerate for several hours or overnight.
4. Remove and pat dry before cooking.

![Photo](assets/images/lesson_markdown_images/level_2/section_0/lesson_0/0.png)

---

## What is Dry Brining?
Dry brining involves rubbing salt directly onto the surface of the meat and letting it rest for a period of time. This method draws moisture from the meat, which then reabsorbs along with the salt.

### Dry Brine Ingredients:
- **Salt** (about 1 teaspoon per pound of meat)
- **Optional**: Herbs, spices, or citrus zest

### How to Dry Brine:
1. Rub salt evenly over the surface of the meat.
2. Rest the meat uncovered in the refrigerator for several hours or overnight.
3. Cook the meat without rinsing.

![Photo](assets/images/lesson_markdown_images/level_2/section_0/lesson_0/1.png)

---

## Key Differences Between Wet and Dry Brining

### 1. **Moisture Retention**
- **Wet Brine**: The meat absorbs some of the brine, leading to increased moisture content.
- **Dry Brine**: The salt draws out moisture, which is then reabsorbed into the meat, enhancing flavor and texture.

---

### 2. **Flavor Profile**
- **Wet Brine**: Adds flavor throughout the meat, but sometimes dilutes the natural taste of the meat.
- **Dry Brine**: Enhances the meat’s natural flavor by concentrating the seasoning and allowing flavors to penetrate deeply.

---

### 3. **Skin and Crispiness**
- **Wet Brine**: The skin of the meat may be less crispy due to the extra moisture.
- **Dry Brine**: The skin crisps up better because there is less surface moisture.

![Photo](assets/images/lesson_markdown_images/level_2/section_0/lesson_0/2.png)

---

### 4. **Time and Effort**
- **Wet Brine**: Requires a large container and the meat to be fully submerged, which may take up refrigerator space.
- **Dry Brine**: Simpler and takes up less space, as the meat only needs to be rubbed with salt and placed on a rack.

![Photo](assets/images/lesson_markdown_images/level_2/section_0/lesson_0/3.png)

---

## Pros and Cons of Wet Brining

### Pros:
- Increases moisture content of lean meats.
- Can result in a juicier finished product.

### Cons:
- Can dilute the meat's natural flavor.
- Requires extra space and a container for brining.

---

## Pros and Cons of Dry Brining

### Pros:
- Enhances flavor concentration.
- Produces a crispier skin.
- Takes up less space.

### Cons:
- Doesn’t add moisture to the meat.

---

## Conclusion
Both wet and dry brining are effective methods for enhancing meat. Choose based on your desired texture, flavor, and cooking method!

![Photo](assets/images/lesson_markdown_images/level_2/section_0/lesson_0/4.png)

Happy cooking! 🍽️
''',
            },
            {
              "id": 4,
              "title": "The Chicken",
              "type": 4,
              "imagePath":
                  "assets/images/interactive_images/level_2/section_0/interactive_0/0.png",
              "isCompleted": false,
              "buttonDetails": [
                {
                  'name': 'Left Chicken Breast',
                  'position_x': 0.25,
                  'position_y': 0.07,
                  'width': 0.2,
                  'height': 0.2,
                  'onPressed':
                      'Lean meat, great for grilling, sautéing, or baking. Often used in sandwiches, salads, or chicken breasts with sauces. Can be cubed for stir-fry or soups.',
                },
                {
                  'name': 'Right Chicken Breast',
                  'position_x': 0.5,
                  'position_y': 0.07,
                  'width': 0.2,
                  'height': 0.2,
                  'onPressed':
                      'Lean meat, great for grilling, sautéing, or baking. Often used in sandwiches, salads, or chicken breasts with sauces. Can be cubed for stir-fry or soups.',
                },
                {
                  'name': 'Left Chicken Thigh',
                  'position_x': 0.02,
                  'position_y': 0.25,
                  'width': 0.15,
                  'height': 0.13,
                  'onPressed':
                      'More flavorful and tender than breasts, ideal for braising, roasting, grilling, or frying. Great for slow-cooked dishes like stews or curries.',
                },
                {
                  'name': 'Right Chicken Thigh',
                  'position_x': 0.72,
                  'position_y': 0.25,
                  'width': 0.175,
                  'height': 0.15,
                  'onPressed':
                      'More flavorful and tender than breasts, ideal for braising, roasting, grilling, or frying. Great for slow-cooked dishes like stews or curries.',
                },
                {
                  'name': 'Left Chicken Leg',
                  'position_x': 0.175,
                  'position_y': 0.3,
                  'width': 0.22,
                  'height': 0.125,
                  'onPressed':
                      'Flavorful and juicy, best for roasting, grilling, or deep frying. Often used in BBQ or baked with spices.',
                },
                {
                  'name': 'Right Chicken Leg',
                  'position_x': 0.5,
                  'position_y': 0.3,
                  'width': 0.22,
                  'height': 0.125,
                  'onPressed':
                      'Flavorful and juicy, best for roasting, grilling, or deep frying. Often used in BBQ or baked with spices.',
                },
                {
                  'name': 'Left Chicken Wing',
                  'position_x': 0.04,
                  'position_y': 0.15,
                  'width': 0.2,
                  'height': 0.075,
                  'onPressed':
                      'Popular for grilling, frying, or baking. Often used in appetizers or party dishes, typically coated with sauces like buffalo or BBQ.',
                },
                {
                  'name': 'Right Chicken Wing',
                  'position_x': 0.7,
                  'position_y': 0.15,
                  'width': 0.2,
                  'height': 0.075,
                  'onPressed':
                      'Popular for grilling, frying, or baking. Often used in appetizers or party dishes, typically coated with sauces like buffalo or BBQ.',
                },

                // Add more button details here
              ],
            },
            {
              "id": 4,
              "title": "Spatchcocking",
              "type": 1,
              "imagePath":
                  "assets/images/lesson_images/level_2/section_0/lesson_3.png",
              "isCompleted": false,
              "videoPath": "assets/videos/level_0/section_1/video_1.mp4",
              "content:": "[Placeholder]",
            },
            {
              "id": 0,
              "title": "Kitchen Tips Quiz",
              "type": 3,
              "imagePath":
                  "assets/images/lesson_images/level_2/section_0/lesson_4.png",
              "isCompleted": false,
              "quiz": {
                "title": "Kitchen Basics Quiz",
                "description": "Test your knowledge of section content",
                "questions": [
                  {
                    "question": "How do you spatchcock a chicken?",
                    "options": [
                      "By salting it overnight",
                      "By cooking it in a pressure cooker",
                      "By removing the spine and flattening it",
                      "By boiling it",
                    ],
                    "correctAnswerIndex": 2,
                  },
                  {
                    "question":
                        "What is the main difference between wet and dry brining?",
                    "options": [
                      "Wet brining involves soaking in a saltwater solution while dry brining uses salt alone",
                      "Dry brining is faster than wet brining",
                      "Wet brining is only for poultry",
                      "Dry brining is only for red meat",
                    ],
                    "correctAnswerIndex": 0,
                  },
                  {
                    "question": "What is carryover cooking?",
                    "options": [
                      "Meat continues to cook after being removed from heat because it's still in the pan",
                      "Meat continues to cook after being removed from heat because the internal temperature is warmer then the external temperature",
                      "Meat continues to cook after being removed from heat because the warmth from the room is absorbed",
                      "Meat continues to cook after being removed from heat due to residual heat",
                    ],
                    "correctAnswerIndex": 3,
                  },
                  {
                    "question":
                        "How long should you ideally leave meat in a wet brine?",
                    "options": ["1 hour", "Overnight", "2-3 hours", "48 hours"],
                    "correctAnswerIndex": 1,
                  },
                  {
                    "question": "What is the name of this cut of chicken?",
                    "options": ["Breast", "Thigh", "Wing", "Drumstick"],
                    "correctAnswerIndex": 1,
                    "imagePath":
                        "assets/images/quiz_images/level_2/section_0/quiz_0/0.png",
                  },
                  {
                    "question":
                        "What is the benefit of spatchcocking a chicken?",
                    "options": [
                      "It cooks faster and more evenly",
                      "It makes the chicken feed more people",
                      "It makes the chicken look more appealing",
                      "It makes the chicken less greasy",
                    ],
                    "correctAnswerIndex": 0,
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
              "assets/images/level_section_images/level_2/section_1.png",
          "lessons": [
            {
              "id": 0,
              "title": "Different cuts of beef and their uses",
              "type": 0,
              "imagePath":
                  "assets/images/lesson_images/level_2/section_1/lesson_0.png",
              "isCompleted": false,
              "content": '''# Understanding Beef Cuts: Types and Best Uses
Beef comes in a variety of cuts, each with its unique characteristics and ideal cooking methods. Understanding these cuts will help you choose the best one for your next meal.

---

## 1. **Chuck**
![Photo](assets/images/lesson_markdown_images/level_2/section_1/lesson_0/0.png)
The chuck comes from the shoulder area and is known for being flavorful but a bit tougher. It's perfect for slow-cooking methods that help break down the fibers.

### Best For:
- **Stews and pot roasts**
- **Ground beef**
- **Slow cooking (braising, simmering)**

---

## 2. **Rib**
![Photo](assets/images/lesson_markdown_images/level_2/section_1/lesson_0/1.png)
The rib cut is known for its tenderness and rich marbling. This cut is highly prized for steaks and prime rib roasts.

### Best For:
- **Ribeye steaks**
- **Prime rib**
- **Grilling or pan-searing**

---

## 3. **Loin**
![Photo](assets/images/lesson_markdown_images/level_2/section_1/lesson_0/2.png)
The loin is located in the rear back section of the cow and is known for its tenderness. It’s the source of some of the most sought-after cuts, including the tenderloin and T-bone.

### Best For:
- **Filet mignon** (from the tenderloin)
- **T-bone and Porterhouse steaks**
- **Grilling or pan-searing**

---

## 4. **Round**
![Photo](assets/images/lesson_markdown_images/level_2/section_1/lesson_0/3.png)
The round is from the rear leg of the cow and is a lean, economical cut. It can be tough if not cooked correctly, but it’s great for roasting or slow-cooking.

### Best For:
- **Roasts (top round, eye of round)**
- **Stews and braising**
- **Grilling (when marinated)**

---

## 5. **Brisket**
![Photo](assets/images/lesson_markdown_images/level_2/section_1/lesson_0/4.png)
The brisket comes from the chest area of the cow and is known for its rich flavor. It has a lot of connective tissue, which breaks down well when slow-cooked.

### Best For:
- **Barbecuing or smoking**
- **Braised dishes**
- **Corned beef**

---

## 6. **Flank**
![Photo](assets/images/lesson_markdown_images/level_2/section_1/lesson_0/5.png)
The flank is a lean cut from the lower abdominal area. It has a lot of flavor, but it can be tough, so it’s important to slice it thinly against the grain.

### Best For:
- **Grilling or stir-frying**
- **Fajitas**
- **Marinated dishes**

---

## 7. **Short Ribs**
![Photo](assets/images/lesson_markdown_images/level_2/section_1/lesson_0/6.png)
Short ribs come from the rib section but are cut into shorter portions. They have a lot of meat and are perfect for slow cooking.

### Best For:
- **Braised dishes**
- **Barbecue**
- **Slow-cooked soups and stews**

---

## 8. **Skirt Steak**
![Photo](assets/images/lesson_markdown_images/level_2/section_1/lesson_0/7.png)
Skirt steak is a flavorful but thin cut from the diaphragm area. It’s often used in Mexican cuisine for dishes like fajitas and stir-fries.

### Best For:
- **Grilling**
- **Stir-frying**
- **Tacos and fajitas**

---

## 9. **Sirloin**
![Photo](assets/images/lesson_markdown_images/level_2/section_1/lesson_0/8.png)
The sirloin is a versatile cut from the rear back portion of the cow. It’s flavorful and tender, making it great for grilling or pan-searing.

### Best For:
- **Grilling steaks**
- **Stews and stir-fry**
- **Roasting**

---

## Conclusion
Understanding the different cuts of beef and their best uses will help you get the most flavor and tenderness from your meat. Choose based on your cooking method, whether it’s grilling, braising, or slow cooking!

Happy cooking! 🍽️
''',
            },
            {
              "id": 2,
              "title": "Cooking Steak",
              "type": 1,
              "imagePath":
                  "assets/images/lesson_images/level_2/section_1/lesson_1.png",
              "isCompleted": false,
              "videoPath": "assets/videos/level_0/section_1/video_1.mp4",
              "content:": "[Placeholder]",
            },
            {
              "id": 4,
              "title": "Smash Burgers",
              "type": 1,
              "imagePath":
                  "assets/images/lesson_images/level_2/section_1/lesson_2.png",
              "isCompleted": false,
              "videoPath": "assets/videos/level_0/section_1/video_1.mp4",
              "content:": "[Placeholder]",
            },
          ],
          "completedLessons": 0,
          "totalLessons": 3,
        },
        {
          "id": 2,
          "title": "Introduction to Baking",
          "subtitle": "Learn the fundamentals of baking",
          "imagePath":
              "assets/images/level_section_images/level_2/section_2.png",
          "lessons": [
            {
              "id": 0,
              "title": "Wet vs Dry Ingredients",
              "type": 0,
              "imagePath":
                  "assets/images/lesson_images/level_2/section_2/lesson_0.png",
              "isCompleted": false,
              "content":
                  '''# Key Aspects of Baking: Understanding Techniques and Tools

Baking involves a lot of precision, and understanding key aspects such as wet vs dry ingredients, how to measure ingredients properly, and the difference between hand mixing and machine-assisted mixing can make a huge difference in your results.

---

## 1. **Wet vs Dry Ingredients**

In baking, understanding the difference between wet and dry ingredients is crucial as they interact differently in the mixing process and affect the final texture of your baked goods.

### Wet Ingredients:
![Photo](assets/images/lesson_markdown_images/level_2/section_2/lesson_0/0.png)

Wet ingredients are typically liquids that are essential to the dough or batter. They help activate dry ingredients like flour, and also contribute to moisture.

- **Examples**: Water, milk, eggs, oils, butter, vanilla extract
- **Purpose**: Add moisture, activate leavening agents, and help bind dry ingredients together.

### Dry Ingredients:
![Photo](assets/images/lesson_markdown_images/level_2/section_2/lesson_0/1.png)

Dry ingredients are typically powders or solid ingredients that provide structure and stability to your baked goods. They need to be mixed well to prevent clumping.

- **Examples**: Flour, sugar, baking soda, salt, spices
- **Purpose**: Provide structure, sweetness, and the necessary chemical reactions (like leavening).

---

## 2. **How to Measure Ingredients Properly**

![Photo](assets/images/lesson_markdown_images/level_2/section_2/lesson_0/2.png)

Accurate measurement of ingredients is critical to successful baking. Too much or too little of one ingredient can affect the texture, taste, and structure of your baked goods. Here’s how to measure wet and dry ingredients properly:

### Wet Ingredients:
- **Use a liquid measuring cup** (with a spout for pouring) for wet ingredients.
- **Fill to the correct measurement line** and check at eye level for accuracy.

![Photo](assets/images/lesson_markdown_images/level_2/section_2/lesson_0/3.png)

### Dry Ingredients:
- **Use a dry measuring cup** for ingredients like flour, sugar, or cocoa powder.
- **Spoon the dry ingredient into the cup** (do not scoop directly, as it may pack the ingredient and cause over-measurement).
- **Level off** the ingredient with a flat edge to ensure accuracy.

---

## 3. **Hand Mixing vs. Machine-Assisted Mixing**

![Photo](assets/images/lesson_markdown_images/level_2/section_2/lesson_0/4.png)

Mixing your ingredients properly is key to achieving the right texture in your baked goods. Whether you choose to mix by hand or use a machine depends on the recipe and the desired results.

### Hand Mixing:
- **Best For**: Simple recipes like muffins, cookies, or pie dough where overmixing could result in tough baked goods.
- **Advantages**: Gives you control over texture and prevents overmixing. It’s also more personal and can be a relaxing activity!
- **Method**: Use a wooden spoon, whisk, or spatula to mix the ingredients gently.

![Photo](assets/images/lesson_markdown_images/level_2/section_2/lesson_0/5.png)

### Machine-Assisted Mixing:
- **Best For**: Recipes that require thorough mixing or aeration, like bread, cakes, and batters. Machines can handle tough tasks like kneading dough or beating egg whites.
- **Advantages**: Saves time and energy, especially for large batches. It ensures even mixing and consistency.
- **Method**: Use a stand mixer or handheld electric mixer, adjusting speed and attachments as needed.

---

## Conclusion

![Photo](assets/images/lesson_markdown_images/level_2/section_2/lesson_0/6.png)

Understanding the difference between wet and dry ingredients, how to measure them properly, and the tools for mixing can make all the difference in your baking results. With practice, these techniques will help you create the perfect baked goods every time.

Happy baking! 🍰🍽️
''',
            },

            {
              "id": 2,
              "title": "Chocolate Chip Oatmeal Cookies",
              "type": 1,
              "imagePath":
                  "assets/images/lesson_images/level_2/section_2/lesson_1.png",
              "isCompleted": false,
              "videoPath": "assets/videos/level_0/section_1/video_1.mp4",
              "content:": "[Placeholder]",
            },
            {
              "id": 3,
              "title": "Chocolate Chip Oatmeal Recipe",
              "type": 0,
              "imagePath":
                  "assets/images/lesson_images/level_2/section_2/lesson_2.png",
              "isCompleted": false,
              "content": '''# Oatmeal Chocolate Chip Cookies  
![Oatmeal Chocolate Chip Cookies](assets/images/lesson_images/level_2/section_2/lesson_2.png)

**Yield:** Approximately 24 cookies (depending on size)

---

## Ingredients:
- 1 cup brown sugar  
- 1 cup white sugar  
- 1 cup butter (softened)  
- 2 eggs  
- 12 oz chocolate chips  
- 1 tsp baking powder  
- 1/2 tsp salt  
- 1 tsp baking soda  
- 1 tsp vanilla extract  
- 2 cups all-purpose flour  
- 2 1/2 cups oats (rolled oats)

---

## Instructions

### 1. Preheat Oven:
- Preheat your oven to 400°F (200°C).  
- Line a baking sheet with parchment paper or lightly grease it.

### 2. Cream Butter and Sugars:
- In a large mixing bowl, cream together the butter, brown sugar, and white sugar until the mixture is light and fluffy.

### 3. Add Eggs and Vanilla:
- Beat in the eggs, one at a time.  
- Stir in the vanilla extract.

### 4. Combine Dry Ingredients:
- In a separate bowl, whisk together the flour, baking powder, baking soda, and salt.

### 5. Mix Dry and Wet Ingredients:
- Gradually add the dry ingredients to the wet ingredients, mixing until just combined.

### 6. Add Oats and Chocolate Chips:
- Stir in the oats and chocolate chips until evenly distributed.

### 7. Scoop Dough:
- Use a cookie scoop or tablespoon to drop dough onto the prepared baking sheet.  
- Leave about 2 inches of space between each cookie.

### 8. Bake:
- Bake for 8 minutes or until the cookies are golden brown around the edges.  
- The centers may still appear slightly soft, but they will firm up as they cool.

### 9. Cool:
- Let the cookies cool on the baking sheet for a few minutes before transferring them to a wire rack to cool completely.

---''',
            },
            {
              "id": 4,
              "title": "Blueberry Muffins",
              "type": 1,
              "imagePath":
                  "assets/images/lesson_images/level_2/section_2/lesson_3.png",
              "isCompleted": false,
              "videoPath": "assets/videos/level_0/section_1/video_1.mp4",
              "content:": "[Placeholder]",
            },
            {
              "id": 5,
              "title": "Blueberry Muffins Simulation",
              "type": 0,
              "imagePath":
                  "assets/images/lesson_images/level_2/section_2/lesson_5.png",
              "isCompleted": false,
              "content": "[Placeholder]",
            },
            {
              "id": 5,
              "title": "Blueberry Muffins Recipe",
              "type": 0,
              "imagePath":
                  "assets/images/lesson_images/level_2/section_2/lesson_5.png",
              "isCompleted": false,
              "content": '''# The Best Blueberry Muffins Ever  
![Blueberry Muffins](assets/images/lesson_images/level_2/section_2/lesson_5.png)

**Yield:** 8 muffins (or 12 smaller muffins)  
**Prep time:** 15 minutes  
**Cook time:** 25 minutes  
**Total time:** 40 minutes  

---

## Ingredients

### Muffin Ingredients:
- 2/3 cup white sugar  
- 1 large egg  
- 1/2 cup vegetable oil OR melted butter  
- 1/3 cup milk  
- 1 teaspoon vanilla extract  
- 1 1/4 cups all-purpose flour (or gluten-free mix)  
- 1 teaspoon baking powder  
- 1/4 teaspoon salt  
- 1/2 cup sour cream (can substitute with yogurt)  
- 1 cup blueberries  
- About 1 tablespoon white sugar for the topping (optional)

---

## Instructions

### 1. Preheat the Oven:
- Preheat the oven to 375°F (190°C).  
- Optionally, grease your muffin tin lightly to prevent muffin tops from sticking, and insert muffin liners if desired.

### 2. Mix Wet Ingredients:
- In a large bowl, combine sugar, egg, oil (or melted butter), milk, and vanilla.  
- Stir until everything is well combined.

### 3. Add Dry Ingredients:
- Add flour, baking powder, and salt to the wet mixture.  
- To avoid using an extra bowl, stir the baking powder and salt into the flour before adding them to the wet ingredients.  
- Stir until just combined — be careful not to overmix.

### 4. Add Sour Cream and Blueberries:
- Gently fold in the sour cream until well distributed.  
- Then, fold in the blueberries.  
- Reserve about half of the blueberries for topping the muffins before baking.

### 5. Distribute the Batter:
- Evenly distribute the batter among the muffin tin cups.  
- For tall, high-crowned muffins, fill the muffin tin all the way to the top.  
- For smaller muffins, fill 12 cups.  
- Optionally, sprinkle the reserved blueberries on top, pressing them lightly into the batter.  
- Sprinkle 1 tablespoon of sugar over the tops for added sweetness and shine.

### 6. Bake the Muffins:
- Bake for about 25 minutes or until a toothpick inserted into the center comes out clean.  
- If using frozen blueberries, increase the baking time by about 5 minutes.  
- Adjust the baking time based on the number of muffins being made.

### 7. Cool and Store:
- Let the muffins cool in the pan for a few minutes before transferring them to a wire rack.  
- To keep them extra moist, place them in a sealed container while they are still warm.

---

## Notes:
- If you prefer the flavor of butter, use melted butter instead of vegetable oil.
- For jumbo muffins, use a jumbo muffin tin and bake at 350°F (175°C) for about 40 minutes.''',
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
              "assets/images/level_section_images/level_2/section_3.png",
          "lessons": [
            {
              "id": 2,
              "title": "Roast Chicken Dinner",
              "type": 1,
              "imagePath":
                  "assets/images/lesson_images/level_2/section_3/lesson_0.png",
              "isCompleted": false,
              "videoPath": "assets/videos/level_0/section_1/video_1.mp4",
              "content:": "[Placeholder]",
            },
            {
              "id": 0,
              "title": "Cooking a Roast Dinner Simulation",
              "type": 0,
              "imagePath":
                  "assets/images/lesson_images/level_2/section_3/lesson_2.png",
              "isCompleted": false,
              "content": "[Placeholder]",
            },
            {
              "id": 1,
              "title": "Roast Chicken Recipe",
              "type": 0,
              "imagePath":
                  "assets/images/lesson_images/level_2/section_3/lesson_2.png",
              "isCompleted": false,
              "content": '''# Roast Chicken Dinner Recipe  
![Roast Chicken Dinner](assets/images/lesson_images/level_2/section_3/lesson_2/0.png)

---

## Ingredients:
- 1 whole chicken (brined overnight, either wet or dry)  
- 1 spatchcocked chicken (brined overnight, either wet or dry)  
- Olive oil  
- 2 sweet potatoes, peeled and chopped  
- 1 head of broccoli, rinsed and chopped  
- Salt  
- Black pepper  
- Garlic powder  
- Chili flakes  
- Onion powder  

---

## Equipment:
- Oven  
- Baking pans  
- Cutting board  
- Knife  
- Tongs  
- Timer  
- Meat thermometer  

---

## Instructions

### 1. Preheat the Oven:
- Set the oven to 400°F (or 375°F for convection ovens).

### 2. Prepare the Chickens:
- Coat both the whole and spatchcocked chickens in olive oil.  
- If possible, use chickens of similar size for more consistent cooking times.

### 3. Cooking Sequence Plan:
- **Whole chicken:** 75 minutes  
- **Spatchcocked chicken:** 50 minutes  
- **Sweet potatoes:** 35 minutes  
- **Broccoli:** 15 minutes

### 4. Start Cooking:
- Place the whole chicken in the oven and set a timer for 25 minutes.  
- After 25 minutes, add the spatchcocked chicken and set a new timer for 20 minutes.

### 5. Prepare the Vegetables:
- Peel and chop the sweet potatoes.  
- Rinse and chop the broccoli.

### 6. Season the Vegetables:
- **Sweet Potatoes:** Toss with olive oil, salt, pepper, and garlic powder.  
- **Broccoli:** Toss with olive oil, salt, pepper, chili flakes, and onion powder.

### 7. Continue Cooking:
- When the 20-minute timer goes off, add the sweet potatoes and set another timer for 15 minutes.  
- Flip the whole chicken to ensure even cooking.

### 8. Final Steps:
- When the next timer goes off, add the broccoli and set the final timer for 15 minutes.  
- Check the temperature of both chickens using a meat thermometer. The whole chicken may be done early; if so, remove it and let it rest.  
- If desired, finish the spatchcocked chicken under the broiler for added color, but watch closely to prevent burning.

### 9. Rest & Serve:
- Let the chicken rest for 10-20 minutes before carving.  
- Serve with the roasted vegetables.

---''',
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
