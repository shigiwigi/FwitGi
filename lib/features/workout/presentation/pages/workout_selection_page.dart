// lib/features/workout/presentation/pages/workout_selection_page.dart

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fwitgi_app/core/di/dependency_injection.dart';
import 'package:fwitgi_app/features/workout/presentation/bloc/workout_bloc.dart';
import 'package:fwitgi_app/features/workout/domain/entities/workout.dart';
import 'package:fwitgi_app/features/workout/presentation/pages/workout_session_page.dart';
import 'package:fwitgi_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:fwitgi_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:fwitgi_app/features/workout/presentation/bloc/workout_event.dart'; // <-- ADD THIS IMPORT
import 'package:fwitgi_app/features/workout/presentation/bloc/workout_state.dart'; // <-- ADD THIS IMPORT

class WorkoutSelectionPage extends StatefulWidget {
  const WorkoutSelectionPage({Key? key}) : super(key: key);

  @override
  State<WorkoutSelectionPage> createState() => _WorkoutSelectionPageState();
}

class _WorkoutSelectionPageState extends State<WorkoutSelectionPage> {
  late WorkoutBloc _workoutBloc;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _workoutBloc = getlt<WorkoutBloc>();

    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      _currentUserId = authState.user.id;
      _workoutBloc.add(LoadWorkoutTemplates(_currentUserId!)); // LoadWorkoutTemplates should now be recognized
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not authenticated. Cannot load templates.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Start New Workout'),
      ),
      body: BlocBuilder<WorkoutBloc, WorkoutState>( // WorkoutState should now be recognized
        bloc: _workoutBloc,
        builder: (context, state) {
          if (state is WorkoutLoading) { // WorkoutLoading should now be recognized
            return const Center(child: CircularProgressIndicator());
          } else if (state is WorkoutError) { // WorkoutError should now be recognized
            return Center(child: Text('Error: ${state.message}'));
          } else if (state is WorkoutLoaded) { // WorkoutLoaded should now be recognized
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Choose a Template',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                Expanded(
                  child: _buildWorkoutList(context, state.workoutTemplates, isTemplate: true),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    onPressed: _currentUserId == null ? null : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => WorkoutSessionPage(userId: _currentUserId)),
                      );
                    },
                    child: const Text('Start Empty Workout'),
                  ),
                ),
              ],
            );
          }
          return const Center(child: Text('No workout templates available.'));
        },
      ),
    );
  }

  Widget _buildWorkoutList(BuildContext context, List<Workout> workouts, {required bool isTemplate}) {
    if (workouts.isEmpty) {
      return Center(
        child: Text(
          isTemplate ? 'No templates found.' : 'No workouts logged yet.',
          style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
      );
    }
    return ListView.builder(
      itemCount: workouts.length,
      itemBuilder: (context, index) {
        final workout = workouts[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            title: Text(workout.name),
            subtitle: Text(
              '${workout.exercises.length} exercises, ${workout.totalSets} sets, ${workout.totalWeight.toStringAsFixed(1)} kg',
            ),
            trailing: isTemplate
                ? IconButton(
                    icon: const Icon(Icons.play_arrow),
                    onPressed: _currentUserId == null ? null : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => WorkoutSessionPage(
                            workoutTemplateId: workout.id,
                            userId: _currentUserId!,
                          ),
                        ),
                      );
                    },
                  )
                : null,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Tapped on ${workout.name}')),
              );
            },
          ),
        );
      },
    );
  }
}