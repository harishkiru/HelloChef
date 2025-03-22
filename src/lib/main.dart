import 'package:flutter/material.dart';
import 'components/home_components/main_navbar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:src/screens/authentication_screens/login_screen.dart';
import 'package:src/screens/authentication_screens/signup_screen.dart';
import 'package:src/components/authentication_components/constant.dart'
    as utils;
import 'package:media_kit/media_kit.dart';
import 'package:src/services/app_first_run.dart';
import 'package:src/services/db_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_API_KEY']!,
  );

  try {
    final dbHelper = DBHelper.instance();
    // Force all tables to be created before proceeding
    await dbHelper.ensureTablesExist();

    // Only now try to insert app first run data
    await AppFirstRun();

    MediaKit.ensureInitialized();
    runApp(const MyApp());
  } catch (e) {
    print('Fatal database initialization error: $e');
    // Add appropriate error handling
  }
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Supabase Flutter',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: // Check if the user is authenticated
          utils.client.auth.currentSession != null ? '/home' : '/',
      routes: {
        // Define the routes
        '/': (context) => const LoginPage(),
        '/signup': (context) => const SignUpPage(),
        '/login': (context) => const LoginPage(),
        '/home': (context) => const NavigationScaffold(),
      },
    );
  }
}
