// lib/features/workout/domain/repositories/exercise_definition_repository.dart

import '../entities/exercise_definition.dart';

/// Abstract interface for managing exercise definitions.
///
/// Defines methods for fetching and saving reusable exercise definitions.
abstract class ExerciseDefinitionRepository {
  /// Retrieves a list of all available exercise definitions.
  Future<List<ExerciseDefinition>> getExerciseDefinitions();

  /// Saves a new or updates an existing [exerciseDefinition].
  Future<void> saveExerciseDefinition(ExerciseDefinition exerciseDefinition);

  /// Deletes an exercise definition by its [id].
  Future<void> deleteExerciseDefinition(String id);

  /// Seeds initial exercise definitions into the repository if it's empty.
  Future<void> seedInitialDefinitions(); // ADD THIS LINE
}