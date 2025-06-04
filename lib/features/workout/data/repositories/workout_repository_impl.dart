import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/config/app_config.dart';
import '../../domain/entities/workout.dart';
import '../../domain/repositories/workout_repository.dart';
import '../../domain/repositories/exercise_definition_repository.dart'; // Import the new repository

/// Concrete implementation of [WorkoutRepository] using Firestore.
class WorkoutRepositoryImpl implements WorkoutRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = const Uuid();

  // Inject ExerciseDefinitionRepository
  final ExerciseDefinitionRepository _exerciseDefinitionRepository; // ADD THIS

  WorkoutRepositoryImpl(this._exerciseDefinitionRepository); // UPDATE CONSTRUCTOR


  @override
  Future<List<Workout>> getWorkouts(String userId) async {
    try {
      final query = await _firestore
          .collection(AppConfig.workoutsCollection)
          .where('userId', isEqualTo: userId)
          // .orderBy('startTime', descending: true) // Re-add if you have Firestore index configured
          .get();

      return query.docs.map((doc) => _workoutFromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to get workouts: ${e.toString()}');
    }
  }

  @override
  Future<void> saveWorkout(Workout workout) async {
    try {
      await _firestore
          .collection(AppConfig.workoutsCollection)
          .doc(workout.id)
          .set(_workoutToFirestore(workout));
    } catch (e) {
      throw Exception('Failed to save workout: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteWorkout(String workoutId) async {
    try {
      await _firestore
          .collection(AppConfig.workoutsCollection)
          .doc(workoutId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete workout: ${e.toString()}');
    }
  }

  @override
  Future<List<Workout>> getWorkoutTemplates() async {
    // Hardcoded workout templates now use WorkoutExercise with exerciseDefinitionId
    return [
      // Existing Push Day Template
      Workout(
        id: _uuid.v4(),
        userId: 'template_user_id',
        name: 'Push Day Template',
        type: WorkoutType.push,
        exercises: [
          WorkoutExercise(
            id: _uuid.v4(), // Unique ID for this instance in the template
            exerciseDefinitionId: 'bench_press_def_id_1', // Placeholder ID for ExerciseDefinition
            sets: [
              ExerciseSet(setNumber: 1, reps: 8, weight: 60.0, isCompleted: false, type: SetType.normal),
              ExerciseSet(setNumber: 2, reps: 8, weight: 60.0, isCompleted: false, type: SetType.normal),
              ExerciseSet(setNumber: 3, reps: 8, weight: 60.0, isCompleted: false, type: SetType.normal),
            ],
            notes: 'Focus on full range of motion',
            restTime: const Duration(minutes: 2),
          ),
          WorkoutExercise(
            id: _uuid.v4(),
            exerciseDefinitionId: 'incline_db_press_def_id_1',
            sets: [
              ExerciseSet(setNumber: 1, reps: 10, weight: 20.0, isCompleted: false, type: SetType.normal),
              ExerciseSet(setNumber: 2, reps: 10, weight: 20.0, isCompleted: false, type: SetType.normal),
            ],
            notes: 'Control the negative',
            restTime: const Duration(minutes: 1, seconds: 30),
          ),
          WorkoutExercise(
            id: _uuid.v4(),
            exerciseDefinitionId: 'overhead_press_def_id_1',
            sets: [
              ExerciseSet(setNumber: 1, reps: 8, weight: 40.0, isCompleted: false, type: SetType.normal),
              ExerciseSet(setNumber: 2, reps: 8, weight: 40.0, isCompleted: false, type: SetType.normal),
            ],
            notes: null,
            restTime: const Duration(minutes: 2),
          ),
        ],
        startTime: DateTime(2000),
        duration: Duration.zero,
        endTime: null,
        notes: null,
        totalWeight: 0.0,
        totalSets: 0,
        totalReps: 0,
      ),
      // Existing Pull Day Template
      Workout(
        id: _uuid.v4(),
        userId: 'template_user_id',
        name: 'Pull Day Template',
        type: WorkoutType.pull,
        exercises: [
          WorkoutExercise(
            id: _uuid.v4(),
            exerciseDefinitionId: 'pull_ups_def_id_1',
            sets: [
              ExerciseSet(setNumber: 1, reps: 8, weight: 0.0, isCompleted: false, type: SetType.normal),
              ExerciseSet(setNumber: 2, reps: 8, weight: 0.0, isCompleted: false, type: SetType.normal),
            ],
            notes: 'Focus on scapular retraction',
            restTime: const Duration(minutes: 2),
          ),
          WorkoutExercise(
            id: _uuid.v4(),
            exerciseDefinitionId: 'barbell_rows_def_id_1',
            sets: [
              ExerciseSet(setNumber: 1, reps: 10, weight: 50.0, isCompleted: false, type: SetType.normal),
              ExerciseSet(setNumber: 2, reps: 10, weight: 50.0, isCompleted: false, type: SetType.normal),
              ExerciseSet(setNumber: 3, reps: 10, weight: 50.0, isCompleted: false, type: SetType.normal),
            ],
            notes: 'Keep back straight',
            restTime: const Duration(minutes: 1, seconds: 30),
          ),
        ],
        startTime: DateTime(2000),
        duration: Duration.zero,
        endTime: null,
        notes: null,
        totalWeight: 0.0,
        totalSets: 0,
        totalReps: 0,
      ),
      // --- New Template: Beginner Full Body - Day 1 (No Equipment) ---
      Workout(
        id: _uuid.v4(),
        userId: 'template_user_id',
        name: 'Beginner Full Body - Day 1 (No Equipment)',
        type: WorkoutType.fullBody,
        exercises: [
          WorkoutExercise(id: _uuid.v4(), exerciseDefinitionId: 'bodyweight_squats_def_id_1',
            sets: [ExerciseSet(setNumber: 1, reps: 15, weight: 0.0, isCompleted: false, type: SetType.normal),
                   ExerciseSet(setNumber: 2, reps: 15, weight: 0.0, isCompleted: false, type: SetType.normal),
                   ExerciseSet(setNumber: 3, reps: 15, weight: 0.0, isCompleted: false, type: SetType.normal),],
            notes: null, restTime: null,),
          WorkoutExercise(id: _uuid.v4(), exerciseDefinitionId: 'incline_push_ups_def_id_1',
            sets: [ExerciseSet(setNumber: 1, reps: 10, weight: 0.0, isCompleted: false, type: SetType.normal),
                   ExerciseSet(setNumber: 2, reps: 10, weight: 0.0, isCompleted: false, type: SetType.normal),
                   ExerciseSet(setNumber: 3, reps: 10, weight: 0.0, isCompleted: false, type: SetType.normal),],
            notes: null, restTime: null,),
          WorkoutExercise(id: _uuid.v4(), exerciseDefinitionId: 'glute_bridges_def_id_1',
            sets: [ExerciseSet(setNumber: 1, reps: 15, weight: 0.0, isCompleted: false, type: SetType.normal),
                   ExerciseSet(setNumber: 2, reps: 15, weight: 0.0, isCompleted: false, type: SetType.normal),
                   ExerciseSet(setNumber: 3, reps: 15, weight: 0.0, isCompleted: false, type: SetType.normal),],
            notes: null, restTime: null,),
          WorkoutExercise(id: _uuid.v4(), exerciseDefinitionId: 'bird_dogs_def_id_1',
            sets: [ExerciseSet(setNumber: 1, reps: 10, weight: 0.0, isCompleted: false, type: SetType.normal),
                   ExerciseSet(setNumber: 2, reps: 10, weight: 0.0, isCompleted: false, type: SetType.normal),],
            notes: 'per side', restTime: null,),
          WorkoutExercise(id: _uuid.v4(), exerciseDefinitionId: 'wall_sit_def_id_1',
            sets: [ExerciseSet(setNumber: 1, reps: 0, weight: 0.0, isCompleted: false, type: SetType.normal),
                   ExerciseSet(setNumber: 2, reps: 0, weight: 0.0, isCompleted: false, type: SetType.normal),],
            notes: '30 seconds', restTime: null,),
          WorkoutExercise(id: _uuid.v4(), exerciseDefinitionId: 'plank_def_id_1',
            sets: [ExerciseSet(setNumber: 1, reps: 0, weight: 0.0, isCompleted: false, type: SetType.normal),
                   ExerciseSet(setNumber: 2, reps: 0, weight: 0.0, isCompleted: false, type: SetType.normal),],
            notes: '30 seconds', restTime: null,),
        ],
        startTime: DateTime(2000), duration: Duration.zero, endTime: null, notes: null, totalWeight: 0.0, totalSets: 0, totalReps: 0,
      ),
      // --- New Template: Beginner Full Body - Day 3 (No Equipment) ---
      Workout(
        id: _uuid.v4(),
        userId: 'template_user_id',
        name: 'Beginner Full Body - Day 3 (No Equipment)',
        type: WorkoutType.legs,
        exercises: [
          WorkoutExercise(id: _uuid.v4(), exerciseDefinitionId: 'goblet_squats_def_id_1',
            sets: [ExerciseSet(setNumber: 1, reps: 15, weight: 0.0, isCompleted: false, type: SetType.normal),
                   ExerciseSet(setNumber: 2, reps: 15, weight: 0.0, isCompleted: false, type: SetType.normal),
                   ExerciseSet(setNumber: 3, reps: 15, weight: 0.0, isCompleted: false, type: SetType.normal),],
            notes: null, restTime: null,),
          WorkoutExercise(id: _uuid.v4(), exerciseDefinitionId: 'lunges_def_id_1',
            sets: [ExerciseSet(setNumber: 1, reps: 10, weight: 0.0, isCompleted: false, type: SetType.normal),
                   ExerciseSet(setNumber: 2, reps: 10, weight: 0.0, isCompleted: false, type: SetType.normal),
                   ExerciseSet(setNumber: 3, reps: 10, weight: 0.0, isCompleted: false, type: SetType.normal),],
            notes: 'per leg', restTime: null,),
          WorkoutExercise(id: _uuid.v4(), exerciseDefinitionId: 'glute_bridges_def_id_1',
            sets: [ExerciseSet(setNumber: 1, reps: 15, weight: 0.0, isCompleted: false, type: SetType.normal),
                   ExerciseSet(setNumber: 2, reps: 15, weight: 0.0, isCompleted: false, type: SetType.normal),
                   ExerciseSet(setNumber: 3, reps: 15, weight: 0.0, isCompleted: false, type: SetType.normal),],
            notes: null, restTime: null,),
          WorkoutExercise(id: _uuid.v4(), exerciseDefinitionId: 'calf_raises_def_id_1',
            sets: [ExerciseSet(setNumber: 1, reps: 20, weight: 0.0, isCompleted: false, type: SetType.normal),
                   ExerciseSet(setNumber: 2, reps: 20, weight: 0.0, isCompleted: false, type: SetType.normal),
                   ExerciseSet(setNumber: 3, reps: 20, weight: 0.0, isCompleted: false, type: SetType.normal),],
            notes: null, restTime: null,),
          WorkoutExercise(id: _uuid.v4(), exerciseDefinitionId: 'wall_sit_def_id_1',
            sets: [ExerciseSet(setNumber: 1, reps: 0, weight: 0.0, isCompleted: false, type: SetType.normal),
                   ExerciseSet(setNumber: 2, reps: 0, weight: 0.0, isCompleted: false, type: SetType.normal),],
            notes: '45 seconds', restTime: null,),
        ],
        startTime: DateTime(2000), duration: Duration.zero, endTime: null, notes: null, totalWeight: 0.0, totalSets: 0, totalReps: 0,
      ),
      // --- New Template: Beginner Full Body - Day 5 (No Equipment) ---
      Workout(
        id: _uuid.v4(),
        userId: 'template_user_id',
        name: 'Beginner Full Body - Day 5 (No Equipment)',
        type: WorkoutType.fullBody,
        exercises: [
          WorkoutExercise(id: _uuid.v4(), exerciseDefinitionId: 'knee_push_ups_def_id_1',
            sets: [ExerciseSet(setNumber: 1, reps: 10, weight: 0.0, isCompleted: false, type: SetType.normal),
                   ExerciseSet(setNumber: 2, reps: 10, weight: 0.0, isCompleted: false, type: SetType.normal),
                   ExerciseSet(setNumber: 3, reps: 10, weight: 0.0, isCompleted: false, type: SetType.normal),],
            notes: null, restTime: null,),
          WorkoutExercise(id: _uuid.v4(), exerciseDefinitionId: 'db_rows_def_id_1',
            sets: [ExerciseSet(setNumber: 1, reps: 12, weight: 0.0, isCompleted: false, type: SetType.normal),
                   ExerciseSet(setNumber: 2, reps: 12, weight: 0.0, isCompleted: false, type: SetType.normal),
                   ExerciseSet(setNumber: 3, reps: 12, weight: 0.0, isCompleted: false, type: SetType.normal),],
            notes: null, restTime: null,),
          WorkoutExercise(id: _uuid.v4(), exerciseDefinitionId: 'overhead_press_bottle_def_id_1', // Using unique ID for this variation
            sets: [ExerciseSet(setNumber: 1, reps: 10, weight: 0.0, isCompleted: false, type: SetType.normal),
                   ExerciseSet(setNumber: 2, reps: 10, weight: 0.0, isCompleted: false, type: SetType.normal),
                   ExerciseSet(setNumber: 3, reps: 10, weight: 0.0, isCompleted: false, type: SetType.normal),],
            notes: null, restTime: null,),
          WorkoutExercise(id: _uuid.v4(), exerciseDefinitionId: 'bicep_curls_def_id_1',
            sets: [ExerciseSet(setNumber: 1, reps: 12, weight: 0.0, isCompleted: false, type: SetType.normal),
                   ExerciseSet(setNumber: 2, reps: 12, weight: 0.0, isCompleted: false, type: SetType.normal),
                   ExerciseSet(setNumber: 3, reps: 12, weight: 0.0, isCompleted: false, type: SetType.normal),],
            notes: null, restTime: null,),
          WorkoutExercise(id: _uuid.v4(), exerciseDefinitionId: 'russian_twists_def_id_1',
            sets: [ExerciseSet(setNumber: 1, reps: 20, weight: 0.0, isCompleted: false, type: SetType.normal),
                   ExerciseSet(setNumber: 2, reps: 20, weight: 0.0, isCompleted: false, type: SetType.normal),],
            notes: null, restTime: null,),
          WorkoutExercise(id: _uuid.v4(), exerciseDefinitionId: 'leg_raises_def_id_1',
            sets: [ExerciseSet(setNumber: 1, reps: 15, weight: 0.0, isCompleted: false, type: SetType.normal),
                   ExerciseSet(setNumber: 2, reps: 15, weight: 0.0, isCompleted: false, type: SetType.normal),],
            notes: null, restTime: null,),
        ],
        startTime: DateTime(2000), duration: Duration.zero, endTime: null, notes: null, totalWeight: 0.0, totalSets: 0, totalReps: 0,
      ),
    ];
  }

  @override
  Future<Map<String, double>> getWorkoutSummaryForPeriod(String userId, DateTime startDate, DateTime endDate) async {
    print('DEBUG: getWorkoutSummaryForPeriod called for userId: $userId, startDate: $startDate, endDate: $endDate');
    try {
      final querySnapshot = await _firestore
          .collection(AppConfig.workoutsCollection)
          .where('userId', isEqualTo: userId)
          .where('startTime', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('startTime', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          // .orderBy('startTime')
          .get();

      print('DEBUG: getWorkoutSummaryForPeriod received ${querySnapshot.docs.length} documents.');

      final Map<String, double> dailyTotals = {};
      final DateFormat formatter = DateFormat('yyyy-MM-dd');

      for (var doc in querySnapshot.docs) {
        final workout = _workoutFromFirestore(doc);
        final dateKey = formatter.format(workout.startTime);
        dailyTotals.update(dateKey, (value) => value + workout.totalWeight, ifAbsent: () => workout.totalWeight);
        print('DEBUG: Processing workout ID: ${workout.id}, startTime: ${workout.startTime}, totalWeight: ${workout.totalWeight}, dateKey: $dateKey');
      }
      print('DEBUG: Final dailyTotals: $dailyTotals');
      return dailyTotals;
    } catch (e) {
      print('ERROR: Failed to get workout summary: $e');
      throw Exception('Failed to get workout summary: ${e.toString()}');
    }
  }

  /// Converts a Firestore [DocumentSnapshot] into a [Workout] object.
  Workout _workoutFromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Workout(
      id: doc.id,
      userId: data['userId'],
      name: data['name'],
      type: WorkoutType.values[data['type']],
      exercises: (data['exercises'] as List)
          .map((e) => WorkoutExercise.fromJson(e as Map<String, dynamic>)) // UPDATED: Use WorkoutExercise.fromJson
          .toList(),
      startTime: (data['startTime'] as Timestamp).toDate(),
      endTime: data['endTime'] != null
          ? (data['endTime'] as Timestamp).toDate()
          : null,
      duration: Duration(seconds: data['duration']),
      notes: data['notes'],
      totalWeight: data['totalWeight']?.toDouble() ?? 0.0,
      totalSets: data['totalSets'] ?? 0,
      totalReps: data['totalReps'] ?? 0,
    );
  }

  /// Converts a [Workout] object into a map suitable for Firestore.
  Map<String, dynamic> _workoutToFirestore(Workout workout) {
    return {
      'userId': workout.userId,
      'name': workout.name,
      'type': workout.type.index,
      'exercises': workout.exercises.map((e) => e.toJson()).toList(), // UPDATED: Use WorkoutExercise.toJson
      'startTime': Timestamp.fromDate(workout.startTime),
      'endTime': workout.endTime != null
          ? Timestamp.fromDate(workout.endTime!)
          : null,
      'duration': workout.duration.inSeconds,
      'notes': workout.notes,
      'totalWeight': workout.totalWeight,
      'totalSets': workout.totalSets,
      'totalReps': workout.totalReps,
    };
  }
}