class LibraryCategory {
  final String id;
  final String name;
  final List<LibraryItem> items;

  LibraryCategory({
    required this.id,
    required this.name,
    this.items = const [],
  });

  LibraryCategory copyWith({
    String? id,
    String? name,
    List<LibraryItem>? items,
  }) {
    return LibraryCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      items: items ?? this.items,
    );
  }
}

class LibraryItem {
  final int malId;
  final String title;
  final String imageUrl;
  final double? score;
  final DateTime addedAt;

  LibraryItem({
    required this.malId,
    required this.title,
    required this.imageUrl,
    this.score,
    DateTime? addedAt,
  }) : addedAt = addedAt ?? DateTime.now();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LibraryItem &&
          runtimeType == other.runtimeType &&
          malId == other.malId;

  @override
  int get hashCode => malId.hashCode;
}
