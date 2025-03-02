import 'package:flutter/material.dart';
import 'package:src/components/textbox.dart';
import 'package:src/components/button.dart';
import 'package:src/components/constant.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:src/services/db_helper.dart'; // Import the updated DBHelper class

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Initialize controllers for email and password
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool isLoading = false;

  // Initialize the database helper
  final dbHelper = DBHelper.instance();

  // Auto-fill credentials if stored in local database
  void _autoFillCredentials() async {
    final credentials = await dbHelper.getCredentials();
    if (credentials != null) {
      setState(() {
        _emailController.text = credentials['username'] ?? '';
        _passwordController.text = credentials['password'] ?? '';
      });
    }
  }

  // Save credentials to local database after successful login
  Future<void> _saveCredentials(String email, String password) async {
    await dbHelper.saveCredentials(email, password);
  }

  // Handle user login
  Future<void> _handleLogin() async {
    setState(() {
      isLoading = true;
    });

    try {
      await client.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Save credentials locally
      await _saveCredentials(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      // Navigate to home screen
      if (mounted) {
        Navigator.pushNamed(context, '/home');
      }
    } on AuthException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error.message,
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.green,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Unexpected error',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.green,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _autoFillCredentials(); // Attempt to auto-fill credentials on load
  }

  @override
  Widget build(BuildContext context) {
    // Get the screen height in logical pixels
    final screenHeight = MediaQuery.of(context).size.height;
    double scaleFactor = 1.0;
    double logosize = 150.0;

    // Apply scaling for screens under 600 logical pixels
    if (screenHeight < 650) {
      scaleFactor = 0.98;
      logosize = 120.0;
    }

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Transform.scale(
            scale: scaleFactor,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: screenHeight * 0.1), // Add some top padding
                Icon(
                  Icons.kitchen,
                  size: logosize,
                  color: Colors.green,
                ),
                const Text(
                  'Hello Chef',
                  style: TextStyle(
                    fontSize: 50,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                MyTextFormField(
                  controller: _emailController,
                  label: const Text('Email Address'),
                  obscureText: false,
                ),
                MyTextFormField(
                  controller: _passwordController,
                  label: const Text('Password'),
                  obscureText: true,
                ),
                MyButton(
                  onTap: isLoading ? null : _handleLogin,
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Login'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/signup');
                  },
                  child: const Text(
                    "Don't have an account? Sign Up",
                    style: TextStyle(color: Colors.green),
                  ),
                ),
                SizedBox(height: screenHeight * 0.1), // Add some bottom padding
              ],
            ),
          ),
        ),
      ),
    );
  }
}