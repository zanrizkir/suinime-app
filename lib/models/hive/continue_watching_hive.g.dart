part of 'continue_watching_hive.dart';

class ContinueWatchingHiveAdapter extends TypeAdapter<ContinueWatchingHive> {
  @override
  final int typeId = 1;

  @override
  ContinueWatchingHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ContinueWatchingHive(
      malId: fields[0] as int,
      animeTitle: fields[1] as String,
      imageUrl: fields[2] as String,
      episodeNumber: fields[3] as int,
      position: fields[4] as int,
      duration: fields[5] as int,
      updatedAt: fields[6] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, ContinueWatchingHive obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.malId)
      ..writeByte(1)
      ..write(obj.animeTitle)
      ..writeByte(2)
      ..write(obj.imageUrl)
      ..writeByte(3)
      ..write(obj.episodeNumber)
      ..writeByte(4)
      ..write(obj.position)
      ..writeByte(5)
      ..write(obj.duration)
      ..writeByte(6)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContinueWatchingHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
