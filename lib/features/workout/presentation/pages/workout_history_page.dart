// lib/features/workout/presentation/pages/workout_history_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:fwitgi_app/core/di/dependency_injection.dart';
import 'package:fwitgi_app/core/theme/app_theme.dart';
import 'package:fwitgi_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:fwitgi_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:fwitgi_app/features/workout/domain/entities/workout.dart';
import 'package:fwitgi_app/features/workout/presentation/bloc/workout_bloc.dart';
import 'package:fwitgi_app/features/workout/presentation/bloc/workout_event.dart';
import 'package:fwitgi_app/features/workout/presentation/bloc/workout_state.dart';

// New imports for ExerciseDefinition and its Repository
import 'package:fwitgi_app/features/workout/domain/repositories/exercise_definition_repository.dart'; // ADD THIS
import 'package:fwitgi_app/features/workout/domain/entities/exercise_definition.dart'; // ADD THIS

class WorkoutHistoryPage extends StatefulWidget {
  const WorkoutHistoryPage({super.key});

  @override
  State<WorkoutHistoryPage> createState() => _WorkoutHistoryPageState();
}

class _WorkoutHistoryPageState extends State<WorkoutHistoryPage> {
  late WorkoutBloc _workoutBloc;
  String? _currentUserId;
  late ExerciseDefinitionRepository _exerciseDefinitionRepository; // ADD THIS

  // Store fetched exercise definitions in a map for quick lookup
  Map<String, ExerciseDefinition> _exerciseDefinitionsMap = {}; // ADD THIS

  @override
  void initState() {
    super.initState();
    _workoutBloc = getlt<WorkoutBloc>();
    _exerciseDefinitionRepository = getlt<ExerciseDefinitionRepository>(); // INITIALIZE THIS

    WidgetsBinding.instance.addPostFrameCallback((_) async { // Make async
      // Fetch all exercise definitions once when the page loads
      try {
        final List<ExerciseDefinition> definitions = await _exerciseDefinitionRepository.getExerciseDefinitions();
        setState(() {
          _exerciseDefinitionsMap = { for (var def in definitions) def.id: def };
        });
      } catch (e) {
        print('Error fetching exercise definitions for history: $e');
        // Optionally show an error message
      }

      final authState = context.read<AuthBloc>().state;
      if (authState is AuthAuthenticated) {
        _currentUserId = authState.user.id;
        _workoutBloc.add(LoadWorkouts(_currentUserId!));
      } else {
        _currentUserId = null;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please sign in to view your workout history.')),
          );
        });
      }
    });
  }

  // Helper to get exercise name from its definition ID (if needed for detailed view)
  String _getExerciseName(String exerciseDefinitionId) {
    return _exerciseDefinitionsMap[exerciseDefinitionId]?.name ?? 'Unknown Exercise';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout History'),
      ),
      body: _currentUserId == null
          ? const Center(child: Text('Please log in to view your workout history.'))
          : BlocConsumer<WorkoutBloc, WorkoutState>(
              bloc: _workoutBloc,
              listener: (context, state) {
                if (state is WorkoutError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error loading workouts: ${state.message}')),
                  );
                }
              },
              builder: (context, state) {
                if (state is WorkoutLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is WorkoutLoaded) {
                  if (state.workouts.isEmpty) {
                    return const Center(child: Text('No past workouts found. Start logging!'));
                  }
                  state.workouts.sort((a, b) => b.startTime.compareTo(a.startTime));

                  return ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: state.workouts.length,
                    itemBuilder: (context, index) {
                      final workout = state.workouts[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Tapped on "${workout.name}"')),
                            );
                            // Example: To view detailed exercises within the workout history
                            // You would pass the workout and use _exerciseDefinitionsMap to display names
                            /*
                            Navigator.push(context, MaterialPageRoute(builder: (context) => WorkoutDetailView(
                                workout: workout,
                                exerciseDefinitionsMap: _exerciseDefinitionsMap, // Pass the map
                            )));
                            */
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  workout.name,
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.primaryColor,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${DateFormat('MMM d, yyyy - HH:mm').format(workout.startTime)}',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                                ),
                                const Divider(height: 16, thickness: 0.5),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    _buildStatItem(context, 'Type', workout.type.name.toUpperCase()),
                                    _buildStatItem(context, 'Duration', '${workout.duration.inMinutes} min'),
                                    _buildStatItem(context, 'Exercises', '${workout.exercises.length}'),
                                    _buildStatItem(context, 'Total Weight', '${workout.totalWeight.toStringAsFixed(1)} kg'),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}