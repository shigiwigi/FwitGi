// lib/features/workout/presentation/bloc/workout_event.dart

import 'package:equatable/equatable.dart';
import '../../domain/entities/workout.dart'; // Needed for SaveWorkout event

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