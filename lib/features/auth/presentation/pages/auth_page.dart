// lib/features/auth/presentation/pages/auth_page.dart
import 'package:flutter/material.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Authentication')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('This is the Auth Page'),
            // You'll build your login/signup UI here
            ElevatedButton(
              onPressed: () {
                // Example: Navigate after successful auth
                // Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const HomePage()));
              },
              child: const Text('Sign In / Sign Up'),
            ),
          ],
        ),
      ),
    );
  }
}