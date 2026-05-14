part of 'watch_history_hive.dart';

class WatchHistoryHiveAdapter extends TypeAdapter<WatchHistoryHive> {
  @override
  final int typeId = 2;

  @override
  WatchHistoryHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WatchHistoryHive(
      malId: fields[0] as int,
      title: fields[1] as String,
      imageUrl: fields[2] as String,
      lastEpisode: fields[3] as int,
      watchedAt: fields[4] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, WatchHistoryHive obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.malId)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.imageUrl)
      ..writeByte(3)
      ..write(obj.lastEpisode)
      ..writeByte(4)
      ..write(obj.watchedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WatchHistoryHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
