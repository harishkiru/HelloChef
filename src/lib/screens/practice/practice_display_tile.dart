import 'package:flutter/material.dart';
import '../practice/practice_tile.dart';

class TileMaker extends StatelessWidget {
  final PracticeTile item;
  const TileMaker({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Redirect on tap
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('REDIRECTING!')),
        );
      },
      // Create individual tiles
      child: Card(
        color: Colors.green,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                child: Image.network(
                  item.imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (context, error, stackTrace) => Icon(Icons.error),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Text(item.title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  SizedBox(height: 4),
                  Text(item.subtitle, style: TextStyle(fontSize: 14, color: Colors.white)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
