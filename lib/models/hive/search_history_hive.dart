import 'package:hive/hive.dart';

part 'search_history_hive.g.dart';

@HiveType(typeId: 3)
class SearchHistoryHive extends HiveObject {
  @HiveField(0)
  late String keyword;

  @HiveField(1)
  late DateTime searchedAt;

  @HiveField(2)
  late String entryType;

  @HiveField(3)
  int? animeId;

  @HiveField(4)
  String? animeTitle;

  @HiveField(5)
  String? animeImageUrl;

  @HiveField(6)
  String? animeMetadata;

  SearchHistoryHive({
    required this.keyword,
    DateTime? searchedAt,
    this.entryType = 'keyword',
    this.animeId,
    this.animeTitle,
    this.animeImageUrl,
    this.animeMetadata,
  }) : searchedAt = searchedAt ?? DateTime.now();

  bool get isKeyword => entryType == 'keyword';
  bool get isAnime => entryType == 'anime';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SearchHistoryHive &&
          runtimeType == other.runtimeType &&
          entryType == other.entryType &&
          animeId == other.animeId &&
          keyword == other.keyword;

  @override
  int get hashCode => Object.hash(entryType, keyword, animeId);
}
