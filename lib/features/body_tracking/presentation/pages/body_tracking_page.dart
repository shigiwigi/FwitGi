// lib/features/body_tracking/presentation/pages/body_tracking_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'package:fwitgi_app/core/di/dependency_injection.dart'; // For GetIt
import 'package:fwitgi_app/features/auth/presentation/bloc/auth_bloc.dart'; // For AuthBloc
import 'package:fwitgi_app/features/auth/presentation/bloc/auth_state.dart'; // For AuthState
import 'package:fwitgi_app/features/body_tracking/presentation/bloc/body_tracking_bloc.dart'; // For BodyTrackingBloc
import 'package:fwitgi_app/core/theme/app_theme.dart'; // For theme colors

class BodyTrackingPage extends StatefulWidget {
  const BodyTrackingPage({super.key});

  @override
  State<BodyTrackingPage> createState() => _BodyTrackingPageState();
}

class _BodyTrackingPageState extends State<BodyTrackingPage> {
  late BodyTrackingBloc _bodyTrackingBloc;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _bodyTrackingBloc = getlt<BodyTrackingBloc>();

    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      _currentUserId = authState.user.id;
      _loadBodyStats();
    } else {
      _currentUserId = null;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please sign in to track your body stats.')),
        );
      });
    }
  }

  void _loadBodyStats() {
    if (_currentUserId != null) {
      _bodyTrackingBloc.add(LoadBodyStatsEvent(_currentUserId!));
    }
  }

  void _showLogBodyStatsDialog() {
    final _formKey = GlobalKey<FormState>();
    final TextEditingController _weightController = TextEditingController();
    final TextEditingController _neckController = TextEditingController();
    final TextEditingController _chestController = TextEditingController();
    final TextEditingController _waistController = TextEditingController();
    final TextEditingController _hipsController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log Body Stats'),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _weightController,
                  decoration: const InputDecoration(labelText: 'Weight (kg)'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || double.tryParse(value) == null) {
                      return 'Enter a valid number';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _neckController,
                  decoration: const InputDecoration(labelText: 'Neck (cm) (Optional)'),
                  keyboardType: TextInputType.number,
                ),
                TextFormField(
                  controller: _chestController,
                  decoration: const InputDecoration(labelText: 'Chest (cm) (Optional)'),
                  keyboardType: TextInputType.number,
                ),
                TextFormField(
                  controller: _waistController,
                  decoration: const InputDecoration(labelText: 'Waist (cm) (Optional)'),
                  keyboardType: TextInputType.number,
                ),
                TextFormField(
                  controller: _hipsController,
                  decoration: const InputDecoration(labelText: 'Hips (cm) (Optional)'),
                  keyboardType: TextInputType.number,
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
                final statsData = {
                  'weight': double.parse(_weightController.text),
                  'neck': double.tryParse(_neckController.text) ?? 0.0,
                  'chest': double.tryParse(_chestController.text) ?? 0.0,
                  'waist': double.tryParse(_waistController.text) ?? 0.0,
                  'hips': double.tryParse(_hipsController.text) ?? 0.0,
                };
                _bodyTrackingBloc.add(LogBodyStatsEvent(userId: _currentUserId!, stats: statsData));
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Body stats logged successfully!')),
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
        title: const Text('Body Tracking'),
      ),
      body: _currentUserId == null
          ? const Center(child: Text('Please sign in to track your body stats.'))
          : BlocConsumer<BodyTrackingBloc, BodyTrackingState>(
              bloc: _bodyTrackingBloc,
              listener: (context, state) {
                if (state is BodyTrackingError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: ${state.message}')),
                  );
                }
              },
              builder: (context, state) {
                if (state is BodyTrackingLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is BodyTrackingLoaded) {
                  if (state.statsHistory.isEmpty) {
                    return const Center(child: Text('No body stats logged yet.'));
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: state.statsHistory.length,
                    itemBuilder: (context, index) {
                      final stat = state.statsHistory[index];
                      final timestamp = (stat['timestamp'] as Timestamp).toDate();
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          title: Text('Weight: ${stat['weight']?.toStringAsFixed(1) ?? 'N/A'} kg'),
                          subtitle: Text(
                            'Logged on: ${DateFormat('MMM d, yyyy HH:mm').format(timestamp)}\n'
                            'Neck: ${stat['neck']?.toStringAsFixed(1) ?? 0} cm | '
                            'Chest: ${stat['chest']?.toStringAsFixed(1) ?? 0} cm | '
                            'Waist: ${stat['waist']?.toStringAsFixed(1) ?? 0} cm | '
                            'Hips: ${stat['hips']?.toStringAsFixed(1) ?? 0} cm',
                          ),
                          isThreeLine: true,
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () {
                            // TODO: Implement stat detail view or edit
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Tapped on stats from ${DateFormat('MMM d, yyyy').format(timestamp)}')),
                            );
                          },
                        ),
                      );
                    },
                  );
                }
                return const Center(child: Text('Start tracking your body stats!'));
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showLogBodyStatsDialog,
        label: const Text('Log Stats'),
        icon: const Icon(Icons.add),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}