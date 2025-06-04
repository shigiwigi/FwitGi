// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WorkoutAdapter extends TypeAdapter<Workout> {
  @override
  final int typeId = 3;

  @override
  Workout read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Workout(
      id: fields[0] as String,
      userId: fields[1] as String,
      name: fields[2] as String,
      type: fields[3] as WorkoutType,
      exercises: (fields[4] as List).cast<WorkoutExercise>(),
      startTime: fields[5] as DateTime,
      endTime: fields[6] as DateTime?,
      duration: fields[7] as Duration,
      notes: fields[8] as String?,
      totalWeight: fields[9] as double,
      totalSets: fields[10] as int,
      totalReps: fields[11] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Workout obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.type)
      ..writeByte(4)
      ..write(obj.exercises)
      ..writeByte(5)
      ..write(obj.startTime)
      ..writeByte(6)
      ..write(obj.endTime)
      ..writeByte(7)
      ..write(obj.duration)
      ..writeByte(8)
      ..write(obj.notes)
      ..writeByte(9)
      ..write(obj.totalWeight)
      ..writeByte(10)
      ..write(obj.totalSets)
      ..writeByte(11)
      ..write(obj.totalReps);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkoutAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class WorkoutExerciseAdapter extends TypeAdapter<WorkoutExercise> {
  @override
  final int typeId = 10;

  @override
  WorkoutExercise read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WorkoutExercise(
      id: fields[0] as String,
      exerciseDefinitionId: fields[1] as String,
      sets: (fields[2] as List).cast<ExerciseSet>(),
      notes: fields[3] as String?,
      restTime: fields[4] as Duration?,
    );
  }

  @override
  void write(BinaryWriter writer, WorkoutExercise obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.exerciseDefinitionId)
      ..writeByte(2)
      ..write(obj.sets)
      ..writeByte(3)
      ..write(obj.notes)
      ..writeByte(4)
      ..write(obj.restTime);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkoutExerciseAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ExerciseSetAdapter extends TypeAdapter<ExerciseSet> {
  @override
  final int typeId = 6;

  @override
  ExerciseSet read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ExerciseSet(
      setNumber: fields[0] as int,
      reps: fields[1] as int,
      weight: fields[2] as double,
      isCompleted: fields[3] as bool,
      type: fields[4] as SetType,
    );
  }

  @override
  void write(BinaryWriter writer, ExerciseSet obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.setNumber)
      ..writeByte(1)
      ..write(obj.reps)
      ..writeByte(2)
      ..write(obj.weight)
      ..writeByte(3)
      ..write(obj.isCompleted)
      ..writeByte(4)
      ..write(obj.type);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExerciseSetAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class WorkoutTypeAdapter extends TypeAdapter<WorkoutType> {
  @override
  final int typeId = 4;

  @override
  WorkoutType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return WorkoutType.push;
      case 1:
        return WorkoutType.pull;
      case 2:
        return WorkoutType.legs;
      case 3:
        return WorkoutType.fullBody;
      case 4:
        return WorkoutType.cardio;
      case 5:
        return WorkoutType.skills;
      case 6:
        return WorkoutType.custom;
      default:
        return WorkoutType.push;
    }
  }

  @override
  void write(BinaryWriter writer, WorkoutType obj) {
    switch (obj) {
      case WorkoutType.push:
        writer.writeByte(0);
        break;
      case WorkoutType.pull:
        writer.writeByte(1);
        break;
      case WorkoutType.legs:
        writer.writeByte(2);
        break;
      case WorkoutType.fullBody:
        writer.writeByte(3);
        break;
      case WorkoutType.cardio:
        writer.writeByte(4);
        break;
      case WorkoutType.skills:
        writer.writeByte(5);
        break;
      case WorkoutType.custom:
        writer.writeByte(6);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkoutTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SetTypeAdapter extends TypeAdapter<SetType> {
  @override
  final int typeId = 7;

  @override
  SetType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return SetType.normal;
      case 1:
        return SetType.warmup;
      case 2:
        return SetType.dropset;
      case 3:
        return SetType.failure;
      default:
        return SetType.normal;
    }
  }

  @override
  void write(BinaryWriter writer, SetType obj) {
    switch (obj) {
      case SetType.normal:
        writer.writeByte(0);
        break;
      case SetType.warmup:
        writer.writeByte(1);
        break;
      case SetType.dropset:
        writer.writeByte(2);
        break;
      case SetType.failure:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SetTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
