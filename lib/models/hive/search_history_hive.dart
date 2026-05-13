import 'package:hive/hive.dart';

part 'search_history_hive.g.dart';

@HiveType(typeId: 3)
class SearchHistoryHive extends HiveObject {
  @HiveField(0)
  late String keyword;

  @HiveField(1)
  late DateTime searchedAt;

  SearchHistoryHive({required this.keyword, DateTime? searchedAt})
    : searchedAt = searchedAt ?? DateTime.now();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SearchHistoryHive &&
          runtimeType == other.runtimeType &&
          keyword == other.keyword;

  @override
  int get hashCode => keyword.hashCode;
}
