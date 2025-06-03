import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/config/app_config.dart';
import '../../domain/entities/workout.dart';
import '../../domain/repositories/workout_repository.dart';

/// Concrete implementation of [WorkoutRepository] using Firestore.
class WorkoutRepositoryImpl implements WorkoutRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<List<Workout>> getWorkouts(String userId) async {
    try {
      final query = await _firestore
          .collection(AppConfig.workoutsCollection)
          .where('userId', isEqualTo: userId)
          // .orderBy('startTime', descending: true) // Removed orderBy to avoid index issues
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
    // This implementation can be expanded later to fetch from a specific
    // 'workout_templates' collection or a flag on the 'workouts' collection.
    // For now, it returns an empty list as per the PDF.
    return [];
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
          .map((e) => _exerciseFromMap(e as Map<String, dynamic>))
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
      'exercises': workout.exercises.map((e) => _exerciseToMap(e)).toList(),
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

  /// Converts a map from Firestore into an [Exercise] object.
  Exercise _exerciseFromMap(Map<String, dynamic> data) {
    return Exercise(
      id: data['id'],
      name: data['name'],
      category: data['category'],
      sets: (data['sets'] as List)
          .map((s) => _setFromMap(s as Map<String, dynamic>))
          .toList(),
      notes: data['notes'],
      restTime: data['restTime'] != null
          ? Duration(seconds: data['restTime'])
          : null,
    );
  }

  /// Converts an [Exercise] object into a map suitable for Firestore.
  Map<String, dynamic> _exerciseToMap(Exercise exercise) {
    return {
      'id': exercise.id,
      'name': exercise.name,
      'category': exercise.category,
      'sets': exercise.sets.map((s) => _setToMap(s)).toList(),
      'notes': exercise.notes,
      'restTime': exercise.restTime?.inSeconds,
    };
  }

  /// Converts a map from Firestore into an [ExerciseSet] object.
  ExerciseSet _setFromMap(Map<String, dynamic> data) {
    return ExerciseSet(
      setNumber: data['setNumber'],
      reps: data['reps'],
      weight: data['weight']?.toDouble() ?? 0.0,
      isCompleted: data['isCompleted'] ?? false,
      type: SetType.values[data['type'] ?? 0],
    );
  }

  /// Converts an [ExerciseSet] object into a map suitable for Firestore.
  Map<String, dynamic> _setToMap(ExerciseSet set) {
    return {
      'setNumber': set.setNumber,
      'reps': set.reps,
      'weight': set.weight,
      'isCompleted': set.isCompleted,
      'type': set.type.index,
    };
  }
}
