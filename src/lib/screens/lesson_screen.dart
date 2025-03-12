import 'package:flutter/material.dart';
import 'package:src/classes/lesson_item.dart';
import 'package:src/classes/level_section.dart';
import 'package:src/screens/level_section_screen.dart';
import 'package:src/classes/level.dart';
import 'package:src/components/lesson_level_card.dart';
import 'package:src/screens/test_screen.dart';
import 'package:src/components/user_profile.dart';
import 'package:src/classes/quiz.dart';

class LessonScreen extends StatefulWidget {
  const LessonScreen({super.key});

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  // Temporary data used for testing purposes
  List<Level> levels = [
    Level(
      id: 0,
      level: 0,
      title: "Level 0",
      subtitle: "Kitchen Foundations",
      imagePath: "assets/images/level_images/level_0.png",
      isCompleted: true,
      sections: [
        LevelSection(
          id: 0,
          title: "Before You Start",
          subtitle: "Learn common tools, equipment, and ingredients.",
          imagePath: "assets/images/level_section_images/level_0/section_0.png",
          lessons: [
            LessonItem(
              id: 0,
              title: "Common Kitchen Tools",
              type: 0,
              imagePath:
                  "assets/images/level_section_images/level_0/section_0.png",
              isCompleted: true,
              content: '''
# Common Kitchen Tools
![Photo](assets/images/lesson_markdown_images/level_0/section_0/lesson_0/0.png)

## Introduction
Before getting started in the kitchen there is a variety of tools you should have on hand inorder to make learning how to cook easier. You will likely have most of these items already so you will probably only have to worry about picking up a couple items. You do not need to invest in them all at once but as you get more comfortable in the kitchen you will find that having the right tools will make your life easier. I have for the convenience broken down these items into sections based on importance.

## Essential Tools
- Medium to large sized frying pan
- Medium to large sized pot
- Baking sheet
- Eating Utensils 
- Cutting Board
- Plates and Bowls
- A Sharp Knife
- A meat thermometer of some kind
- A can opener
- A Spatual
- A Sponge

These are the most important tools to have in your kitchen. You will use these tools on a daily basis and they are essential to cooking. You can get by without the other tools but these are a must have.

## Recommended Tools
- Multiple sized pots and pans
- An instant read thermometer
- Tongs
- Multiple baking sheets
- Vegetable peeler
- Garlic press
- Multiple sized food storage containers
- Reusable salt and pepper shakers
- Reusable spice and herb containers
- Multiple cutting boards
- Measuring cups and spoons
- A whisk
- A blender
- A colander
- A range of knives

These are tools that are not essential but are very helpful to have in the kitchen. You will find that having these tools will make your life easier and will make cooking more enjoyable.
''',
            ),

            LessonItem(
              id: 1,
              title: "Common Ingredients",
              type: 0,
              imagePath:
                  "assets/images/lesson_images/level_0/section_0/lesson_2.png",
              isCompleted: false,
              content: ''' 
# Common Ingredients
![Photo](assets/images/lesson_markdown_images/level_0/section_0/lesson_1/0.png)

## Introduction
When you are first starting out in the kitchen it can be hard to know what ingredients you should have on hand. Just like music, recipes borrow alot of ingredients from one another so having a stock of common ingredients can make cooking dishes on demand much easier. This list is a great starting point for anyone who is just starting out in the kitchen. You will find that having these ingredients on hand will make cooking easier and more enjoyable. Just like with the tools list I have compiled these ingredients into two different lists based on their importance.

## Essential Ingredients
- Salt
- Pepper
- Some kind of oil (vegetable, olive, Avocado)
- Garlic Powder
- Onion Powder
- Flour
- Sugar

These ingredients are in almost every recipe you will find in some form so it is highly recommended you buy larger containers of these items to save time and money.

## Recommended Ingredients
- Eggs
- Milk
- Butter
- Baking Powder
- Baking Soda
- Vanilla Extract
- Soy Sauce
- Worcestershire Sauce
- Ketchup
- Mustard
- Mayonnaise
- White and balsamic vinegar
- Dried Rosemary
- Dried Thyme
- Dried Oregano
- Dried Basil
- Dried Parsley
- Cumin
- Chili Powder
- Ground Mustard Seed
- Cayenne Pepper
- Chicken/beef/vegetable stock and/or bouillon
- White Rice
- Dried Pasta
- Lemon Juice
- Lime Juice
- Sliced Bread

These ingredients are commonly used in recipes and are recommended to have on hand. Its important to note some of these ingredients are perishable so you may not want to buy them in large quantities or without a plan.



                  ''',
            ),
            LessonItem(
              id: 2,
              title: "Kitchen Setup & Cleanup",
              type: 1,
              imagePath:
                  "assets/images/lesson_images/level_0/section_0/lesson_1.png",
              videoPath: "assets/videos/level_0/section_0/video_0.mp4",
              isCompleted: false,
            ),
            LessonItem(
              id: 3,
              title: "Video Transcript",
              type: 2,
              imagePath:
                  "assets/images/lesson_images/level_0/section_0/lesson_1.png",
              content: '''
# Getting Started 

Alright, let's get started. Before we begin cooking, we need to learn how to prepare our kitchen for cooking and how to clean up afterward. 

The first thing we're going to wanna do is clean up any mess that may already exist in the kitchen. Clearing the space is going to be important to keep an organized and safe environment.

![Photo](assets/images/lesson_transcript_images/level_0/section_0/transcript_0/0.png)

Next, we're going to want to wipe every surface we will be working on with a clean, damp rag, making sure to sweep up any crumbs while we're at it. 

![Photo](assets/images/lesson_transcript_images/level_0/section_0/transcript_0/1.png)

A good thing to also have on hand is a couple of clean, dry bar towels that can be used to dry surfaces on demand.

![Photo](assets/images/lesson_transcript_images/level_0/section_0/transcript_0/2.png)

If we are going to cook with the stove, now is also a good time to turn on the kitchen fan. 

The last thing we are going to do is wash our hands using warm water and soap, making sure to get a good clean wash under the nails as well. 

![Photo](assets/images/lesson_transcript_images/level_0/section_0/transcript_0/5.png)

With the kitchen and our hands clean, we can now start preparing our food.
… 
Now that we have finished cooking, we should clean the kitchen so it will be convenient for the next time it needs to be used. 

Make sure to either dispose of or properly refrigerate any perishable unused ingredients, or you could just eat them…

Using a dishwasher can heavily cut down on the amount of dishes we need to wash so it is heavily recommended you use one to make cleaning faster.

For dishes that may not fit easily or are simply not dishwashable, we can easily clean them ourselves with hot water, dish soap, and a sponge. 

![Photo](assets/images/lesson_transcript_images/level_0/section_0/transcript_0/3.png)

If you have a drying rack setup, you can wash all the dishes and dry them separately to improve efficiency.

After you are done with the dishes you should then wash out the sink making sure to remove any material caught in the trap.

It is once again recommended that you clean all the surfaces used when cooking as it’ll be much easier now than it will be later. 

After drying all surfaces and any pools around the sink, you should now remove the towels used when cooking to be washed as they are no longer clean. Remember, even a towel that only wiped up water is still not going to be clean if left to fester. 

With that, the kitchen is clean. Good stuff

![Photo](assets/images/lesson_transcript_images/level_0/section_0/transcript_0/4.png)

''',
              isCompleted: false,
            ),
            LessonItem(
              id: 3,
              title: "Common Quiz",
              type: 3,
              imagePath:
                  "assets/images/lesson_images/level_0_section_0_lesson_2.png",
              isCompleted: false,
              quiz: Quiz(
                title: "Kitchen Basics Quiz",
                description: "Test your knowledge of kitchen basics!",
                questions: [
                  QuizQuestion(
                    question:
                        "Which of the following is NOT a common kitchen tool?",
                    options: ["Spatula", "Whisk", "Blender", "Power drill"],
                    correctAnswerIndex: 3,
                  ),
                  QuizQuestion(
                    question: "What is the primary use of a colander?",
                    options: [
                      "Mixing ingredients",
                      "Draining liquids",
                      "Measuring ingredients",
                      "Cutting vegetables",
                    ],
                    correctAnswerIndex: 1,
                  ),
                  QuizQuestion(
                    question: "Which knife is best for chopping vegetables?",
                    imagePath: "assets/images/quiz/chef_knife.png",
                    options: [
                      "Paring knife",
                      "Chef's knife",
                      "Bread knife",
                      "Butter knife",
                    ],
                    correctAnswerIndex: 1,
                  ),
                  QuizQuestion(
                    question: "What is the main purpose of a food processor?",
                    options: [
                      "Brewing coffee",
                      "Blending smoothies",
                      "Chopping and mixing ingredients",
                      "Toasting bread",
                    ],
                    correctAnswerIndex: 2,
                  ),
                ],
              ),
            ),
          ],
          completedLessons: 0,
        ),
        LevelSection(
          id: 1,
          title: "Kitchen Safety",
          subtitle: "Learn how to safely use kitchen tools and equipment.",
          imagePath: "assets/images/level_section_images/level_0/section_1.png",
          lessons: [
            LessonItem(
              id: 0,
              title: "Food Safety",
              type: 1,
              imagePath:
                  "assets/images/lesson_images/level_0/section_0/lesson_1.png",
              videoPath: "assets/videos/level_0/section_1/video_0.mp4",
              isCompleted: false,
            ),
            LessonItem(
              id: 1,
              title: "Video Transcript",
              type: 2,
              imagePath:
                  "assets/images/lesson_images/level_0/section_0/lesson_1.png",
              content: '''
# Food Safety

Contamination is one of the easiest ways to make yourself or others sick in the kitchen, so it is important to understand what you should be doing to minimize the chances of this happening.

![Photo](assets/images/lesson_transcript_images/level_0/section_1/transcript_0/0.png)

When storing raw meat, it is important that it be stored in a tightly secured bag or container and placed away from other foods in the fridge. It is important to note that the amount of time you can safely store meat in the fridge widely depends on the temperature of the fridge and the best-before date provided by the seller. 

![Photo](assets/images/lesson_transcript_images/level_0/section_1/transcript_0/1.png)

Generally, with most fridges, it is safe to store meat up to the posted date but definitely not past this time, as bacteria and toxins can build up to unsafe levels. 

![Photo](assets/images/lesson_transcript_images/level_0/section_1/transcript_0/2.png)

When preparing raw meats for cooking, make sure to a separate cutting board or plate to interact with the meat. Never use the same surface for prepared and raw ingredients. This is called cross contamination, and it should be avoided at all times. 

After you're done working with the raw meat and are going to touch something else, be sure to wash your hands no matter what 

Any contaminated surface needs to be cleaned before it can come in contact with a non-contaminated surface or item

Also, make sure to check that the internal temperature of the meat you're cooking is safe to consume before removing it from the heat. This can be best done with an instant read thermometer. 

![Photo](assets/images/lesson_transcript_images/level_0/section_1/transcript_0/3.png)

When working with fresh fruits and vegetables make sure to rinse them off with cold water before consuming them as this helps to remove any toxins that could have been added during the lifetime of the food. 

Do not use soap, as soap can be absorbed by some fruits and vegetables and is not meant to be consumed. 

After you're done eating, you might have left overs. It is important for the longevity of the food that it be refrigerated as soon as possible. Make sure to use a container that isnt significantly larger then the portion of food it stores so it doesn’t take up too much space. 

![Photo](assets/images/lesson_transcript_images/level_0/section_1/transcript_0/4.png)

Different types of food can be stored safely for different times, so keep this in mind when you're looking to eat leftovers. 

![Photo](assets/images/lesson_transcript_images/level_0/section_1/transcript_0/5.png)

''',
              isCompleted: false,
            ),
            LessonItem(
              id: 2,
              title: "Heat Safety",
              type: 1,
              imagePath:
                  "assets/images/lesson_images/level_0/section_0/lesson_1.png",
              videoPath: "assets/videos/level_0/section_1/video_1.mp4",
              isCompleted: false,
            ),
            LessonItem(
              id: 3,
              title: "Video Transcript",
              type: 2,
              imagePath:
                  "assets/images/lesson_images/level_0/section_0/lesson_1.png",
              content: '''
# Heat Safety

Alright, let's talk about safe heat handling.

When working with kitchen appliances that generate heat, it is important to be aware of the risks and take proper precautions to avoid burns or accidents.

Let's start with the oven. When opening the oven door, you should always stand to the side and allow a moment for the hot air to escape before reaching in. 

![Photo](assets/images/lesson_transcript_images/level_0/section_1/transcript_1/0.png)

This is especially true after food has been cooking since water vapour builds up inside the oven and will be extremely hot. When removing food from the oven, always use oven mitts or heat-resistant gloves to protect your hands from burns. Never use a damp cloth or towel, as the moisture can conduct heat or worse turn into steam and burn you.

![Photo](assets/images/lesson_transcript_images/level_0/section_1/transcript_1/1.png)

When using the stove, it's important to keep all pan and pot handles turned inward, flush with the stove or countertop. This prevents them from being accidentally knocked over, reducing the risk of spills and burns.

![Photo](assets/images/lesson_transcript_images/level_0/section_1/transcript_1/2.png)

Additionally, if frying anything in oil, be sure to place the item in the pan facing away from you to minimize the chance of oil splashing on you.

![Photo](assets/images/lesson_transcript_images/level_0/section_1/transcript_1/3.png)

When boiling water, be extra careful when straining. Always pour away from yourself and stand out of the direct path of the steam, as steam can cause burns just as easily as boiling water. A safe approach is to use a colander placed in the sink and pour the water slowly to minimize splashing.

![Photo](assets/images/lesson_transcript_images/level_0/section_1/transcript_1/4.png)

Toasters can also be a hazard if used incorrectly. If something becomes stuck inside, never attempt to remove it with a metal utensil while the toaster is plugged in. Doing so can lead to an electric shock. Instead, unplug the toaster first, let it cool, and then use a wooden or plastic utensil to carefully dislodge the stuck item.

![Photo](assets/images/lesson_transcript_images/level_0/section_1/transcript_1/5.png)

By following these precautions, you can safely handle hot kitchen appliances and reduce the risk of burns or accidents. Stay safe and cook with confidence!


''',
              isCompleted: false,
            ),
          ],
          completedLessons: 0,
        ),
        LevelSection(
          id: 2,
          title: "Knowledge Section",
          subtitle: "Test what you've learned.",
          imagePath: "assets/images/level_section_images/level_0/section_2.png",
          lessons: List.empty(),
          completedLessons: 0,
        ),
      ],
    ),
    Level(
      id: 1,
      level: 1,
      title: "Level 1",
      subtitle: "Kitchen Something",
      imagePath: "assets/images/level_images/level_1.jpg",
      isCompleted: false,
      sections: List.empty(),
    ),
    Level(
      id: 2,
      level: 2,
      title: "Level 2",
      subtitle: "Kitchen Learning Plus",
      imagePath: "assets/images/level_images/level_2.jpg",
      isCompleted: false,
      sections: List.empty(),
    ),
    Level(
      id: 3,
      level: 3,
      title: "Level 3",
      subtitle: "Kitchen Foundations Plus Plus",
      imagePath: "assets/images/level_images/level_3.jpg",
      isCompleted: false,
      sections: List.empty(),
    ),
    Level(
      id: 4,
      level: 4,
      title: "Level 4",
      subtitle: "Kitchen Foundations",
      imagePath: "assets/images/level_images/level_0.png",
      isCompleted: false,
      sections: List.empty(),
    ),
  ];

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
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: levels.length,
              itemBuilder: (context, index) {
                return LessonLevelCard(
                  level: levels[index],
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) =>
                                LevelSectionScreen(level: levels[index]),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
