import 'package:hive/hive.dart';

part 'watch_history_hive.g.dart';

@HiveType(typeId: 2)
class WatchHistoryHive extends HiveObject {
  @HiveField(0)
  late int malId;

  @HiveField(1)
  late String title;

  @HiveField(2)
  late String imageUrl;

  @HiveField(3)
  int lastEpisode;

  @HiveField(4)
  late DateTime watchedAt;

  WatchHistoryHive({
    required this.malId,
    required this.title,
    required this.imageUrl,
    this.lastEpisode = 0,
    DateTime? watchedAt,
  }) : watchedAt = watchedAt ?? DateTime.now();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WatchHistoryHive &&
          runtimeType == other.runtimeType &&
          malId == other.malId;

  @override
  int get hashCode => malId.hashCode;
}
