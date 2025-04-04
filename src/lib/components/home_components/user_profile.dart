import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:src/services/db_helper.dart';
import 'package:src/services/drop_all_tables.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:src/components/common/dark_mode.dart';
import 'package:src/screens/leaderboard_screen.dart';

class UserProfileIcon extends StatelessWidget {
  const UserProfileIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const CircleAvatar(
        backgroundImage: AssetImage('assets/images/profile_placeholder.png'),
      ),
      onPressed: () {
        Scaffold.of(context).openEndDrawer();
      },
    );
  }
}

class UserProfileDrawer extends StatelessWidget {
  const UserProfileDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          SizedBox(
            height: 115,
            child: DrawerHeader(
              decoration: const BoxDecoration(color: Colors.green),
              child: FutureBuilder<Map<String, dynamic>?>(
                future: DBHelper.instance().getUserDetails(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    );
                  } else {
                    final firstName =
                        snapshot.data?['first_name']?.toString() ?? 'First';
                    final lastName =
                        snapshot.data?['last_name']?.toString() ?? 'Last';
                    return Row(
                      children: [
                        const CircleAvatar(
                          backgroundImage: AssetImage(
                            'assets/images/profile_placeholder.png',
                          ),
                          radius: 30,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            '$firstName $lastName',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    );
                  }
                },
              ),
            ),
          ),
          
          // XP and Level Progress
          _buildXpProgressSection(context),
          
          // Badges Section
          _buildBadgesSection(context),
          
          const Divider(),
          
          // Dark Mode Toggle
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, _) => SwitchListTile(
              secondary: Icon(
                Icons.dark_mode,
                color: isDarkMode ? Colors.green[300] : Colors.green[700],
              ),
              title: Text(
                'Dark Mode',
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              value: themeProvider.isDarkMode,
              onChanged: (_) {
                themeProvider.toggleTheme();
                Navigator.pop(context);
              },
            ),
          ),
          
          // Leaderboard Option
          ListTile(
            leading: Icon(
              Icons.leaderboard,
              color: isDarkMode ? Colors.green[300] : Colors.green[700],
            ),
            title: Text(
              'Leaderboard',
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            onTap: () {
              Navigator.pop(context); // Close drawer
              Navigator.push(
                context, 
                MaterialPageRoute(builder: (context) => const LeaderboardScreen()),
              );
            },
          ),
          
          // Logout Option
          ListTile(
            leading: Icon(
              Icons.logout,
              color: isDarkMode ? Colors.green[300] : Colors.green[700],
            ),
            title: Text(
              'Logout',
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            onTap: () {
              Navigator.pop(context);
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(
                    'Logout',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  content: Text(
                    'Are you sure you want to log out?',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () async {
                        await Supabase.instance.client.auth.signOut();
                        if (context.mounted) {
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            '/',
                            (route) => false,
                          );
                        }
                      },
                      child: const Text(
                        'Yes',
                        style: TextStyle(color: Colors.green),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'No',
                        style: TextStyle(color: Colors.green),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          
          // Delete Local Data Option
          ListTile(
            leading: Icon(
              Icons.delete,
              color: isDarkMode ? Colors.green[300] : Colors.green[700],
            ),
            title: Text(
              'Delete Local Data',
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            onTap: () async {
              Navigator.pop(context);
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(
                    'Delete Local Data',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  content: Text(
                    'Are you sure you want to delete all local data? This action cannot be undone.',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () async {
                        final db = DBHelper.instance();
                        await db.sqliteDatabase.then((database) async {
                          await dropAllTables(database);
                        });
                        await db.ensureTablesExist();
                        SystemNavigator.pop();
                      },
                      child: const Text(
                        'Yes',
                        style: TextStyle(color: Colors.green),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'No',
                        style: TextStyle(color: Colors.green),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // XP and Level Progress Section
  Widget _buildXpProgressSection(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: FutureBuilder<Map<String, dynamic>>(
        future: DBHelper.instance().getUserXpAndRank(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: CircularProgressIndicator(),
              ),
            );
          } else if (snapshot.hasError) {
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  'Error loading level data',
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyMedium?.color
                  ),
                ),
              ),
            );
          }
          
          final data = snapshot.data!;
          final currentXP = data['currentXP'] as int;
          final currentRank = data['currentRank'] as int;
          final nextRank = data['nextRank'] as int;
          final progress = data['progress'] as double;
          final xpForNextRank = data['xpForNextRank'] as int;
          final xpNeeded = xpForNextRank - currentXP;
          
          return Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Rank $currentRank',  // Changed from 'Level $currentRank'
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.green[300] : Colors.green[700],
                        ),
                      ),
                      Text(
                        '$currentXP XP',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: isDarkMode ? Colors.grey[800] : Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isDarkMode ? Colors.green[400]! : Colors.green,
                      ),
                      minHeight: 10,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$xpNeeded XP until Rank $nextRank',  // Changed from 'Level $nextRank'
                    style: TextStyle(
                      fontSize: 14,
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Badges Section
  Widget _buildBadgesSection(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
            child: Text(
              'Badges',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.green[300] : Colors.green[700],
              ),
            ),
          ),
          FutureBuilder<List<Map<String, dynamic>>>(
            future: DBHelper.instance().getAllBadgesWithUnlockStatus(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              } else if (snapshot.hasError) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                      'Error loading badges: ${snapshot.error}',
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyMedium?.color
                      ),
                    ),
                  ),
                );
              }
              
              final badges = snapshot.data!;
              
              if (badges.isEmpty) {
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.emoji_events_outlined,
                            size: 48,
                            color: isDarkMode ? Colors.grey[500] : Colors.grey[400],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'No badges available',
                            style: TextStyle(
                              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }
              
              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Count of unlocked badges
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Text(
                          'Unlocked: ${badges.where((b) => b['unlocked'] == true).length}/${badges.length}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.green[200] : Colors.green[800],
                          ),
                        ),
                      ),
                      // Badge grid
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: badges.map((badge) {
                          final bool isUnlocked = badge['unlocked'] as bool;
                          return GestureDetector(
                            onTap: () => _showBadgeDetails(context, badge),
                            child: Tooltip(
                              message: badge['name'],
                              child: Container(
                                width: 60,
                                height: 60,
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
                                          padding: EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: Colors.black45,
                                            borderRadius: BorderRadius.only(
                                              topRight: Radius.circular(8),
                                              bottomLeft: Radius.circular(8),
                                            ),
                                          ),
                                          child: Icon(
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
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  // Add this method to show badge details popup
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
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Text(
                  isUnlocked ? 'UNLOCKED' : 'LOCKED',
                  textAlign: TextAlign.center,
                  style: TextStyle(
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
                      padding: EdgeInsets.all(8),
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
            child: Text(
              'Close',
              style: TextStyle(color: Colors.green),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadgeImage(String imageUrl) {
    // Check if the URL starts with 'http' or 'https' (a web URL)
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
    // If it starts with 'assets/' treat it as an app asset
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
    // Default fallback
    else {
      return Icon(
        Icons.emoji_events,
        size: 32,
        color: Colors.amber[600],
      );
    }
  }
}
