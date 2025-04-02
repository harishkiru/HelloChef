import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter/material.dart';
import 'package:src/components/common/safe_bottom_padding.dart'; // Add this import
import 'package:src/components/common/gamification_widget.dart';
import 'package:src/components/common/greyed_out_widget.dart';

// ![Photo](assets/images/lesson_markdown_images/level_1/section_0/lesson_0/0.png)
void main() {
  runApp(
    MaterialApp(
      home: MarkdownViewerScreen(
        markdown: '''# Key Aspects of Baking: Understanding Techniques and Tools

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
      ),
    ),
  );
}

class MarkdownViewerScreen extends StatefulWidget {
  final String markdown;
  const MarkdownViewerScreen({super.key, required this.markdown});

  @override
  State<MarkdownViewerScreen> createState() => _MarkdownViewerScreenState();
}

class _MarkdownViewerScreenState extends State<MarkdownViewerScreen> {
  late ScrollController _scrollController;
  bool reachedBottom = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent) {
      print("User reached the bottom!");
      setState(() {
        reachedBottom = true;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text("example text", style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Markdown(
                  controller: _scrollController,
                  data: widget.markdown,
                  imageBuilder: (uri, title, alt) {
                    return Image.asset(uri.toString());
                  },
                ),
              ),
              // Replace fixed margin with SafeBottomPadding
              SafeBottomPadding(
                extraPadding: 16.0,
                child: Container(
                  width: double.infinity,
                  margin: EdgeInsets.fromLTRB(
                    8,
                    8,
                    8,
                    0,
                  ), // Changed bottom margin from 40 to 0
                  child:
                      reachedBottom ? GamificationWidget() : GreyedOutWidget(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
