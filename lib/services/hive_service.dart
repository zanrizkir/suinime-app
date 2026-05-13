import 'package:hive_flutter/hive_flutter.dart';
import '../models/hive/library_item_hive.dart';
import '../models/hive/continue_watching_hive.dart';
import '../models/hive/watch_history_hive.dart';
import '../models/hive/search_history_hive.dart';
import '../models/hive/cached_anime_detail_hive.dart';
import '../models/hive/library_category_hive.dart';

class HiveService {
  static const String libraryBox = 'library_items';
  static const String libraryCategories = 'library_categories';
  static const String continueWatchingBox = 'continue_watching';
  static const String watchHistoryBox = 'watch_history';
  static const String searchHistoryBox = 'search_history';
  static const String cachedDetailBox = 'cached_anime_details';

  // Initialize Hive and register adapters
  static Future<void> initHive() async {
    await Hive.initFlutter();

    // Register adapters
    Hive.registerAdapter(LibraryItemHiveAdapter());
    Hive.registerAdapter(LibraryCategoryHiveAdapter());
    Hive.registerAdapter(ContinueWatchingHiveAdapter());
    Hive.registerAdapter(WatchHistoryHiveAdapter());
    Hive.registerAdapter(SearchHistoryHiveAdapter());
    Hive.registerAdapter(CachedAnimeDetailHiveAdapter());

    // Open boxes
    await Hive.openBox<LibraryItemHive>(libraryBox);
    await Hive.openBox<LibraryCategoryHive>(libraryCategories);
    await Hive.openBox<ContinueWatchingHive>(continueWatchingBox);
    await Hive.openBox<WatchHistoryHive>(watchHistoryBox);
    await Hive.openBox<SearchHistoryHive>(searchHistoryBox);
    await Hive.openBox<CachedAnimeDetailHive>(cachedDetailBox);
  }

  // ===== LIBRARY ITEMS =====

  /// Get library items for a specific category
  static List<LibraryItemHive> getLibraryItemsByCategory(String categoryId) {
    final box = Hive.box<LibraryItemHive>(libraryBox);
    return box.values
        .where(
          (item) => item.categoryId.toLowerCase() == categoryId.toLowerCase(),
        )
        .toList();
  }

  /// Get all library items
  static List<LibraryItemHive> getAllLibraryItems() {
    final box = Hive.box<LibraryItemHive>(libraryBox);
    return box.values.toList();
  }

  /// Check if anime is in library
  static bool isAnimeInLibrary(int malId, String categoryId) {
    final box = Hive.box<LibraryItemHive>(libraryBox);
    return box.values.any(
      (item) =>
          item.malId == malId &&
          item.categoryId.toLowerCase() == categoryId.toLowerCase(),
    );
  }

  /// Add anime to library
  static Future<void> addToLibrary({
    required int malId,
    required String title,
    required String imageUrl,
    double? score,
    required String categoryId,
  }) async {
    final box = Hive.box<LibraryItemHive>(libraryBox);

    // Check for duplicates
    final exists = box.values.any(
      (item) =>
          item.malId == malId &&
          item.categoryId.toLowerCase() == categoryId.toLowerCase(),
    );

    if (exists) return;

    final item = LibraryItemHive(
      malId: malId,
      title: title,
      imageUrl: imageUrl,
      score: score,
      categoryId: categoryId.toLowerCase(),
    );

    // Use malId as key for easy access
    await box.put('${malId}_$categoryId', item);
  }

  /// Remove anime from library
  static Future<void> removeFromLibrary(int malId, String categoryId) async {
    final box = Hive.box<LibraryItemHive>(libraryBox);
    await box.delete('${malId}_$categoryId');
  }

  /// Update anime in library
  static Future<void> updateLibraryItem({
    required int malId,
    required String categoryId,
    required String title,
    required String imageUrl,
    double? score,
  }) async {
    final box = Hive.box<LibraryItemHive>(libraryBox);
    final key = '${malId}_$categoryId';

    if (box.containsKey(key)) {
      final item = box.get(key)!;
      item.title = title;
      item.imageUrl = imageUrl;
      item.score = score;
      await item.save();
    }
  }

  /// Clear all items from a category
  static Future<void> clearCategory(String categoryId) async {
    final box = Hive.box<LibraryItemHive>(libraryBox);
    final keysToDelete = box.keys
        .where(
          (key) =>
              box.get(key)?.categoryId.toLowerCase() ==
              categoryId.toLowerCase(),
        )
        .toList();

    for (var key in keysToDelete) {
      await box.delete(key);
    }
  }

