import 'package:flutter/foundation.dart';
import '../models/library_model.dart';

class LibraryNotifier extends ChangeNotifier {
  final Map<String, LibraryCategory> _categories = {};

  LibraryNotifier() {
    _initializeDefaultCategory();
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
  void addAnimeToCategory({
    required int malId,
    required String title,
    required String imageUrl,
    double? score,
    required String categoryId,
  }) {
    String catId = categoryId.toLowerCase();

    // Create category if doesn't exist
    if (!_categories.containsKey(catId)) {
      _categories[catId] = LibraryCategory(
        id: catId,
        name: categoryId,
        items: [],
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

    final updatedItems = [...category.items, newItem];
    _categories[catId] = category.copyWith(items: updatedItems);

    notifyListeners();
  }

  /// Add anime to default Favorit category
  void addToFavorites({
    required int malId,
    required String title,
    required String imageUrl,
    double? score,
  }) {
    addAnimeToCategory(
      malId: malId,
      title: title,
      imageUrl: imageUrl,
      score: score,
      categoryId: 'Favorit',
    );
  }

  /// Remove anime from category
  void removeAnimeFromCategory(int malId, String categoryId) {
    String catId = categoryId.toLowerCase();
    final category = _categories[catId];

    if (category == null) return;

    final updatedItems = category.items
        .where((item) => item.malId != malId)
        .toList();

    _categories[catId] = category.copyWith(items: updatedItems);

    notifyListeners();
  }

  /// Remove anime from all categories
  void removeAnimeFromAllCategories(int malId) {
    for (final categoryId in _categories.keys.toList()) {
      removeAnimeFromCategory(malId, categoryId);
    }
  }

  /// Create new custom category
  bool createCategory(String name) {
    String id = name.toLowerCase();

    if (_categories.containsKey(id)) {
      return false; // Category already exists
    }

    _categories[id] = LibraryCategory(id: id, name: name, items: []);

    notifyListeners();
    return true;
  }

  /// Delete category
  void deleteCategory(String categoryId) {
    String catId = categoryId.toLowerCase();

    // Don't allow deleting Favorit category
    if (catId == 'favorit') {
      return;
    }

    _categories.remove(catId);
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
  void clearAll() {
    _categories.clear();
    _initializeDefaultCategory();
    notifyListeners();
  }
}
