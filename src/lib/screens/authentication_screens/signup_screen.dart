import 'package:flutter/material.dart';
import 'package:src/components/authentication_components/textbox.dart';
import 'package:src/components/authentication_components/button.dart';
import 'package:src/components/authentication_components/constant.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:src/components/common/safe_bottom_padding.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  final SupabaseClient client = Supabase.instance.client;

  bool isLoading = false;

  // create a new user with the provided details
  Future<bool> createUser({
    required final String email,
    required final String password,
    required final String confirmPassword,
    required final String firstName,
    required final String lastName,
  }) async {
    setState(() {
      isLoading = true;
    });

    try {
      if (password != confirmPassword) {
        context.showErrorMessage("Passwords do not match");
        return false;
      }

      final response = await client.auth.signUp(
        email: email,
        password: password,
      );

      final userId = response.user!.id;

      await client.from('users').insert({
        'auth_id': userId,
        'email': email,
        'first_name': firstName,
        'last_name': lastName,
      });

      return true;
    } catch (e) {

      if (mounted) {
        context.showErrorMessage('Sign up failed. Please try again.');
      }
      return false;
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // google sign-in method
  Future<void> _handleGoogleSignIn() async {
    setState(() {
      isLoading = true;
    });

    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
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

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

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
          await client.from('users').select().eq('auth_id', user.id).single();

          if (mounted) {
            Navigator.pushReplacementNamed(context, '/home');
          }
        } catch (e) {
          String firstName = '';
          String lastName = '';

          if (googleUser.displayName != null) {
            final nameParts = googleUser.displayName!.trim().split(' ');
            if (nameParts.length > 1) {
              firstName = nameParts.first;
              lastName = nameParts
                  .skip(1)
                  .join(' ');
            } else if (nameParts.length == 1) {
              firstName = nameParts.first;
              lastName = '';
            }
          }

          await client.from('users').insert({
            'auth_id': user.id,
            'email': user.email,
            'first_name': firstName,
            'last_name': lastName,
          });

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
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    double scaleFactor = 1.0;
    double logosize = 150.0;

    if (screenHeight < 650) {
      scaleFactor = 0.98;
      logosize = 120.0;
    }

    Widget content = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(Icons.kitchen, size: logosize, color: Colors.green),
        const Text(
          'Hello Chef',
          style: TextStyle(
            fontSize: 50,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        MyTextFormField(
          controller: _firstNameController,
          label: const Text('First Name'),
          obscureText: false,
        ),
        MyTextFormField(
          controller: _lastNameController,
          label: const Text('Last Name'),
          obscureText: false,
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
        MyTextFormField(
          controller: _confirmPasswordController,
          label: const Text('Confirm Password'),
          obscureText: true,
        ),
        MyButton(
          onTap:
              isLoading
                  ? null
                  : () async {
                    bool success = await createUser(
                      email: _emailController.text,
                      password: _passwordController.text,
                      confirmPassword: _confirmPasswordController.text,
                      firstName: _firstNameController.text,
                      lastName: _lastNameController.text,
                    );
                    if (success && context.mounted) {
                      Navigator.pushReplacementNamed(
                        context,
                        '/home',
                      );
                    }
                  },
          child:
              isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Sign Up'),
        ),
        const SizedBox(height: 20),
        const Text('OR', style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          onPressed: _handleGoogleSignIn,
          icon: Image.asset('assets/google_logo.png', height: 24),
          label: const Text('Sign up with Google'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 2,
            minimumSize: const Size(double.infinity, 50),
          ),
        ),
        SafeBottomPadding(
          extraPadding:
              screenHeight * 0.05,
          child: TextButton(
            onPressed: () {
              Navigator.pushNamed(context, '/login');
            },
            child: const Text(
              'Already have an account? Log in',
              style: TextStyle(color: Colors.green),
            ),
          ),
        ),
      ],
    );

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 20.0,
              horizontal: 24.0,
            ),
            child: Transform.scale(scale: scaleFactor, child: content),
          ),
        ),
      ),
    );
  }
}
