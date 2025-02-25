import 'package:flutter/material.dart';
import 'components/main_navbar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:src/screens/login_screen.dart';
import 'package:src/screens/signup_screen.dart';
import 'package:src/components/constant.dart' as utils;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_API_KEY']!,
  );

  runApp(const MyApp());
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
