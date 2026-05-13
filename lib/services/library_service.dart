import 'package:flutter/foundation.dart';
import '../models/library_model.dart';
import 'hive_service.dart';

class LibraryNotifier extends ChangeNotifier {
  final Map<String, LibraryCategory> _categories = {};
  bool _isInitialized = false;

  LibraryNotifier() {
    _initializeFromHive();
  }

  bool get isInitialized => _isInitialized;

  /// Initialize categories from Hive database
  Future<void> _initializeFromHive() async {
    try {
      // First ensure default category exists
      await HiveService.initializeDefaultCategories();

      // Load categories from Hive
      _categories.clear();

      // Load default favorit category
      _categories['favorit'] = LibraryCategory(
        id: 'favorit',
        name: 'Favorit',
        items: [],
      );

      // Load all library items and organize by category
      final allItems = HiveService.getAllLibraryItems();
      for (final hiveItem in allItems) {
        final categoryId = hiveItem.categoryId.toLowerCase();

        if (!_categories.containsKey(categoryId)) {
          _categories[categoryId] = LibraryCategory(
            id: categoryId,
            name: categoryId.replaceFirst(
              categoryId[0],
              categoryId[0].toUpperCase(),
            ),
            items: [],
          );
        }

        final item = LibraryItem(
          malId: hiveItem.malId,
          title: hiveItem.title,
          imageUrl: hiveItem.imageUrl,
          score: hiveItem.score,
          addedAt: hiveItem.addedAt,
        );

        _categories[categoryId]!.items.add(item);
      }

      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      print('Error initializing library from Hive: $e');
      _initializeDefaultCategory();
      _isInitialized = true;
    }
  }

  void _initializeDefaultCategory() {
    _categories['favorit'] = LibraryCategory(
      id: 'favorit',
      name: 'Favorit',
      items: [],
    );
  }

  /// Get all categories
  List<LibraryCategory> get categories => _categories.values.toList();

  /// Get category by id
  LibraryCategory? getCategoryById(String id) => _categories[id.toLowerCase()];

  /// Get default Favorit category
  LibraryCategory get favoritCategory =>
      _categories['favorit'] ?? LibraryCategory(id: 'favorit', name: 'Favorit');

  /// Check if anime is in a category
  bool isAnimeInCategory(int malId, String categoryId) {
    final category = getCategoryById(categoryId);
    return category?.items.any((item) => item.malId == malId) ?? false;
  }

  /// Check if anime is favorited
  bool isFavorite(int malId) => isAnimeInCategory(malId, 'favorit');

  /// Add anime to category (create category if not exists)
  Future<void> addAnimeToCategory({
    required int malId,
    required String title,
    required String imageUrl,
    double? score,
    required String categoryId,
  }) async {
    String catId = categoryId.toLowerCase();

    // Create category if doesn't exist
    if (!_categories.containsKey(catId)) {
      _categories[catId] = LibraryCategory(
        id: catId,
        name: categoryId,
        items: [],
      );
      // Persist new category to Hive
      await HiveService.addCategory(
        categoryId: catId,
        categoryName: categoryId,
      );
    }

    final category = _categories[catId]!;

    // Check if anime already exists
    if (category.items.any((item) => item.malId == malId)) {
      return;
    }

    // Add anime to category
    final newItem = LibraryItem(
      malId: malId,
      title: title,
      imageUrl: imageUrl,
      score: score,
    );

    category.items.add(newItem);

    // Persist to Hive
    await HiveService.addToLibrary(
      malId: malId,
      title: title,
      imageUrl: imageUrl,
      score: score,
      categoryId: catId,
    );

    notifyListeners();
  }

  /// Add anime to default Favorit category
  Future<void> addToFavorites({
    required int malId,
    required String title,
    required String imageUrl,
    double? score,
  }) async {
    await addAnimeToCategory(
      malId: malId,
      title: title,
      imageUrl: imageUrl,
      score: score,
      categoryId: 'Favorit',
    );
  }

  /// Remove anime from category
  Future<void> removeAnimeFromCategory(int malId, String categoryId) async {
    String catId = categoryId.toLowerCase();
    final category = _categories[catId];

    if (category == null) return;

    category.items.removeWhere((item) => item.malId == malId);

    // Persist removal to Hive
    await HiveService.removeFromLibrary(malId, catId);

    notifyListeners();
  }

