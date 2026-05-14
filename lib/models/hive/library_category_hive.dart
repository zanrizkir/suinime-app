import 'package:hive/hive.dart';

part 'library_category_hive.g.dart';

@HiveType(typeId: 5)
class LibraryCategoryHive extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String name;

  @HiveField(2)
  late DateTime createdAt;

  LibraryCategoryHive({
    required this.id,
    required this.name,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LibraryCategoryHive &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
