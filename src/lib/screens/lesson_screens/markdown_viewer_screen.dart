import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter/material.dart';
import 'package:src/classes/lesson_item.dart';
import 'package:src/components/common/safe_bottom_padding.dart';
import 'package:src/components/common/gamification_widget.dart';
import 'package:src/components/common/greyed_out_widget.dart';

class MarkdownViewerScreen extends StatefulWidget {
  final String markdown;
  final LessonItem lessonItem;

  const MarkdownViewerScreen({
    super.key,
    required this.markdown,
    required this.lessonItem,
  });

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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text(
          widget.lessonItem.title,
          style: const TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
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
                  styleSheet: MarkdownStyleSheet(
                    // Use theme text colors
                    p: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
                    h1: TextStyle(
                      fontSize: 24, 
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.green.shade300 : Colors.green.shade800,
                    ),
                    h2: TextStyle(
                      fontSize: 22, 
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.green.shade300 : Colors.green.shade800,
                    ),
                    h3: TextStyle(
                      fontSize: 18, 
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.green.shade300 : Colors.green.shade800,
                    ),
                    em: TextStyle(fontStyle: FontStyle.italic, color: Theme.of(context).textTheme.bodyLarge?.color),
                    strong: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color),
                    blockquote: TextStyle(
                      color: isDarkMode ? Colors.grey.shade300 : Colors.grey.shade700,
                      fontStyle: FontStyle.italic,
                    ),
                    code: TextStyle(
                      fontFamily: 'monospace',
                      backgroundColor: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
                      color: isDarkMode ? Colors.green.shade300 : Colors.green.shade700,
                    ),
                    codeblockDecoration: BoxDecoration(
                      color: isDarkMode ? Colors.grey.shade900 : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
              SafeBottomPadding(
                extraPadding: 16.0,
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                  child: reachedBottom ? GamificationWidget() : GreyedOutWidget(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
