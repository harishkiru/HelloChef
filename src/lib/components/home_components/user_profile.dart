import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:src/services/db_helper.dart';
import 'package:src/services/drop_all_tables.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:src/components/common/dark_mode.dart';

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
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '$firstName $lastName',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                          ),
                        ),
                      ],
                    );
                  }
                },
              ),
            ),
          ),
          // Settings option removed
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, _) => SwitchListTile(
              secondary: const Icon(Icons.dark_mode),
              title: const Text('Dark Mode'),
              value: themeProvider.isDarkMode,
              onChanged: (_) {
                themeProvider.toggleTheme();
                Navigator.pop(context);
              },
            ),
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () {
              Navigator.pop(context);
              showDialog(
                context: context,
                builder:
                    (context) => AlertDialog(
                      title: const Text('Logout'),
                      content: const Text('Are you sure you want to log out?'),
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
          ListTile(
            leading: const Icon(Icons.delete),
            title: const Text('Delete Local Data'),
            onTap: () async {
              Navigator.pop(context);
              showDialog(
                context: context,
                builder:
                    (context) => AlertDialog(
                      title: const Text('Delete Local Data'),
                      content: const Text(
                        'Are you sure you want to delete all local data? This action cannot be undone.',
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
}
