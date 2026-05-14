// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'library_item_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LibraryItemHiveAdapter extends TypeAdapter<LibraryItemHive> {
  @override
  final int typeId = 0;

  @override
  LibraryItemHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LibraryItemHive(
      malId: fields[0] as int,
      title: fields[1] as String,
      imageUrl: fields[2] as String,
      score: fields[3] as double?,
      categoryId: fields[4] as String,
      addedAt: fields[5] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, LibraryItemHive obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.malId)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.imageUrl)
      ..writeByte(3)
      ..write(obj.score)
      ..writeByte(4)
      ..write(obj.categoryId)
      ..writeByte(5)
      ..write(obj.addedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LibraryItemHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
