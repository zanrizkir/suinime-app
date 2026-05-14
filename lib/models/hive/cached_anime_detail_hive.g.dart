part of 'cached_anime_detail_hive.dart';

class CachedAnimeDetailHiveAdapter extends TypeAdapter<CachedAnimeDetailHive> {
  @override
  final int typeId = 4;

  @override
  CachedAnimeDetailHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CachedAnimeDetailHive(
      malId: fields[0] as int,
      title: fields[1] as String,
      imageUrl: fields[2] as String,
      synopsis: fields[3] as String?,
      status: fields[4] as String?,
      episodes: fields[5] as int?,
      genres: (fields[6] as List?)?.cast<String>(),
      rating: fields[7] as double?,
      cachedAt: fields[8] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, CachedAnimeDetailHive obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.malId)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.imageUrl)
      ..writeByte(3)
      ..write(obj.synopsis)
      ..writeByte(4)
      ..write(obj.status)
      ..writeByte(5)
      ..write(obj.episodes)
      ..writeByte(6)
      ..write(obj.genres)
      ..writeByte(7)
      ..write(obj.rating)
      ..writeByte(8)
      ..write(obj.cachedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CachedAnimeDetailHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