  // ===== LIBRARY CATEGORIES =====

  /// Get all library categories
  static List<LibraryCategoryHive> getAllCategories() {
    final box = Hive.box<LibraryCategoryHive>(libraryCategories);
    return box.values.toList();
  }

  /// Get category by id
  static LibraryCategoryHive? getCategoryById(String categoryId) {
    final box = Hive.box<LibraryCategoryHive>(libraryCategories);
    return box.get(categoryId.toLowerCase());
  }

  /// Add new category
  static Future<void> addCategory({
    required String categoryId,
    required String categoryName,
  }) async {
    final box = Hive.box<LibraryCategoryHive>(libraryCategories);

    final category = LibraryCategoryHive(
      id: categoryId.toLowerCase(),
      name: categoryName,
    );

    await box.put(categoryId.toLowerCase(), category);
  }

  /// Delete category
  static Future<void> deleteCategory(String categoryId) async {
    final box = Hive.box<LibraryCategoryHive>(libraryCategories);
    await box.delete(categoryId.toLowerCase());
    await clearCategory(categoryId);
  }

  /// Initialize default categories
  static Future<void> initializeDefaultCategories() async {
    final box = Hive.box<LibraryCategoryHive>(libraryCategories);

    if (box.isEmpty) {
      await addCategory(categoryId: 'favorit', categoryName: 'Favorit');
    }
  }

  // ===== CONTINUE WATCHING =====

  /// Get continue watching item
  static ContinueWatchingHive? getContinueWatching(int malId) {
    final box = Hive.box<ContinueWatchingHive>(continueWatchingBox);
    return box.get(malId);
  }

