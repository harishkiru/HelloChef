import 'package:flutter/material.dart';
import 'package:src/components/authentication_components/textbox.dart';
import 'package:src/components/authentication_components/button.dart';
import 'package:src/components/authentication_components/constant.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  // Controllers for managing text input in form fields
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  // Supabase client instance for database and authentication operations
  final SupabaseClient client = Supabase.instance.client;

  // Boolean to track loading state for UI updates
  bool isLoading = false;

  // Function to create a new user with the provided details
  Future<bool> createUser({
    required final String email,
    required final String password,
    required final String ConfirmPassword,
    required final String firstName,
    required final String lastName,
  }) async {
    // Check if password and confirmation password match
    if (password != ConfirmPassword) {
      context.showErrorMessage("Passwords do not match");
      return false;
    }

    try {
      // Sign up the user using Supabase authentication
      final response =
          await client.auth.signUp(email: email, password: password);

      // Retrieve the user's ID after successful sign-up
      final userId = response.user!.id;

      // Insert additional user details into the 'users' table
      await client.from('users').insert({
        'auth_id': userId,
        'email': email,
        'first_name': firstName,
        'last_name': lastName,
      });

      return true; // Return true if sign-up is successful
    } catch (e) {
      // Display an error message if sign-up fails
      context.showErrorMessage('Sign up failed: $e');
      return false; // Return false on failure
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    double scaleFactor = 1.0;
    double logosize = 150.0;

    // Apply scaling for screens under 600 logical pixels
    if (screenHeight < 650) {
      scaleFactor = 0.98;
      logosize = 120.0;
    }

    // Build the content widget
    Widget content = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Display an icon at the top
        Icon(
          Icons.kitchen,
          size: logosize,
          color: Colors.green,
        ),
        // Display the app's name with styling
        const Text(
          'Hello Chef',
          style: TextStyle(
            fontSize: 50,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        // Text fields for user input
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
        // Button to trigger sign-up
        MyButton(
          onTap: () async {
            bool success = await createUser(
              email: _emailController.text,
              password: _passwordController.text,
              ConfirmPassword: _confirmPasswordController.text,
              firstName: _firstNameController.text,
              lastName: _lastNameController.text,
            );
            if (success) {
              Navigator.pushNamed(context, '/home');
            }
          },
          child: const Text('Sign Up'),
        ),
        // Text button to navigate to the login page
        TextButton(
          onPressed: () {
            Navigator.pushNamed(context, '/login');
          },
          child: const Text(
            'Already have an account? Log in',
            style: TextStyle(color: Colors.green),
          ),
        ),
      ],
    );

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0), // Slight vertical padding
            child: Transform.scale(
              scale: scaleFactor,
              child: content,
            ),
          ),
        ),
      ),
    );
  }
}