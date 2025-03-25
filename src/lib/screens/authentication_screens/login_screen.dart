import 'package:flutter/material.dart';
import 'package:src/components/authentication_components/textbox.dart';
import 'package:src/components/authentication_components/button.dart';
import 'package:src/components/authentication_components/constant.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:src/services/db_helper.dart';
import 'package:src/components/common/safe_bottom_padding.dart'; // Add this import
import 'package:google_sign_in/google_sign_in.dart'; // Add this import
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Add this import

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
        Navigator.pushReplacementNamed(context, '/home');  // Changed from pushNamed to pushReplacementNamed
      }
    } on AuthException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Authentication failed. Please check your credentials.',
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
          content: const Text(
            'Unexpected error occurred. Please try again later.',
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

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Initialize with your web client ID
      final GoogleSignIn googleSignIn = GoogleSignIn(
        // Add this line - use your Web client ID here
        serverClientId: dotenv.env['GOOGLE_CLIENT_ID'],
        scopes: ['email', 'profile'],
      );
      
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      
      if (googleUser == null) {
        setState(() {
          isLoading = false;
        });
        return;
      }
      
      // Print full user details for debugging
      print("Google user data: ${googleUser.displayName}, ${googleUser.email}, ${googleUser.id}");
      
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      // Print auth tokens for debugging
      print("Access token: ${googleAuth.accessToken != null ? 'Present' : 'Missing'}");
      print("ID token: ${googleAuth.idToken != null ? 'Present' : 'Missing'}");
      
      if (googleAuth.idToken == null) {
        throw Exception("Failed to get ID token from Google");
      }
      
      final AuthResponse res = await client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: googleAuth.idToken!,
        accessToken: googleAuth.accessToken,
      );
      
      if (res.session != null) {
        final user = res.session!.user;
        
        try {
          // Check if user exists in your custom users table
          await client
              .from('users')
              .select()
              .eq('auth_id', user.id)
              .single();
          
          // User exists, navigate to home
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/home');
          }
        } catch (e) {
          print("User not found in custom table, creating entry: $e");
          // User doesn't exist in custom table, create entry
          String firstName = '';
          String lastName = '';

          // Better name splitting logic
          if (googleUser.displayName != null) {
            final nameParts = googleUser.displayName!.trim().split(' ');
            if (nameParts.length > 1) {
              // If there are multiple parts, first part is firstName, rest is lastName
              firstName = nameParts.first;
              lastName = nameParts.skip(1).join(' '); // Join all remaining parts for lastName
            } else if (nameParts.length == 1) {
              // If only one part, use it as firstName
              firstName = nameParts.first;
              lastName = '';
            }
          }

          final result = await client.from('users').insert({
            'auth_id': user.id,
            'email': user.email,
            'first_name': firstName,
            'last_name': lastName,
          }).select();
          
          print("Insert result: $result");
          
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/home');
          }
        }
      }
    } catch (e) {
      print("Detailed Google sign-in error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Google sign-in failed: ${e.toString()}',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.green,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
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
      body: SafeArea(
        child: SingleChildScrollView(
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
                  const SizedBox(height: 20),
                  const Text('OR', style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _handleGoogleSignIn,
                    icon: Image.asset('assets/google_logo.png', height: 24),  // Add this image to your assets
                    label: const Text('Sign in with Google'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      elevation: 2,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                  ),
                  // Wrap the TextButton in SafeBottomPadding
                  SafeBottomPadding(
                    extraPadding: screenHeight * 0.05, // Dynamic padding based on screen height
                    child: TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/signup');
                      },
                      child: const Text(
                        "Don't have an account? Sign Up",
                        style: TextStyle(color: Colors.green),
                      ),
                    ),
                  ),
                  // Remove the fixed SizedBox at the bottom
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}