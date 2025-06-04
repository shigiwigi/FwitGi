// lib/features/workout/data/repositories/exercise_definition_repository_impl.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

import '../../../../../core/config/app_config.dart';
import '../../domain/entities/exercise_definition.dart';
import '../../domain/repositories/exercise_definition_repository.dart';

/// Concrete implementation of [ExerciseDefinitionRepository] using Firestore.
class ExerciseDefinitionRepositoryImpl implements ExerciseDefinitionRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = const Uuid();

  final String _exerciseDefinitionsCollection = AppConfig.exerciseDefinitionsCollection; // Use AppConfig constant


  // Static list of initial ExerciseDefinition data to seed the database
  static final List<ExerciseDefinition> _initialExerciseDefinitions = [
    // Push Exercises
    ExerciseDefinition(
      id: 'bench_press_def_id_1',
      name: 'Barbell Bench Press', category: 'Chest',
      defaultSets: 3, defaultReps: 8, defaultWeight: 60.0,
      measurementType: ExerciseMeasurementType.reps,
    ),
    ExerciseDefinition(
      id: 'incline_db_press_def_id_1',
      name: 'Incline Dumbbell Press', category: 'Chest',
      defaultSets: 2, defaultReps: 10, defaultWeight: 20.0,
      measurementType: ExerciseMeasurementType.reps,
    ),
    ExerciseDefinition(
      id: 'overhead_press_def_id_1', // Reusing ID for general Overhead Press
      name: 'Overhead Press (Barbell)', category: 'Shoulders',
      defaultSets: 2, defaultReps: 8, defaultWeight: 40.0,
      measurementType: ExerciseMeasurementType.reps,
    ),
    ExerciseDefinition(
      id: 'overhead_press_bottle_def_id_1', // Specific ID for bottle/dumbbell variation
      name: 'Overhead Press (Bottle/Dumbbell)', category: 'Shoulders',
      defaultSets: 3, defaultReps: 10, defaultWeight: 0.0, // Bodyweight/light
      measurementType: ExerciseMeasurementType.reps,
    ),
    ExerciseDefinition(
      id: 'incline_push_ups_def_id_1',
      name: 'Incline Push-ups', category: 'Chest',
      defaultSets: 3, defaultReps: 10, defaultWeight: 0.0,
      measurementType: ExerciseMeasurementType.reps,
    ),
    ExerciseDefinition(
      id: 'knee_push_ups_def_id_1',
      name: 'Knee Push-ups', category: 'Chest',
      defaultSets: 3, defaultReps: 10, defaultWeight: 0.0,
      measurementType: ExerciseMeasurementType.reps,
    ),

    // Pull Exercises
    ExerciseDefinition(
      id: 'pull_ups_def_id_1',
      name: 'Pull-ups', category: 'Back',
      defaultSets: 2, defaultReps: 8, defaultWeight: 0.0,
      measurementType: ExerciseMeasurementType.reps,
    ),
    ExerciseDefinition(
      id: 'barbell_rows_def_id_1',
      name: 'Barbell Rows', category: 'Back',
      defaultSets: 3, defaultReps: 10, defaultWeight: 50.0,
      measurementType: ExerciseMeasurementType.reps,
    ),
    ExerciseDefinition(
      id: 'db_rows_def_id_1',
      name: 'Dumbbell Rows (or backpack)', category: 'Back',
      defaultSets: 3, defaultReps: 12, defaultWeight: 0.0,
      measurementType: ExerciseMeasurementType.reps,
    ),
    ExerciseDefinition(
      id: 'bicep_curls_def_id_1',
      name: 'Bicep Curls', category: 'Biceps',
      defaultSets: 3, defaultReps: 12, defaultWeight: 0.0,
      measurementType: ExerciseMeasurementType.reps,
    ),

    // Leg Exercises
    ExerciseDefinition(
      id: 'bodyweight_squats_def_id_1',
      name: 'Bodyweight Squats', category: 'Legs',
      defaultSets: 3, defaultReps: 15, defaultWeight: 0.0,
      measurementType: ExerciseMeasurementType.reps,
    ),
    ExerciseDefinition(
      id: 'glute_bridges_def_id_1',
      name: 'Glute Bridges', category: 'Glutes',
      defaultSets: 3, defaultReps: 15, defaultWeight: 0.0,
      measurementType: ExerciseMeasurementType.reps,
    ),
    ExerciseDefinition(
      id: 'goblet_squats_def_id_1',
      name: 'Goblet Squats (or bodyweight)', category: 'Legs',
      defaultSets: 3, defaultReps: 15, defaultWeight: 0.0,
      measurementType: ExerciseMeasurementType.reps,
    ),
    ExerciseDefinition(
      id: 'lunges_def_id_1',
      name: 'Lunges', category: 'Legs',
      defaultSets: 3, defaultReps: 10, defaultWeight: 0.0,
      measurementType: ExerciseMeasurementType.reps,
    ),
    ExerciseDefinition(
      id: 'calf_raises_def_id_1',
      name: 'Calf Raises', category: 'Calves',
      defaultSets: 3, defaultReps: 20, defaultWeight: 0.0,
      measurementType: ExerciseMeasurementType.reps,
    ),
    ExerciseDefinition(
      id: 'wall_sit_def_id_1',
      name: 'Wall Sit', category: 'Legs',
      defaultSets: 2, defaultReps: 0, defaultWeight: 0.0,
      measurementType: ExerciseMeasurementType.time,
      defaultDuration: Duration(seconds: 30), // Example for 30s
    ),

    // Core Exercises
    ExerciseDefinition(
      id: 'bird_dogs_def_id_1',
      name: 'Bird-Dogs', category: 'Core',
      defaultSets: 2, defaultReps: 10, defaultWeight: 0.0,
      measurementType: ExerciseMeasurementType.reps,
      description: 'per side',
    ),
    ExerciseDefinition(
      id: 'plank_def_id_1',
      name: 'Plank', category: 'Core',
      defaultSets: 2, defaultReps: 0, defaultWeight: 0.0,
      measurementType: ExerciseMeasurementType.time,
      defaultDuration: Duration(seconds: 30),
    ),
    ExerciseDefinition(
      id: 'russian_twists_def_id_1',
      name: 'Russian Twists', category: 'Core',
      defaultSets: 2, defaultReps: 20, defaultWeight: 0.0,
      measurementType: ExerciseMeasurementType.reps,
    ),
    ExerciseDefinition(
      id: 'leg_raises_def_id_1',
      name: 'Leg Raises', category: 'Core',
      defaultSets: 2, defaultReps: 15, defaultWeight: 0.0,
      measurementType: ExerciseMeasurementType.reps,
    ),
  ];

   @override
  Future<List<ExerciseDefinition>> getExerciseDefinitions() async {
    try {
      final querySnapshot = await _firestore
          .collection(_exerciseDefinitionsCollection)
          .orderBy('name')
          .get();

      // ADD THIS PRINT STATEMENT
      print('DEBUG: ExerciseDefinitionRepository: Fetched ${querySnapshot.docs.length} exercise definitions from Firestore.');

      return querySnapshot.docs
          .map((doc) => ExerciseDefinition.fromJson(doc.data()))
          .toList();
    } catch (e) {
      // ADD THIS PRINT STATEMENT FOR ERRORS
      print('ERROR: ExerciseDefinitionRepository: Failed to get exercise definitions from Firestore: ${e.toString()}');
      throw Exception('Failed to get exercise definitions: ${e.toString()}');
    }
  }

  @override
  Future<void> saveExerciseDefinition(ExerciseDefinition exerciseDefinition) async {
    try {
      final String id = exerciseDefinition.id.isEmpty ? _uuid.v4() : exerciseDefinition.id;

      await _firestore
          .collection(_exerciseDefinitionsCollection)
          .doc(id)
          .set(exerciseDefinition.toJson());
    } catch (e) {
      throw Exception('Failed to save exercise definition: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteExerciseDefinition(String id) async {
    try {
      await _firestore
          .collection(_exerciseDefinitionsCollection)
          .doc(id)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete exercise definition: ${e.toString()}');
    }
  }

  // New method to seed initial exercise definitions
  Future<void> seedInitialDefinitions() async {
    try {
      final existingDefinitions = await getExerciseDefinitions();
      if (existingDefinitions.isEmpty) {
        print('Seeding initial exercise definitions...');
        for (var def in _initialExerciseDefinitions) {
          await saveExerciseDefinition(def);
        }
        print('Initial exercise definitions seeded successfully.');
      } else {
        print('Exercise definitions already exist. Skipping seeding.');
      }
    } catch (e) {
      print('Error seeding initial exercise definitions: $e');
      throw Exception('Failed to seed initial exercise definitions: ${e.toString()}');
    }
  }
}