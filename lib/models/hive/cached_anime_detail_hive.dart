import 'package:hive/hive.dart';

part 'cached_anime_detail_hive.g.dart';

@HiveType(typeId: 4)
class CachedAnimeDetailHive extends HiveObject {
  @HiveField(0)
  late int malId;

  @HiveField(1)
  late String title;

  @HiveField(2)
  late String imageUrl;

  @HiveField(3)
  String? synopsis;

  @HiveField(4)
  String? status;

  @HiveField(5)
  int? episodes;

  @HiveField(6)
  late List<String> genres;

  @HiveField(7)
  double? rating;

  @HiveField(8)
  late DateTime cachedAt;

  CachedAnimeDetailHive({
    required this.malId,
    required this.title,
    required this.imageUrl,
    this.synopsis,
    this.status,
    this.episodes,
    List<String>? genres,
    this.rating,
    DateTime? cachedAt,
  }) : genres = genres ?? [],
       cachedAt = cachedAt ?? DateTime.now();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CachedAnimeDetailHive &&
          runtimeType == other.runtimeType &&
          malId == other.malId;

  @override
  int get hashCode => malId.hashCode;
}
