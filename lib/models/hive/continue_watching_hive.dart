import 'package:hive/hive.dart';

part 'continue_watching_hive.g.dart';

@HiveType(typeId: 1)
class ContinueWatchingHive extends HiveObject {
  @HiveField(0)
  late int malId;

  @HiveField(1)
  late String animeTitle;

  @HiveField(2)
  late String imageUrl;

  @HiveField(3)
  late int episodeNumber;

  @HiveField(4)
  late int position; // in milliseconds

  @HiveField(5)
  late int duration; // in milliseconds

  @HiveField(6)
  late DateTime updatedAt;

  ContinueWatchingHive({
    required this.malId,
    required this.animeTitle,
    required this.imageUrl,
    required this.episodeNumber,
    required this.position,
    required this.duration,
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime.now();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContinueWatchingHive &&
          runtimeType == other.runtimeType &&
          malId == other.malId;

  @override
  int get hashCode => malId.hashCode;
}
