// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TaskModelAdapter extends TypeAdapter<TaskModel> {
  @override
  final int typeId = 1;

  @override
  TaskModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TaskModel(
      id: fields[0] as String,
      title: fields[1] as String,
      discription: fields[2] as String,
      date: fields[3] as String,
      startTime: fields[4] as String,
      endTime: fields[5] as String,
      color: fields[6] as int,
      isCompleted: fields[7] as bool,
      category: fields[8] as String?,
      priority: fields[9] as int?,
      subTasks: (fields[10] as List?)?.cast<String>(),
      subTasksCompleted: (fields[11] as List?)?.cast<bool>(),
      isRepeat: fields[12] as String?,
      notificationId: fields[13] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, TaskModel obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.discription)
      ..writeByte(3)
      ..write(obj.date)
      ..writeByte(4)
      ..write(obj.startTime)
      ..writeByte(5)
      ..write(obj.endTime)
      ..writeByte(6)
      ..write(obj.color)
      ..writeByte(7)
      ..write(obj.isCompleted)
      ..writeByte(8)
      ..write(obj.category)
      ..writeByte(9)
      ..write(obj.priority)
      ..writeByte(10)
      ..write(obj.subTasks)
      ..writeByte(11)
      ..write(obj.subTasksCompleted)
      ..writeByte(12)
      ..write(obj.isRepeat)
      ..writeByte(13)
      ..write(obj.notificationId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
