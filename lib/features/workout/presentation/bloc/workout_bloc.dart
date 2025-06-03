import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

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
  const WorkoutLoaded(this.workouts);

  @override
  List<Object> get props => [workouts];
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
  }

  /// Handles the [LoadWorkouts] event.
  ///
  /// Emits [WorkoutLoading] then either [WorkoutLoaded] or [WorkoutError].
  Future<void> _onLoadWorkouts(
    LoadWorkouts event,
    Emitter<WorkoutState> emit,
  ) async {
    emit(WorkoutLoading());
    try {
      final workouts = await repository.getWorkouts(event.userId);
      emit(WorkoutLoaded(workouts));
    } catch (e) {
      emit(WorkoutError(e.toString()));
    }
  }

  /// Handles the [SaveWorkout] event.
  ///
  /// Emits [WorkoutLoading] then either a success state (or reloads workouts)
  /// or [WorkoutError].
  Future<void> _onSaveWorkout(
    SaveWorkout event,
    Emitter<WorkoutState> emit,
  ) async {
    // Optionally emit loading if you want to show a saving indicator
    // emit(WorkoutLoading());
    try {
      await repository.saveWorkout(event.workout);
      // Optionally reload workouts or emit success state
      // For simplicity, we're not reloading immediately after saving
      // but a real app might trigger a LoadWorkouts event here.
    } catch (e) {
      emit(WorkoutError(e.toString()));
    }
  }
}
