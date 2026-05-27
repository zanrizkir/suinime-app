part of 'search_history_hive.dart';

class SearchHistoryHiveAdapter extends TypeAdapter<SearchHistoryHive> {
  @override
  final int typeId = 3;

  @override
  SearchHistoryHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SearchHistoryHive(
      keyword: fields[0] as String? ?? '',
      searchedAt: fields[1] as DateTime?,
      entryType: fields[2] as String? ?? 'keyword',
      animeId: fields[3] as int?,
      animeTitle: fields[4] as String?,
      animeImageUrl: fields[5] as String?,
      animeMetadata: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, SearchHistoryHive obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.keyword)
      ..writeByte(1)
      ..write(obj.searchedAt)
      ..writeByte(2)
      ..write(obj.entryType)
      ..writeByte(3)
      ..write(obj.animeId)
      ..writeByte(4)
      ..write(obj.animeTitle)
      ..writeByte(5)
      ..write(obj.animeImageUrl)
      ..writeByte(6)
      ..write(obj.animeMetadata);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SearchHistoryHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
