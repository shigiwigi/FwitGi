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

  /// Retrieves a summary of total weight lifted per day for a specific period.
  ///
  /// Returns a Map where keys are dates (e.g., 'YYYY-MM-DD') and values are
  /// the total weight lifted on that day.
  Future<Map<String, double>> getWorkoutSummaryForPeriod(String userId, DateTime startDate, DateTime endDate);
}