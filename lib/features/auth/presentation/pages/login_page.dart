// lib/features/auth/presentation/pages/login_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// Make sure this import is correct and points to your AuthBloc
import 'package:fwitgi_app/features/auth/presentation/bloc/auth_bloc.dart';
// You also need to import auth_state.dart here to recognize AuthAuthenticated and AuthFailure
import 'package:fwitgi_app/features/auth/presentation/bloc/auth_state.dart'; // <--- ADD THIS IMPORT

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLogin = true; // To toggle between login and signup

  // If you plan to use a name for signup, you'll need a controller for it:
  final TextEditingController _nameController = TextEditingController(); // <--- Add this if you need a name input

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose(); // <--- Dispose name controller if added
    super.dispose();
  }

  void _handleSubmit() {
    print('DEBUG: _handleSubmit() called!');
    if (_formKey.currentState!.validate()) {
      print('DEBUG: Form validation passed!');
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
            name: _nameController.text.trim(), // <--- Use the name controller's text
          ),
        );
      }
    } else {
      print('DEBUG: Form validation failed!');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isLogin ? 'Sign In' : 'Sign Up')),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          // Listen for authentication success or failure
          if (state is AuthAuthenticated) { // <--- CHANGE from AuthSuccess to AuthAuthenticated
            print('Auth Success! User: ${state.user.email}'); // Access user details
            // Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const HomePage()));
            // For now, let's just show a success snackbar
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Logged in as ${state.user.email}')),
            );
          } else if (state is AuthFailure) { // <--- This is now consistent with AuthBloc
            print('Auth Failed: ${state.message}');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                    validator: (value) {
                      if (value == null || value.isEmpty || !value.contains('@')) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(labelText: 'Password'),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty || value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  // Add a name field for SignUp if _isLogin is false
                  if (!_isLogin) ...[ // Only show name field in Sign Up mode
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nameController, // <--- Use the name controller
                      decoration: const InputDecoration(labelText: 'Name'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),
                  ],
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: state is AuthLoading ? null : _handleSubmit,
                    child: state is AuthLoading
                        ? const CircularProgressIndicator()
                        : Text(_isLogin ? 'Sign In' : 'Sign Up'),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isLogin = !_isLogin;
                        // Clear fields when toggling to avoid validation issues
                        _emailController.clear();
                        _passwordController.clear();
                        _nameController.clear();
                      });
                    },
                    child: Text(_isLogin
                        ? "Don't have an account? Sign Up"
                        : "Already have an account? Sign In"),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}