import 'package:flutter/material.dart';
import '../practice/practice_tile.dart';

class PracticeRecipe extends StatelessWidget {
  final PracticeTile item;
  const PracticeRecipe({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(item.title),
        backgroundColor: Colors.green,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Back button functionality
          },
        ),
      ),
      body: Column(
        children: [
          Image.network(item.imageUrl, width: double.infinity, fit: BoxFit.cover),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              item.subtitle,
              style: TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }
}