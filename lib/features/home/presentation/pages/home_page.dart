// lib/features/home/presentation/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// Corrected import: AuthEvent and SignOutRequested are defined in auth_bloc.dart
import 'package:fwitgi_app/features/auth/presentation/bloc/auth_bloc.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // Dispatch a SignOutRequested event when the logout button is pressed
              // This will trigger the AuthBloc to sign out the user,
              // and the AuthWrapper will then navigate back to the LoginPage.
              context.read<AuthBloc>().add(SignOutRequested());
            },
          ),
        ],
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome! You are authenticated.',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 20),
            // You can add more content here that belongs to your app's home screen
          ],
        ),
      ),
    );
  }
}