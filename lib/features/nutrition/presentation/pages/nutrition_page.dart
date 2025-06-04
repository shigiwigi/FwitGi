// lib/features/nutrition/presentation/pages/nutrition_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:fwitgi_app/core/di/dependency_injection.dart'; // For GetIt
import 'package:fwitgi_app/features/auth/presentation/bloc/auth_bloc.dart'; // For AuthBloc
import 'package:fwitgi_app/features/auth/presentation/bloc/auth_state.dart'; // For AuthState
import 'package:fwitgi_app/features/nutrition/presentation/bloc/nutrition_bloc.dart'; // For NutritionBloc
import 'package:fwitgi_app/core/theme/app_theme.dart'; // For theme colors

class NutritionPage extends StatefulWidget {
  const NutritionPage({super.key});

  @override
  State<NutritionPage> createState() => _NutritionPageState();
}

class _NutritionPageState extends State<NutritionPage> {
  late NutritionBloc _nutritionBloc;
  String? _currentUserId;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _nutritionBloc = getlt<NutritionBloc>();

    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      _currentUserId = authState.user.id;
      _loadNutritionData();
    } else {
      _currentUserId = null;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please sign in to track your nutrition.')),
        );
      });
    }
  }

  void _loadNutritionData() {
    if (_currentUserId != null) {
      _nutritionBloc.add(LoadDailyNutritionEvent(userId: _currentUserId!, date: _selectedDate));
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _loadNutritionData();
    }
  }

  void _showLogMealDialog() {
    final _formKey = GlobalKey<FormState>();
    final TextEditingController _foodController = TextEditingController();
    final TextEditingController _caloriesController = TextEditingController();
    final TextEditingController _proteinController = TextEditingController();
    final TextEditingController _carbsController = TextEditingController();
    final TextEditingController _fatController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log Meal'),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _foodController,
                  decoration: const InputDecoration(labelText: 'Food Item'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a food item';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _caloriesController,
                  decoration: const InputDecoration(labelText: 'Calories (kcal)'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || int.tryParse(value) == null) {
                      return 'Enter a valid number';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _proteinController,
                  decoration: const InputDecoration(labelText: 'Protein (g)'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || double.tryParse(value) == null) {
                      return 'Enter a valid number';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _carbsController,
                  decoration: const InputDecoration(labelText: 'Carbs (g)'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || double.tryParse(value) == null) {
                      return 'Enter a valid number';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _fatController,
                  decoration: const InputDecoration(labelText: 'Fat (g)'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || double.tryParse(value) == null) {
                      return 'Enter a valid number';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate() && _currentUserId != null) {
                final mealData = {
                  'foodItem': _foodController.text.trim(),
                  'calories': int.parse(_caloriesController.text),
                  'protein': double.parse(_proteinController.text),
                  'carbs': double.parse(_carbsController.text),
                  'fat': double.parse(_fatController.text),
                  'mealType': 'Snack', // Example: Could be selected from a dropdown
                };
                _nutritionBloc.add(LogMealEvent(userId: _currentUserId!, meal: mealData));
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Meal logged successfully!')),
                );
              }
            },
            child: const Text('Log'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nutrition Tracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () => _selectDate(context),
          ),
        ],
      ),
      body: _currentUserId == null
          ? const Center(child: Text('Please sign in to track your nutrition.'))
          : BlocConsumer<NutritionBloc, NutritionState>(
              bloc: _nutritionBloc,
              listener: (context, state) {
                if (state is NutritionError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: ${state.message}')),
                  );
                }
              },
              builder: (context, state) {
                if (state is NutritionLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is NutritionLoaded) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDailySummary(state.dailySummary),
                        const SizedBox(height: 24),
                        Text(
                          'Meals for ${DateFormat('EEEE, MMM d').format(_selectedDate)}',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 16),
                        state.meals.isEmpty
                            ? const Center(child: Text('No meals logged for this day.'))
                            : ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: state.meals.length,
                                itemBuilder: (context, index) {
                                  final meal = state.meals[index];
                                  return Card(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    child: ListTile(
                                      title: Text(meal['foodItem'] ?? 'N/A'),
                                      subtitle: Text(
                                          '${meal['calories'] ?? 0} kcal | P: ${meal['protein'] ?? 0}g | C: ${meal['carbs'] ?? 0}g | F: ${meal['fat'] ?? 0}g'),
                                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                                      onTap: () {
                                        // TODO: Implement meal detail view or edit
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Tapped on ${meal['foodItem']}')),
                                        );
                                      },
                                    ),
                                  );
                                },
                              ),
                      ],
                    ),
                  );
                }
                return const Center(child: Text('Start logging your nutrition!'));
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showLogMealDialog,
        label: const Text('Log Meal'),
        icon: const Icon(Icons.add),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildDailySummary(Map<String, double> dailySummary) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Daily Summary (${DateFormat('MMM d, yyyy').format(_selectedDate)})',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          _buildMacroRow(
            context,
            'Calories',
            '${dailySummary['calories']?.toStringAsFixed(0) ?? 0} kcal',
            Colors.orangeAccent,
            Icons.local_fire_department,
          ),
          const SizedBox(height: 12),
          _buildMacroRow(
            context,
            'Protein',
            '${dailySummary['protein']?.toStringAsFixed(1) ?? 0}g',
            Colors.redAccent,
            Icons.restaurant_menu,
          ),
          const SizedBox(height: 12),
          _buildMacroRow(
            context,
            'Carbs',
            '${dailySummary['carbs']?.toStringAsFixed(1) ?? 0}g',
            Colors.lightGreenAccent,
            Icons.rice_bowl,
          ),
          const SizedBox(height: 12),
          _buildMacroRow(
            context,
            'Fat',
            '${dailySummary['fat']?.toStringAsFixed(1) ?? 0}g',
            Colors.amberAccent,
            Icons.fastfood,
          ),
        ],
      ),
    );
  }

  Widget _buildMacroRow(BuildContext context, String label, String value, Color iconColor, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}