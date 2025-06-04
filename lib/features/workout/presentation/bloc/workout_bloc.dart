// lib/features/workout/presentation/bloc/workout_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';

// Import events and states from their dedicated files
import './workout_event.dart';
import './workout_state.dart';

import '../../domain/entities/workout.dart';
import '../../domain/repositories/workout_repository.dart';

// BLoC for managing workout-related states and events.
class WorkoutBloc extends Bloc<WorkoutEvent, WorkoutState> {
  final WorkoutRepository repository;

  // Constructs a [WorkoutBloc] with the given [repository].
  WorkoutBloc(this.repository) : super(WorkoutInitial()) {
    on<LoadWorkouts>(_onLoadWorkouts);
    on<SaveWorkout>(_onSaveWorkout);
    on<LoadWorkoutTemplates>(_onLoadWorkoutTemplates);
  }

  // Handles the [LoadWorkouts] event.
  Future<void> _onLoadWorkouts(
    LoadWorkouts event,
    Emitter<WorkoutState> emit,
  ) async {
    emit(WorkoutLoading());
    try {
      final workouts = await repository.getWorkouts(event.userId);

      final Map<String, double> weeklyWorkoutSummary = {};
      final now = DateTime.now();
      final DateFormat formatter = DateFormat('yyyy-MM-dd');

      for (int i = 0; i < 7; i++) {
        final date = DateTime(now.year, now.month, now.day).subtract(Duration(days: i));
        final String formattedDate = formatter.format(date);
        weeklyWorkoutSummary[formattedDate] = 0.0;
      }

      for (var workout in workouts) {
        final String workoutDate = formatter.format(workout.startTime);
        if (weeklyWorkoutSummary.containsKey(workoutDate)) {
          weeklyWorkoutSummary[workoutDate] = (weeklyWorkoutSummary[workoutDate] ?? 0.0) + workout.totalWeight;
        }
      }

      workouts.sort((a, b) => b.startTime.compareTo(a.startTime));

      List<Workout> currentTemplates = [];
      if (state is WorkoutLoaded) {
        currentTemplates = (state as WorkoutLoaded).workoutTemplates;
      }

      emit(WorkoutLoaded(workouts, workoutSummary: weeklyWorkoutSummary, workoutTemplates: currentTemplates));
    } catch (e) {
      emit(WorkoutError(e.toString()));
    }
  }

  // Handles the [SaveWorkout] event.
  Future<void> _onSaveWorkout(
    SaveWorkout event,
    Emitter<WorkoutState> emit,
  ) async {
    try {
      await repository.saveWorkout(event.workout);
      add(LoadWorkouts(event.workout.userId)); // Reload workouts after saving
      // Optionally, reload templates if needed
      // add(LoadWorkoutTemplates(event.workout.userId));
    } catch (e) {
      emit(WorkoutError(e.toString()));
    }
  }

  // Implement _onLoadWorkoutTemplates
  Future<void> _onLoadWorkoutTemplates(
    LoadWorkoutTemplates event,
    Emitter<WorkoutState> emit,
  ) async {
    try {
      final templates = await repository.getWorkoutTemplates();
      List<Workout> currentWorkouts = [];
      Map<String, double> currentSummary = {};
      if (state is WorkoutLoaded) {
        currentWorkouts = (state as WorkoutLoaded).workouts;
        currentSummary = (state as WorkoutLoaded).workoutSummary;
      }
      emit(WorkoutLoaded(currentWorkouts, workoutSummary: currentSummary, workoutTemplates: templates));
    } catch (e) {
      emit(WorkoutError('Failed to load workout templates: ${e.toString()}'));
    }
  }
}