  /// Get all continue watching
  static List<ContinueWatchingHive> getAllContinueWatching() {
    final box = Hive.box<ContinueWatchingHive>(continueWatchingBox);
    return box.values.toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  /// Save or update continue watching
  static Future<void> saveContinueWatching({
    required int malId,
    required String animeTitle,
    required String imageUrl,
    required int episodeNumber,
    required int position,
    required int duration,
  }) async {
    final box = Hive.box<ContinueWatchingHive>(continueWatchingBox);

    final item = ContinueWatchingHive(
      malId: malId,
      animeTitle: animeTitle,
      imageUrl: imageUrl,
      episodeNumber: episodeNumber,
      position: position,
      duration: duration,
      updatedAt: DateTime.now(),
    );

    await box.put(malId, item);
  }

  /// Remove continue watching
  static Future<void> removeContinueWatching(int malId) async {
    final box = Hive.box<ContinueWatchingHive>(continueWatchingBox);
    await box.delete(malId);
  }

  /// Clear all continue watching
  static Future<void> clearAllContinueWatching() async {
    final box = Hive.box<ContinueWatchingHive>(continueWatchingBox);
    await box.clear();
  }

  // ===== WATCH HISTORY =====

  /// Get watch history
  static List<WatchHistoryHive> getWatchHistory({int limit = 50}) {
    final box = Hive.box<WatchHistoryHive>(watchHistoryBox);
    final items = box.values.toList()
      ..sort((a, b) => b.watchedAt.compareTo(a.watchedAt));
    return items.length > limit ? items.sublist(0, limit) : items;
  }

  /// Check if anime in history
  static bool isInWatchHistory(int malId) {
    final box = Hive.box<WatchHistoryHive>(watchHistoryBox);
    return box.containsKey(malId);
  }

  /// Add to watch history
  static Future<void> addToWatchHistory({
    required int malId,
    required String title,
    required String imageUrl,
    int lastEpisode = 0,
  }) async {
    final box = Hive.box<WatchHistoryHive>(watchHistoryBox);

    final item = WatchHistoryHive(
      malId: malId,
      title: title,
      imageUrl: imageUrl,
      lastEpisode: lastEpisode,
      watchedAt: DateTime.now(),
    );

    await box.put(malId, item);
  }

  /// Update watch history last episode
  static Future<void> updateWatchHistoryEpisode(
    int malId,
    int lastEpisode,
  ) async {
    final box = Hive.box<WatchHistoryHive>(watchHistoryBox);

    if (box.containsKey(malId)) {
      final item = box.get(malId)!;
      item.lastEpisode = lastEpisode;
      item.watchedAt = DateTime.now();
      await item.save();
    }
  }

  /// Remove from watch history
  static Future<void> removeFromWatchHistory(int malId) async {
    final box = Hive.box<WatchHistoryHive>(watchHistoryBox);
    await box.delete(malId);
  }

  /// Clear watch history
  static Future<void> clearWatchHistory() async {
    final box = Hive.box<WatchHistoryHive>(watchHistoryBox);
    await box.clear();
  }

  // ===== SEARCH HISTORY =====

  /// Get search history
  static List<SearchHistoryHive> getSearchHistory({int limit = 20}) {
    final box = Hive.box<SearchHistoryHive>(searchHistoryBox);
    final items = box.values.toList()
      ..sort((a, b) => b.searchedAt.compareTo(a.searchedAt));
    return items.length > limit ? items.sublist(0, limit) : items;
  }

  /// Get unique search keywords
  static List<String> getSearchKeywords({int limit = 20}) {
    final history = getSearchHistory(limit: limit * 2);
    final seen = <String>{};
    return history
        .map((item) => item.keyword)
        .where((keyword) => seen.add(keyword))
        .take(limit)
        .toList();
  }

  /// Add search keyword
  static Future<void> addSearchKeyword(String keyword) async {
    final box = Hive.box<SearchHistoryHive>(searchHistoryBox);

    final item = SearchHistoryHive(
      keyword: keyword.trim(),
      searchedAt: DateTime.now(),
    );

    await box.add(item);
  }

  /// Remove search keyword
  static Future<void> removeSearchKeyword(String keyword) async {
    final box = Hive.box<SearchHistoryHive>(searchHistoryBox);
    final keysToDelete = box.keys
        .where((key) => box.get(key)?.keyword == keyword)
        .toList();

    for (var key in keysToDelete) {
      await box.delete(key);
    }
  }

  /// Clear search history
  static Future<void> clearSearchHistory() async {
    final box = Hive.box<SearchHistoryHive>(searchHistoryBox);
    await box.clear();
  }

  // ===== CACHED ANIME DETAILS =====

  /// Get cached detail
  static CachedAnimeDetailHive? getCachedDetail(int malId) {
    final box = Hive.box<CachedAnimeDetailHive>(cachedDetailBox);
    return box.get(malId);
  }

  /// Check if detail is cached and not expired
  static bool isCachedDetailValid(
    int malId, {
    Duration cacheDuration = const Duration(days: 7),
  }) {
    final cached = getCachedDetail(malId);
    if (cached == null) return false;

    final now = DateTime.now();
    final diff = now.difference(cached.cachedAt);
    return diff < cacheDuration;
  }

  /// Cache anime detail
  static Future<void> cacheAnimeDetail({
    required int malId,
    required String title,
    required String imageUrl,
    String? synopsis,
    String? status,
    int? episodes,
    List<String>? genres,
    double? rating,
  }) async {
    final box = Hive.box<CachedAnimeDetailHive>(cachedDetailBox);

    final item = CachedAnimeDetailHive(
      malId: malId,
      title: title,
      imageUrl: imageUrl,
      synopsis: synopsis,
      status: status,
      episodes: episodes,
      genres: genres,
      rating: rating,
      cachedAt: DateTime.now(),
    );

    await box.put(malId, item);
  }

  /// Remove cached detail
  static Future<void> removeCachedDetail(int malId) async {
    final box = Hive.box<CachedAnimeDetailHive>(cachedDetailBox);
    await box.delete(malId);
  }

  /// Clear cache
  static Future<void> clearCache() async {
    final box = Hive.box<CachedAnimeDetailHive>(cachedDetailBox);
    await box.clear();
  }

  // ===== GENERAL =====

  /// Clear all data
  static Future<void> clearAllData() async {
    await clearAllContinueWatching();
    await clearWatchHistory();
    await clearSearchHistory();
    await clearCache();
    await clearCategory('favorit');
  }

  /// Get database stats
  static Map<String, int> getStats() {
    return {
      'library_items': Hive.box<LibraryItemHive>(libraryBox).length,
      'categories': Hive.box<LibraryCategoryHive>(libraryCategories).length,
      'continue_watching': Hive.box<ContinueWatchingHive>(
        continueWatchingBox,
      ).length,
      'watch_history': Hive.box<WatchHistoryHive>(watchHistoryBox).length,
      'search_history': Hive.box<SearchHistoryHive>(searchHistoryBox).length,
      'cached_details': Hive.box<CachedAnimeDetailHive>(cachedDetailBox).length,
    };
  }
}
