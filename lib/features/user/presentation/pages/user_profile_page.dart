// lib/features/user/presentation/pages/user_profile_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fwitgi_app/core/di/dependency_injection.dart'; // For GetIt
import 'package:fwitgi_app/core/models/user_model.dart'; // For UserModel, UserPreferences, UserStats
import 'package:fwitgi_app/core/theme/app_theme.dart'; // For theme colors
import 'package:fwitgi_app/core/theme/theme_cubit.dart'; // Import ThemeCubit
import 'package:fwitgi_app/features/auth/presentation/bloc/auth_bloc.dart'; // For AuthBloc
import 'package:fwitgi_app/features/auth/presentation/bloc/auth_state.dart'; // For AuthState
import 'package:fwitgi_app/features/user/domain/repositories/user_repository.dart'; // For UserRepository
import 'package:fwitgi_app/features/auth/data/repositories/user_repository_impl.dart'; // For the implementation

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  UserModel? _currentUser;
  late UserRepository _userRepository;
  late ThemeCubit _themeCubit; // Instance of ThemeCubit

  // Controllers for editable fields
  late TextEditingController _nameController;
  late TextEditingController _dailyCalorieGoalController;
  late TextEditingController _dailyProteinGoalController;

  bool _darkModeEnabled = false;
  String _selectedUnits = 'metric'; // Default to metric

  @override
  void initState() {
    super.initState();
    _userRepository = getlt<UserRepository>();
    _themeCubit = getlt<ThemeCubit>(); // Get ThemeCubit instance

    // Initialize with current user data if available
    _initializeUserData();

    // Listen to AuthBloc changes to keep _currentUser updated
    context.read<AuthBloc>().stream.listen((state) {
      if (state is AuthAuthenticated) {
        setState(() {
          _currentUser = state.user;
          _updateControllersAndStateFromUser();
        });
      } else if (state is AuthUnauthenticated) {
        setState(() {
          _currentUser = null;
        });
      }
    });

    // Listen to ThemeCubit changes to keep _darkModeEnabled in sync
    _themeCubit.stream.listen((themeMode) {
      setState(() {
        _darkModeEnabled = (themeMode == ThemeMode.dark);
      });
    });
  }

  void _initializeUserData() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      _currentUser = authState.user;
      _nameController = TextEditingController(text: _currentUser?.name ?? '');
      _darkModeEnabled = _currentUser?.preferences.darkMode ?? false;
      _selectedUnits = _currentUser?.preferences.units ?? 'metric';
      _dailyCalorieGoalController = TextEditingController(text: _currentUser?.preferences.dailyCalorieGoal.toString() ?? '');
      _dailyProteinGoalController = TextEditingController(text: _currentUser?.preferences.dailyProteinGoal.toString() ?? '');
    } else {
      _nameController = TextEditingController();
      _dailyCalorieGoalController = TextEditingController();
      _dailyProteinGoalController = TextEditingController();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please sign in to view your profile.')),
        );
      });
    }
  }

  void _updateControllersAndStateFromUser() {
    _nameController.text = _currentUser?.name ?? '';
    _darkModeEnabled = _currentUser?.preferences.darkMode ?? false;
    _selectedUnits = _currentUser?.preferences.units ?? 'metric';
    _dailyCalorieGoalController.text = _currentUser?.preferences.dailyCalorieGoal.toString() ?? '';
    _dailyProteinGoalController.text = _currentUser?.preferences.dailyProteinGoal.toString() ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dailyCalorieGoalController.dispose();
    _dailyProteinGoalController.dispose();
    super.dispose();
  }

  void _updateUserProfile() async {
    if (_currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot update profile: No user logged in.')),
      );
      return;
    }

    // Create updated preferences and stats objects
    final updatedPreferences = UserPreferences(
      darkMode: _darkModeEnabled, // Use the state variable
      units: _selectedUnits,
      dailyCalorieGoal: int.tryParse(_dailyCalorieGoalController.text) ?? _currentUser!.preferences.dailyCalorieGoal,
      dailyProteinGoal: int.tryParse(_dailyProteinGoalController.text) ?? _currentUser!.preferences.dailyProteinGoal,
      workoutReminders: _currentUser!.preferences.workoutReminders, // Keep existing reminders
    );

    // Create updated UserModel
    final updatedUser = UserModel(
      id: _currentUser!.id,
      email: _currentUser!.email,
      name: _nameController.text.trim(),
      photoUrl: _currentUser!.photoUrl,
      createdAt: _currentUser!.createdAt,
      preferences: updatedPreferences,
      stats: _currentUser!.stats, // Keep existing stats
    );

    try {
      await _userRepository.updateUser(updatedUser);
      // Immediately update AuthBloc with the new user model to reflect changes across the app
      context.read<AuthBloc>().add(AuthCheckRequested()); // Re-fetch or update current user in AuthBloc

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update profile: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: const Center(child: Text('Please log in to view your profile.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _updateUserProfile,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Personal Information'),
            Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Name'),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      initialValue: _currentUser!.email,
                      readOnly: true, // Email usually isn't edited directly here
                      decoration: const InputDecoration(labelText: 'Email', enabled: false),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildSectionHeader('Preferences'),
            Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text('Dark Mode'),
                      value: _darkModeEnabled,
                      onChanged: (bool value) {
                        setState(() {
                          _darkModeEnabled = value;
                        });
                        _themeCubit.setTheme(value); // Set theme via ThemeCubit
                      },
                    ),
                    ListTile(
                      title: const Text('Units'),
                      trailing: DropdownButton<String>(
                        value: _selectedUnits,
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedUnits = newValue!;
                          });
                        },
                        items: <String>['metric', 'imperial']
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value.capitalize()),
                          );
                        }).toList(),
                      ),
                    ),
                    TextFormField(
                      controller: _dailyCalorieGoalController,
                      decoration: const InputDecoration(labelText: 'Daily Calorie Goal (kcal)'),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _dailyProteinGoalController,
                      decoration: const InputDecoration(labelText: 'Daily Protein Goal (g)'),
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildSectionHeader('Statistics'),
            Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildStatRow('Total Workouts', _currentUser!.stats.totalWorkouts.toString()),
                    _buildStatRow('Current Streak', _currentUser!.stats.currentStreak.toString()),
                    _buildStatRow('Longest Streak', _currentUser!.stats.longestStreak.toString()),
                    _buildStatRow('Total Weight Lifted', '${_currentUser!.stats.totalWeightLifted.toStringAsFixed(1)} kg'),
                    _buildStatRow('Total Calories Logged', _currentUser!.stats.totalCaloriesLogged.toString()),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  context.read<AuthBloc>().add(SignOutRequested());
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Logged out successfully.')),
                  );
                  // AuthWrapper will handle navigation back to LoginPage
                },
                icon: const Icon(Icons.logout, color: Colors.white),
                label: const Text('Logout', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.errorColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyLarge),
          Text(value, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

// Extension to capitalize first letter of a string
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}