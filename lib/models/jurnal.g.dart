// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'jurnal.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class JournalAdapter extends TypeAdapter<Journal> {
  @override
  final int typeId = 2;

  @override
  Journal read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Journal(
      id: fields[0] as int,
      title: fields[1] as String,
      content: fields[2] as String,
      date: fields[3] as DateTime,
      imagePath: fields[4] as String?,
    )..key = fields[5] as int?;
  }

  @override
  void write(BinaryWriter writer, Journal obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.content)
      ..writeByte(3)
      ..write(obj.date)
      ..writeByte(4)
      ..write(obj.imagePath)
      ..writeByte(5)
      ..write(obj.key);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JournalAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
