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
                        onTap: () => _showUserDetails(context, user),
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
  
  // Show detailed user info with badges
  void _showUserDetails(BuildContext context, Map<String, dynamic> user) async {
    final userId = user['id'];
    final firstName = user['firstName'];
    final lastName = user['lastName'];
    final rank = user['rank'];
    final xp = user['xp'];
    final isCurrentUser = user['isCurrentUser'] ?? false;
    
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
    
    // Fetch badges for this user
    final badges = await DBHelper.instance().getUserBadgesById(userId);
    
    // Close loading dialog
    if (context.mounted) Navigator.of(context).pop();
    
    if (!context.mounted) return;
    
    // Show user details dialog
    showDialog(
      context: context,
      builder: (context) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;
        
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            width: double.maxFinite,
            constraints: const BoxConstraints(maxHeight: 500),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with user info
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        '$firstName $lastName',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Rank $rank',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '$xp XP',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (isCurrentUser)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'You',
                              style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                
                // Badges section
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Badge header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Badges',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isDarkMode ? Colors.green.shade300 : Colors.green.shade800,
                              ),
                            ),
                            Text(
                              'Unlocked: ${badges.where((b) => b['unlocked'] == true).length}/${badges.length}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: isDarkMode ? Colors.green.shade200 : Colors.green.shade800,
                              ),
                            ),
                          ],
                        ),
                        const Divider(),
                        const SizedBox(height: 8),
                        
                        // Badge grid
                        Expanded(
                          child: badges.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.emoji_events_outlined,
                                        size: 48,
                                        color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'No badges available',
                                        style: TextStyle(
                                          color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : GridView.builder(
                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 4,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 12,
                                    childAspectRatio: 1,
                                  ),
                                  itemCount: badges.length,
                                  itemBuilder: (context, index) {
                                    final badge = badges[index];
                                    final bool isUnlocked = badge['unlocked'] as bool;
                                    return GestureDetector(
                                      onTap: () => _showBadgeDetails(context, badge),
                                      child: Tooltip(
                                        message: badge['name'],
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                                            borderRadius: BorderRadius.circular(8),
                                            border: isUnlocked 
                                              ? Border.all(
                                                  color: Colors.amber[600]!,
                                                  width: 2,
                                                )
                                              : null,
                                          ),
                                          child: Stack(
                                            children: [
                                              Center(
                                                child: Opacity(
                                                  opacity: isUnlocked ? 1.0 : 0.4,
                                                  child: badge['imageUrl'] != null && badge['imageUrl'].isNotEmpty
                                                      ? _buildBadgeImage(badge['imageUrl'])
                                                      : Icon(
                                                          Icons.emoji_events,
                                                          size: 32,
                                                          color: Colors.amber[600],
                                                        ),
                                                ),
                                              ),
                                              if (!isUnlocked)
                                                Positioned(
                                                  top: 0,
                                                  right: 0,
                                                  child: Container(
                                                    padding: const EdgeInsets.all(4),
                                                    decoration: BoxDecoration(
                                                      color: Colors.black45,
                                                      borderRadius: const BorderRadius.only(
                                                        topRight: Radius.circular(8),
                                                        bottomLeft: Radius.circular(8),
                                                      ),
                                                    ),
                                                    child: const Icon(
                                                      Icons.lock,
                                                      color: Colors.white,
                                                      size: 14,
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Actions
                Container(
                  padding: const EdgeInsets.all(12),
                  child: TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      minimumSize: const Size(double.infinity, 44),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  // Show badge details
  void _showBadgeDetails(BuildContext context, Map<String, dynamic> badge) {
    final bool isUnlocked = badge['unlocked'] as bool;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: EdgeInsets.zero,
        content: Container(
          width: 300,
          padding: EdgeInsets.zero,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Badge status header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isUnlocked 
                    ? Colors.green
                    : isDarkMode ? Colors.grey[700] : Colors.grey[400],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Text(
                  isUnlocked ? 'UNLOCKED' : 'LOCKED',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Badge image
                    Container(
                      width: 80,
                      height: 80,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                        shape: BoxShape.circle,
                        border: isUnlocked 
                          ? Border.all(color: Colors.amber[600]!, width: 2)
                          : null,
                      ),
                      child: Opacity(
                        opacity: isUnlocked ? 1.0 : 0.5,
                        child: badge['imageUrl'] != null && badge['imageUrl'].isNotEmpty
                          ? _buildBadgeImage(badge['imageUrl'])
                          : Icon(
                              Icons.emoji_events,
                              size: 50,
                              color: Colors.amber[600],
                            ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Badge name
                    Text(
                      badge['name'] ?? 'Unknown Badge',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Badge description
                    Text(
                      badge['description'] ?? 'No description available',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Close',
              style: TextStyle(color: Colors.green),
            ),
          ),
        ],
      ),
    );
  }
  
  // Helper to build badge images
  Widget _buildBadgeImage(String imageUrl) {
    if (imageUrl.startsWith('http')) {
      return Image.network(
        imageUrl,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => Icon(
          Icons.emoji_events,
          size: 32,
          color: Colors.amber[600],
        ),
      );
    } 
    else if (imageUrl.startsWith('assets/')) {
      return Image.asset(
        imageUrl,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => Icon(
          Icons.emoji_events,
          size: 32,
          color: Colors.amber[600],
        ),
      );
    } 
    else {
      return Icon(
        Icons.emoji_events,
        size: 32,
        color: Colors.amber[600],
      );
    }
  }
}