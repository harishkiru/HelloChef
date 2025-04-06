import 'package:flutter/material.dart';
import 'components/home_components/main_navbar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:src/screens/authentication_screens/login_screen.dart';
import 'package:src/screens/authentication_screens/signup_screen.dart';
import 'package:src/components/authentication_components/constant.dart' as utils;
import 'package:media_kit/media_kit.dart';
import 'package:src/services/app_first_run.dart';
import 'package:src/services/db_helper.dart';
import 'package:provider/provider.dart';
import 'package:src/components/common/dark_mode.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_API_KEY']!,
  );

  try {
    final dbHelper = DBHelper.instance();

    await dbHelper.ensureTablesExist();

    await appFirstRun();

    MediaKit.ensureInitialized();

    runApp(
      ChangeNotifierProvider(
        create: (_) => ThemeProvider(),
        child: const MyApp(),
      ),
    );
  } catch (e) {
    print('Fatal database initialization error: $e');
  }
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Supabase Flutter',
        theme: themeProvider.getTheme(), // use the theme from provider
        initialRoute: // check if the user is authenticated
            utils.client.auth.currentSession != null ? '/home' : '/',
        routes: {
          '/': (context) => const LoginPage(),
          '/signup': (context) => const SignUpPage(),
          '/login': (context) => const LoginPage(),
          '/home': (context) => const NavigationScaffold(),
        },
      ),
    );
  }
}
