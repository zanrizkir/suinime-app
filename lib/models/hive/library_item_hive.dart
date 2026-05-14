import 'package:hive/hive.dart';

part 'library_item_hive.g.dart';

@HiveType(typeId: 0)
class LibraryItemHive extends HiveObject {
  @HiveField(0)
  late int malId;

  @HiveField(1)
  late String title;

  @HiveField(2)
  late String imageUrl;

  @HiveField(3)
  double? score;

  @HiveField(4)
  late String categoryId;

  @HiveField(5)
  late DateTime addedAt;

  LibraryItemHive({
    required this.malId,
    required this.title,
    required this.imageUrl,
    this.score,
    required this.categoryId,
    DateTime? addedAt,
  }) : addedAt = addedAt ?? DateTime.now();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LibraryItemHive &&
          runtimeType == other.runtimeType &&
          malId == other.malId &&
          categoryId == other.categoryId;

  @override
  int get hashCode => malId.hashCode ^ categoryId.hashCode;
}