  /// Remove anime from all categories
  Future<void> removeAnimeFromAllCategories(int malId) async {
    for (final categoryId in _categories.keys.toList()) {
      await removeAnimeFromCategory(malId, categoryId);
    }
  }

  /// Create new custom category
  Future<bool> createCategory(String name) async {
    String id = name.toLowerCase();

    if (_categories.containsKey(id)) {
      return false; // Category already exists
    }

    _categories[id] = LibraryCategory(id: id, name: name, items: []);

    // Persist new category to Hive
    await HiveService.addCategory(categoryId: id, categoryName: name);

    notifyListeners();
    return true;
  }

  /// Delete category
  Future<void> deleteCategory(String categoryId) async {
    String catId = categoryId.toLowerCase();

    // Don't allow deleting Favorit category
    if (catId == 'favorit') {
      return;
    }

    _categories.remove(catId);

    // Delete from Hive
    await HiveService.deleteCategory(catId);

    notifyListeners();
  }

  /// Get total favorite count
  int get favoriteCount => favoritCategory.items.length;

  /// Get total items across all categories
  int get totalItems {
    int total = 0;
    for (final category in _categories.values) {
      total += category.items.length;
    }
    return total;
  }

  /// Check if there are any custom categories (excluding Favorit)
  bool get hasCustomCategories {
    return _categories.values
        .where((cat) => cat.id.toLowerCase() != 'favorit')
        .isNotEmpty;
  }

  /// Clear all data
  Future<void> clearAll() async {
    _categories.clear();
    _initializeDefaultCategory();

    // Clear Hive data
    await HiveService.clearAllData();

    notifyListeners();
  }

  /// Get categories that contain this anime
  List<LibraryCategory> getCategoriesForAnime(int malId) {
    return _categories.values
        .where((cat) => cat.items.any((item) => item.malId == malId))
        .toList();
  }

  /// Check if anime exists in any category (other than just in library)
  bool animeExistsInLibrary(int malId) {
    return getCategoriesForAnime(malId).isNotEmpty;
  }

  /// Rename category
  Future<bool> renameCategory(String oldCategoryId, String newName) async {
    String oldId = oldCategoryId.toLowerCase();
    final category = _categories[oldId];

    if (category == null) return false;
    if (oldId == 'favorit') return false; // Can't rename Favorit

    String newId = newName.toLowerCase();
    if (_categories.containsKey(newId)) return false; // New name already exists

    final renamedCategory = category.copyWith(name: newName, id: newId);
    _categories.remove(oldId);
    _categories[newId] = renamedCategory;

    // Update in Hive
    await HiveService.deleteCategory(oldId);
    await HiveService.addCategory(categoryId: newId, categoryName: newName);

    // Migrate all items to new category
    final items = HiveService.getLibraryItemsByCategory(oldId);
    for (final item in items) {
      await HiveService.addToLibrary(
        malId: item.malId,
        title: item.title,
        imageUrl: item.imageUrl,
        score: item.score,
        categoryId: newId,
      );
    }

    notifyListeners();
    return true;
  }

  /// Move anime from one category to another
  Future<void> moveAnimeToCategory({
    required int malId,
    required String fromCategoryId,
    required String toCategoryId,
  }) async {
    // Get anime from source category
    String fromId = fromCategoryId.toLowerCase();
    final fromCategory = _categories[fromId];
    if (fromCategory == null) return;

    LibraryItem? animeItem;
    for (final item in fromCategory.items) {
      if (item.malId == malId) {
        animeItem = item;
        break;
      }
    }
    if (animeItem == null) return;

    // Remove from source
    await removeAnimeFromCategory(malId, fromCategoryId);

    // Add to destination
    await addAnimeToCategory(
      malId: animeItem.malId,
      title: animeItem.title,
      imageUrl: animeItem.imageUrl,
      score: animeItem.score,
      categoryId: toCategoryId,
    );
  }

  /// Reorder categories (maintain order in a list)
  void reorderCategories(List<LibraryCategory> newOrder) {
    final tempMap = <String, LibraryCategory>{};
    for (final cat in newOrder) {
      tempMap[cat.id] = cat;
    }
    // Add any missing categories (shouldn't happen)
    for (final entry in _categories.entries) {
      if (!tempMap.containsKey(entry.key)) {
        tempMap[entry.key] = entry.value;
      }
    }
    _categories.clear();
    _categories.addAll(tempMap);
    notifyListeners();
  }
}
