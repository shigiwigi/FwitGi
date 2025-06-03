// lib/features/auth/presentation/pages/login_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fwitgi_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:fwitgi_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:fwitgi_app/core/theme/app_theme.dart'; // Import your AppTheme for colors

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  bool _isLogin = true;
  bool _passwordVisible = false; // State for password visibility

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      if (_isLogin) {
        context.read<AuthBloc>().add(
          SignInRequested(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          ),
        );
      } else {
        context.read<AuthBloc>().add(
          SignUpRequested(
            email: _emailController.text.trim(),
            password: _passwordController.text,
            name: _nameController.text.trim(),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar is optional, remove if you want full screen logo
      // appBar: AppBar(title: Text(_isLogin ? 'Sign In' : 'Sign Up')),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Logged in as ${state.user.email}')),
            );
          } else if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          final bool isLoading = state is AuthLoading; // Check if loading state

          return SafeArea( // Added SafeArea for better layout on all devices
            child: Center(
              child: SingleChildScrollView( // Allows scrolling if content overflows
                padding: const EdgeInsets.all(24.0), // Increased padding
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // --- START: Logo and App Title ---
                      Image.asset(
                        'assets/images/logo.png', // Make sure this path is correct and logo exists
                        height: 120, // Adjusted height
                        width: 120,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        _isLogin ? 'Welcome Back!' : 'Join FwitGi',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith( // Changed to headlineSmall
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onBackground,
                            ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _isLogin
                            ? 'Sign in to continue to your account.'
                            : 'Create an account to start your fitness journey!',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      ),
                      const SizedBox(height: 40), // Increased spacing
                      // --- END: Logo and App Title ---

                      TextFormField(
                        controller: _emailController,
                        enabled: !isLoading, // Disable during loading
                        decoration: InputDecoration(
                          labelText: 'Email',
                          hintText: 'Enter your email',
                          prefixIcon: const Icon(Icons.email_outlined),
                          border: OutlineInputBorder( // Professional border
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true, // Adds a fill color
                          fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.1),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty || !value.contains('@')) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20), // Consistent spacing
                      TextFormField(
                        controller: _passwordController,
                        enabled: !isLoading, // Disable during loading
                        decoration: InputDecoration(
                          labelText: 'Password',
                          hintText: 'Enter your password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.1),
                          suffixIcon: IconButton( // Password visibility toggle
                            icon: Icon(
                              _passwordVisible ? Icons.visibility : Icons.visibility_off,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                            onPressed: () {
                              setState(() {
                                _passwordVisible = !_passwordVisible;
                              });
                            },
                          ),
                        ),
                        obscureText: !_passwordVisible, // Apply visibility toggle
                        validator: (value) {
                          if (value == null || value.isEmpty || value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),
                      if (!_isLogin) ...[
                        const SizedBox(height: 20), // Consistent spacing
                        TextFormField(
                          controller: _nameController,
                          enabled: !isLoading, // Disable during loading
                          decoration: InputDecoration(
                            labelText: 'Name',
                            hintText: 'Enter your full name',
                            prefixIcon: const Icon(Icons.person_outline),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.1),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your name';
                            }
                            return null;
                          },
                        ),
                      ],
                      const SizedBox(height: 32), // Spacing before button
                      ElevatedButton(
                        onPressed: isLoading ? null : _handleSubmit, // Disable button while loading
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 56), // Full width button
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          backgroundColor: AppTheme.primaryColor, // Use primary color
                          foregroundColor: Colors.white, // Text color
                          elevation: 3, // Subtle elevation
                        ),
                        child: isLoading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Text(
                                _isLogin ? 'Sign In' : 'Sign Up',
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                      ),
                      const SizedBox(height: 20), // Spacing after button
                      TextButton(
                        onPressed: isLoading ? null : () { // Disable toggle button while loading
                          setState(() {
                            _isLogin = !_isLogin;
                            _emailController.clear();
                            _passwordController.clear();
                            _nameController.clear();
                            _passwordVisible = false; // Reset visibility
                          });
                        },
                        child: Text(
                          _isLogin
                              ? "Don't have an account? Sign Up"
                              : "Already have an account? Sign In",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}