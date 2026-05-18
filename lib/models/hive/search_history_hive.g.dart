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
      keyword: fields[0] as String,
      searchedAt: fields[1] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, SearchHistoryHive obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.keyword)
      ..writeByte(1)
      ..write(obj.searchedAt);
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
