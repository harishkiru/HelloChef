import 'package:flutter/material.dart';
import 'package:src/services/db_helper.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  LeaderboardScreenState createState() => LeaderboardScreenState();
}

class LeaderboardScreenState extends State<LeaderboardScreen> {
  late Future<List<Map<String, dynamic>>> _leaderboardFuture;

  @override
  void initState() {
    super.initState();
    _leaderboardFuture = DBHelper.instance().getLeaderboardData();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _leaderboardFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading leaderboard data: ${snapshot.error}',
                style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                'No users found',
                style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
              ),
            );
          }
          
          final leaderboardData = snapshot.data!;
          
          return Column(
            children: [
              // Leaderboard header
              Container(
                color: isDarkMode ? const Color(0xFF1A3020) : Colors.green.shade50,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                child: Row(
                  children: [
                    const SizedBox(width: 40, child: Text('#', style: TextStyle(fontWeight: FontWeight.bold))),
                    Expanded(
                      flex: 3,
                      child: Text(
                        'Chef',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.green.shade300 : Colors.green.shade800,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        'Rank',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.green.shade300 : Colors.green.shade800,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        'XP',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.green.shade300 : Colors.green.shade800,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        'Badges',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.green.shade300 : Colors.green.shade800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Leaderboard list
              Expanded(
                child: ListView.builder(
                  itemCount: leaderboardData.length,
                  itemBuilder: (context, index) {
                    final user = leaderboardData[index];
                    final isCurrentUser = user['isCurrentUser'] ?? false;
                    
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      elevation: isCurrentUser ? 3 : 1,
                      color: isCurrentUser 
                          ? (isDarkMode ? Colors.green.shade900.withOpacity(0.3) : Colors.green.shade50) 
                          : null,
                      child: ListTile(
                        leading: Container(
                          width: 36,
                          height: 36,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: _getPositionColor(index, isDarkMode),
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Text(
                                '${user['firstName']} ${user['lastName']}',
                                style: TextStyle(
                                  fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.normal,
                                  color: Theme.of(context).textTheme.bodyLarge?.color,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text(
                                '${user['rank']}',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isDarkMode ? Colors.green.shade300 : Colors.green.shade800,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text(
                                '${user['xp']}',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Theme.of(context).textTheme.bodyLarge?.color,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.emoji_events,
                                    size: 16,
                                    color: Colors.amber[600],
                                  ),
                                  Text(
                                    ' ${user['badgeCount']}',
                                    style: TextStyle(
                                      color: Theme.of(context).textTheme.bodyLarge?.color,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        subtitle: isCurrentUser ? const Text('You', style: TextStyle(color: Colors.green)) : null,
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
  
  // Helper method to get color for position ranking
  Color _getPositionColor(int position, bool isDarkMode) {
    switch (position) {
      case 0: // 1st place - Gold
        return Colors.amber[700]!;
      case 1: // 2nd place - Silver
        return Colors.grey[400]!;
      case 2: // 3rd place - Bronze
        return Colors.brown[400]!;
      default: // Everyone else
        return isDarkMode ? Colors.grey[700]! : Colors.grey[500]!;
    }
  }
}