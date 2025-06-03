import '../entities/workout.dart';

/// Abstract interface for workout data operations.
///
/// Defines methods for fetching, saving, and managing workout data.
abstract class WorkoutRepository {
  /// Retrieves a list of workouts for a specific [userId].
  ///
  /// Workouts are typically ordered by start time in descending order.
  Future<List<Workout>> getWorkouts(String userId);

  /// Saves a [workout] to the data source.
  ///
  /// If the workout already exists (based on its ID), it should be updated.
  Future<void> saveWorkout(Workout workout);

  /// Deletes a workout by its [workoutId].
  Future<void> deleteWorkout(String workoutId);

  /// Retrieves a list of pre-defined workout templates.
  Future<List<Workout>> getWorkoutTemplates();
}
