import 'package:flutter/material.dart';
import 'package:src/classes/lesson_item.dart';
import 'package:src/components/common/safe_bottom_padding.dart';

class InteractiveImageScreen extends StatefulWidget {
  final String imagePath;
  final LessonItem lessonItem;
  List<Map<String, dynamic>> buttonDetails;

  InteractiveImageScreen({
    super.key,
    required this.imagePath,
    required this.buttonDetails,
    required this.lessonItem,
  });

  @override
  State<InteractiveImageScreen> createState() => _InteractiveImageScreenState();
}

class _InteractiveImageScreenState extends State<InteractiveImageScreen> {
  // Track the highlighted button
  String? highlightedButton;
  bool showHints = false;

  @override
  void initState() {
    super.initState();
  }

  void _onComplete(context) {
    Navigator.pop(context, true);
  }

  List<Widget> makeButtons() {
    List<Widget> buttons = [];
    for (var button in widget.buttonDetails) {
      final buttonName = button['name'] as String;
      final isHighlighted = highlightedButton == buttonName || showHints;

      // Calculate exact positions and sizes
      final double top =
          MediaQuery.of(context).size.height * (button['position_y']! as num);
      final double left =
          MediaQuery.of(context).size.width * (button['position_x']! as num);
      final double width =
          MediaQuery.of(context).size.width * (button['width']! as num);
      final double height =
          MediaQuery.of(context).size.height * (button['height']! as num);

      buttons.add(
        Stack(
          children: [
            // The button itself with exact positioning
            Positioned(
              top: top,
              left: left,
              width: width,
              height: height,
              child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(
                    isHighlighted
                        ? Colors.green.withOpacity(0.3)
                        : Colors.transparent,
                  ),
                  foregroundColor: MaterialStateProperty.all(
                    Colors.transparent,
                  ),
                  shadowColor: MaterialStateProperty.all(Colors.transparent),
                  surfaceTintColor: MaterialStateProperty.all(
                    Colors.transparent,
                  ),
                  padding: MaterialStateProperty.all(EdgeInsets.zero),
                  minimumSize: MaterialStateProperty.all(Size.zero),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                      side: BorderSide(
                        color:
                            isHighlighted ? Colors.green : Colors.transparent,
                        width: 2,
                      ),
                    ),
                  ),
                ),
                onPressed: () {
                  setState(() {
                    highlightedButton = buttonName;
                  });

                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      // ...existing dialog code...
                      return Dialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 8,
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                buttonName,
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                              SizedBox(height: 16),
                              Text(
                                '${button['onPressed']}',
                                style: TextStyle(fontSize: 16),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 24),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 10,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text('Got it!'),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
                child: Container(),
              ),
            ),

            // The label positioned above the button
            if (isHighlighted)
              Positioned(
                top: top - 24, // Position just above the button
                left:
                    left +
                    (width / 2) -
                    40, // Horizontally center the label above the button
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    buttonName,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
    }
    return buttons;
  }

  void _showAllItems() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Kitchen Items',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              SizedBox(height: 16),
              Expanded(
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 2.5,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: widget.buttonDetails.length,
                  itemBuilder: (context, index) {
                    final item = widget.buttonDetails[index];
                    return ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.withOpacity(0.1),
                        foregroundColor: Colors.green,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(
                            color: Colors.green.withOpacity(0.5),
                          ),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        setState(() {
                          highlightedButton = item['name'] as String;
                        });

                        // Show dialog for the item
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return Dialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 8,
                              child: Padding(
                                padding: EdgeInsets.all(20),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      item['name'] as String,
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                      ),
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      '${item['onPressed']}',
                                      style: TextStyle(fontSize: 16),
                                      textAlign: TextAlign.center,
                                    ),
                                    SizedBox(height: 24),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        foregroundColor: Colors.white,
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 24,
                                          vertical: 10,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            24,
                                          ),
                                        ),
                                      ),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text('Got it!'),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                      child: Text(
                        item['name'] as String,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text('The Kitchen', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white), // Changed to white
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          // Help button
          IconButton(
            icon: Icon(Icons.help_outline, color: Colors.white),
            onPressed: () {
              setState(() {
                showHints = !showHints;
              });
            },
            tooltip: 'Show/Hide Hints',
          ),
          // List button
          IconButton(
            icon: Icon(Icons.list, color: Colors.white),
            onPressed: _showAllItems,
            tooltip: 'Show All Items',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Colors.green.shade50],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              margin: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    offset: Offset(0, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(Icons.touch_app, color: Colors.green),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Tap on kitchen items to learn more about them',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.green.shade800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.green.shade200, width: 2),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        offset: Offset(0, 3),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  margin: EdgeInsets.symmetric(horizontal: 16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Stack(
                      children: [
                        Image.asset(widget.imagePath),
                        ...makeButtons(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SafeBottomPadding(
              extraPadding: 8.0,
              child: Container(
                width: double.infinity,
                height: screenHeight * 0.075,
                margin: EdgeInsets.fromLTRB(8, 8, 8, 0), // Changed bottom margin from 30 to 0
                child: ElevatedButton(
                  onPressed: () => _onComplete(context),
                  child: Text('Complete', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
