// lib/core/common/widgets/auth_wrapper.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fwitgi_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:fwitgi_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:fwitgi_app/features/auth/presentation/pages/login_page.dart';
import 'package:fwitgi_app/features/dashboard/presentation/pages/dashboard_page.dart'; // <--- CHANGE THIS IMPORT TO DashboardPage
// import 'package:fwitgi_app/features/home/presentation/pages/home_page.dart'; // <--- REMOVE THIS IMPORT

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          print('Auth Success! User: ${state.user.email}');
          // Navigation to home page is now handled by the builder directly
          // We can still show a snackbar here if desired, but not navigation
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Logged in as ${state.user.email}')),
          );
        } else if (state is AuthFailure) {
          print('Auth Failed: ${state.message}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        } else if (state is AuthUnauthenticated) {
          print('Auth Unauthenticated: User logged out or session expired.');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('You have been logged out.')),
          );
        }
      },
      builder: (context, state) {
        if (state is AuthInitial || state is AuthLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (state is AuthAuthenticated) {
          // <--- CHANGE THIS: Return the actual DashboardPage
          return const DashboardPage();
        } else if (state is AuthUnauthenticated || state is AuthFailure) {
          // If unauthenticated or authentication failed, show the LoginPage
          return const LoginPage();
        }
        // Fallback for any unexpected state
        return const Scaffold(
          body: Center(child: Text('Unknown Authentication State')),
        );
      },
    );
  }
}