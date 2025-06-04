// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise_definition.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ExerciseDefinitionAdapter extends TypeAdapter<ExerciseDefinition> {
  @override
  final int typeId = 8;

  @override
  ExerciseDefinition read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ExerciseDefinition(
      id: fields[0] as String,
      name: fields[1] as String,
      category: fields[2] as String,
      description: fields[3] as String?,
      imageUrl: fields[4] as String?,
      defaultSets: fields[5] as int,
      defaultReps: fields[6] as int,
      defaultWeight: fields[7] as double,
      defaultRestTime: fields[8] as Duration?,
      measurementType: fields[9] as ExerciseMeasurementType,
      defaultDuration: fields[10] as Duration?,
      defaultDistance: fields[11] as double?,
      defaultDistanceUnit: fields[12] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ExerciseDefinition obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.category)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.imageUrl)
      ..writeByte(5)
      ..write(obj.defaultSets)
      ..writeByte(6)
      ..write(obj.defaultReps)
      ..writeByte(7)
      ..write(obj.defaultWeight)
      ..writeByte(8)
      ..write(obj.defaultRestTime)
      ..writeByte(9)
      ..write(obj.measurementType)
      ..writeByte(10)
      ..write(obj.defaultDuration)
      ..writeByte(11)
      ..write(obj.defaultDistance)
      ..writeByte(12)
      ..write(obj.defaultDistanceUnit);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExerciseDefinitionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ExerciseMeasurementTypeAdapter
    extends TypeAdapter<ExerciseMeasurementType> {
  @override
  final int typeId = 9;

  @override
  ExerciseMeasurementType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ExerciseMeasurementType.reps;
      case 1:
        return ExerciseMeasurementType.time;
      case 2:
        return ExerciseMeasurementType.distance;
      default:
        return ExerciseMeasurementType.reps;
    }
  }

  @override
  void write(BinaryWriter writer, ExerciseMeasurementType obj) {
    switch (obj) {
      case ExerciseMeasurementType.reps:
        writer.writeByte(0);
        break;
      case ExerciseMeasurementType.time:
        writer.writeByte(1);
        break;
      case ExerciseMeasurementType.distance:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExerciseMeasurementTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
