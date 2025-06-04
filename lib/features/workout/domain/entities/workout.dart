import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'workout.g.dart';

@HiveType(typeId: 3)
class Workout extends Equatable {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String userId;
  @HiveField(2)
  final String name;
  @HiveField(3)
  final WorkoutType type;
  @HiveField(4)
  final List<WorkoutExercise> exercises;
  @HiveField(5)
  final DateTime startTime;
  @HiveField(6)
  final DateTime? endTime;
  @HiveField(7)
  final Duration duration;
  @HiveField(8)
  final String? notes;
  @HiveField(9)
  final double totalWeight;
  @HiveField(10)
  final int totalSets;
  @HiveField(11)
  final int totalReps;

  const Workout({
    required this.id,
    required this.userId,
    required this.name,
    required this.type,
    required this.exercises,
    required this.startTime,
    this.endTime,
    required this.duration,
    this.notes,
    required this.totalWeight,
    required this.totalSets,
    required this.totalReps,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        name,
        type,
        exercises,
        startTime,
        endTime,
        duration,
        notes,
        totalWeight,
        totalSets,
        totalReps
      ];

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'name': name,
        'type': type.index,
        'exercises': exercises.map((e) => e.toJson()).toList(),
        'startTime': startTime.toIso8601String(),
        'endTime': endTime?.toIso8601String(),
        'duration': duration.inSeconds,
        'notes': notes,
        'totalWeight': totalWeight,
        'totalSets': totalSets,
        'totalReps': totalReps,
      };

  factory Workout.fromJson(Map<String, dynamic> json) => Workout(
        id: json['id'] as String? ?? 'unknown_workout_id', // Handle null ID
        userId: json['userId'] as String? ?? 'unknown_user_id', // Handle null userId
        name: json['name'] as String? ?? 'Untitled Workout', // Handle null name
        type: WorkoutType.values[json['type'] as int? ?? 0], // Handle null type, default to 0 (push)
        exercises: (json['exercises'] as List?) // Handle null exercises list
            ?.map((e) => WorkoutExercise.fromJson(e as Map<String, dynamic>))
            .toList() ?? [], // Default to empty list
        startTime: json['startTime'] != null // Handle null startTime
            ? DateTime.parse(json['startTime'] as String)
            : DateTime(2000), // Default to a past date
        endTime: json['endTime'] != null
            ? DateTime.parse(json['endTime'] as String)
            : null,
        duration: Duration(seconds: json['duration'] as int? ?? 0), // Handle null duration
        notes: json['notes'] as String?,
        totalWeight: json['totalWeight']?.toDouble() ?? 0.0,
        totalSets: json['totalSets'] as int? ?? 0, // Handle null totalSets
        totalReps: json['totalReps'] as int? ?? 0, // Handle null totalReps
      );
}

@HiveType(typeId: 4)
enum WorkoutType {
  @HiveField(0)
  push,
  @HiveField(1)
  pull,
  @HiveField(2)
  legs,
  @HiveField(3)
  fullBody,
  @HiveField(4)
  cardio,
  @HiveField(5)
  skills,
  @HiveField(6)
  custom,
}

@HiveType(typeId: 10)
class WorkoutExercise extends Equatable {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String exerciseDefinitionId;
  @HiveField(2)
  final List<ExerciseSet> sets;
  @HiveField(3)
  final String? notes;
  @HiveField(4)
  final Duration? restTime;

  const WorkoutExercise({
    required this.id,
    required this.exerciseDefinitionId,
    required this.sets,
    this.notes,
    this.restTime,
  });

  @override
  List<Object?> get props => [id, exerciseDefinitionId, sets, notes, restTime];

  Map<String, dynamic> toJson() => {
        'id': id,
        'exerciseDefinitionId': exerciseDefinitionId,
        'sets': sets.map((s) => s.toJson()).toList(),
        'notes': notes,
        'restTime': restTime?.inSeconds,
      };

  factory WorkoutExercise.fromJson(Map<String, dynamic> json) => WorkoutExercise(
        id: json['id'] as String? ?? 'unknown_exercise_id', // Handle null ID
        exerciseDefinitionId: json['exerciseDefinitionId'] as String? ?? 'unknown_def_id', // Handle null exerciseDefinitionId
        sets: (json['sets'] as List?) // Handle null sets list
            ?.map((s) => ExerciseSet.fromJson(s as Map<String, dynamic>))
            .toList() ?? [], // Default to empty list
        notes: json['notes'] as String?,
        restTime: json['restTime'] != null
            ? Duration(seconds: json['restTime'] as int)
            : null,
      );
}


@HiveType(typeId: 6)
class ExerciseSet extends Equatable {
  @HiveField(0)
  final int setNumber;
  @HiveField(1)
  final int reps;
  @HiveField(2)
  final double weight;
  @HiveField(3)
  final bool isCompleted;
  @HiveField(4)
  final SetType type;

  const ExerciseSet({
    required this.setNumber,
    required this.reps,
    required this.weight,
    required this.isCompleted,
    required this.type,
  });

  @override
  List<Object> get props => [setNumber, reps, weight, isCompleted, type];

  Map<String, dynamic> toJson() => {
        'setNumber': setNumber,
        'reps': reps,
        'weight': weight,
        'isCompleted': isCompleted,
        'type': type.index,
      };

  factory ExerciseSet.fromJson(Map<String, dynamic> json) => ExerciseSet(
        setNumber: json['setNumber'] as int? ?? 0, // Handle null setNumber
        reps: json['reps'] as int? ?? 0, // Handle null reps
        weight: json['weight']?.toDouble() ?? 0.0, // Handle null weight
        isCompleted: json['isCompleted'] as bool? ?? false, // Handle null isCompleted
        type: SetType.values[json['type'] as int? ?? 0], // Handle null type
      );
}

@HiveType(typeId: 7)
enum SetType {
  @HiveField(0)
  normal,
  @HiveField(1)
  warmup,
  @HiveField(2)
  dropset,
  @HiveField(3)
  failure,
}