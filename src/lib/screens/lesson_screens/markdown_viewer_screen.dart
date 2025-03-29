import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter/material.dart';
import 'package:src/classes/lesson_item.dart';
import 'package:src/components/common/safe_bottom_padding.dart'; // Add this import
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text(
          widget.lessonItem.title,
          style: TextStyle(color: Colors.white),
        ),
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
