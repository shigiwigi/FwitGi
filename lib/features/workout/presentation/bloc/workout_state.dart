// lib/features/workout/presentation/bloc/workout_state.dart

import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import '../../domain/entities/workout.dart'; // Needed for WorkoutLoaded state

/// Abstract base class for all Workout States.
@immutable
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
  final List<Workout> workoutTemplates;
  const WorkoutLoaded(this.workouts, {this.workoutSummary = const {}, this.workoutTemplates = const []});

  @override
  List<Object> get props => [workouts, workoutSummary, workoutTemplates];
}

/// State indicating an error occurred during a workout operation.
class WorkoutError extends WorkoutState {
  final String message;
  const WorkoutError(this.message);

  @override
  List<Object> get props => [message];
}