// lib/features/workout/presentation/bloc/workout_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/workout.dart';
import '../../domain/repositories/workout_repository.dart';

/// Abstract base class for all Workout Events.
abstract class WorkoutEvent extends Equatable {
  const WorkoutEvent();

  @override
  List<Object> get props => [];
}

/// Event to request loading of workouts for a specific user.
class LoadWorkouts extends WorkoutEvent {
  final String userId;
  const LoadWorkouts(this.userId);

  @override
  List<Object> get props => [userId];
}

/// Event to request saving a workout.
class SaveWorkout extends WorkoutEvent {
  final Workout workout;
  const SaveWorkout(this.workout);

  @override
  List<Object> get props => [workout];
}

// Define the LoadWorkoutTemplates event
class LoadWorkoutTemplates extends WorkoutEvent {
  final String userId;
  const LoadWorkoutTemplates(this.userId);

  @override
  List<Object> get props => [userId];
}


/// Abstract base class for all Workout States.
abstract class WorkoutState extends Equatable {
  const WorkoutState();

  @override
  List<Object> get props => [];
}

/// Initial state of the Workout BLoC.
class WorkoutInitial extends WorkoutState {}

/// State indicating that workouts are currently being loaded or saved.
class WorkoutLoading extends WorkoutState {}

/// State indicating that workouts have been successfully loaded.
class WorkoutLoaded extends WorkoutState {
  final List<Workout> workouts;
  final Map<String, double> workoutSummary;
  final List<Workout> workoutTemplates; // ADDED FIELD for templates
  const WorkoutLoaded(this.workouts, {this.workoutSummary = const {}, this.workoutTemplates = const []}); // Updated constructor

  @override
  List<Object> get props => [workouts, workoutSummary, workoutTemplates]; // Updated props
}

/// State indicating an error occurred during a workout operation.
class WorkoutError extends WorkoutState {
  final String message;
  const WorkoutError(this.message);

  @override
  List<Object> get props => [message];
}

/// BLoC for managing workout-related states and events.
class WorkoutBloc extends Bloc<WorkoutEvent, WorkoutState> {
  final WorkoutRepository repository;

  /// Constructs a [WorkoutBloc] with the given [repository].
  WorkoutBloc(this.repository) : super(WorkoutInitial()) {
    on<LoadWorkouts>(_onLoadWorkouts);
    on<SaveWorkout>(_onSaveWorkout);
    on<LoadWorkoutTemplates>(_onLoadWorkoutTemplates); // Added handler for LoadWorkoutTemplates
  }

  /// Handles the [LoadWorkouts] event.
  Future<void> _onLoadWorkouts(
    LoadWorkouts event,
    Emitter<WorkoutState> emit,
  ) async {
    emit(WorkoutLoading());
    try {
      final workouts = await repository.getWorkouts(event.userId);

      // Calculate weekly workout summary for the chart
      final Map<String, double> weeklyWorkoutSummary = {};
      final now = DateTime.now();
      final DateFormat formatter = DateFormat('yyyy-MM-dd');

      for (int i = 0; i < 7; i++) { // Iterate for the last 7 days
        final date = DateTime(now.year, now.month, now.day).subtract(Duration(days: i));
        final String formattedDate = formatter.format(date);
        weeklyWorkoutSummary[formattedDate] = 0.0; // Initialize with 0
      }

      for (var workout in workouts) {
        final String workoutDate = formatter.format(workout.startTime);
        if (weeklyWorkoutSummary.containsKey(workoutDate)) {
          weeklyWorkoutSummary[workoutDate] = (weeklyWorkoutSummary[workoutDate] ?? 0.0) + workout.totalWeight;
        }
      }

      // Sort workouts by startTime in descending order (most recent first)
      workouts.sort((a, b) => b.startTime.compareTo(a.startTime));

      // Retrieve current workoutTemplates if they exist in the current state to preserve them
      List<Workout> currentTemplates = [];
      if (state is WorkoutLoaded) {
        currentTemplates = (state as WorkoutLoaded).workoutTemplates;
      }

      emit(WorkoutLoaded(workouts, workoutSummary: weeklyWorkoutSummary, workoutTemplates: currentTemplates));
    } catch (e) {
      emit(WorkoutError(e.toString()));
    }
  }

  /// Handles the [SaveWorkout] event.
  Future<void> _onSaveWorkout(
    SaveWorkout event,
    Emitter<WorkoutState> emit,
  ) async {
    try {
      await repository.saveWorkout(event.workout);
      // After saving, reload workouts to update the dashboard (and potentially templates)
      add(LoadWorkouts(event.workout.userId));
      // Optionally, if templates should also be reloaded after saving a workout
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
      // Retrieve current workouts and workoutSummary if they exist in the current state to preserve them
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