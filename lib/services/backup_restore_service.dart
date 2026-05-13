import 'dart:convert';
import 'dart:io';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import '../models/hive/library_item_hive.dart';
import '../models/hive/library_category_hive.dart';
import '../models/hive/continue_watching_hive.dart';
import '../models/hive/watch_history_hive.dart';
import '../models/hive/search_history_hive.dart';
import '../models/hive/cached_anime_detail_hive.dart';
import 'hive_service.dart';

class BackupRestoreService {
  static const String backupVersion = '1.0';
  static const String backupFileName = 'suinime_backup_';
  static const String backupFileExt = '.json';

  /// Create a complete Hive backup
  /// Returns path to created backup file
  static Future<String> createBackup(String backupLocation) async {
    try {
      final backupDir = Directory(backupLocation);

      // Ensure directory exists
      if (!await backupDir.exists()) {
        await backupDir.create(recursive: true);
      }

      // Collect all Hive data
      final backupData = {
        'version': backupVersion,
        'timestamp': DateTime.now().toIso8601String(),
        'backupName': 'Suinime Backup',
        'data': {
          'library_items': _serializeLibraryItems(),
          'library_categories': _serializeLibraryCategories(),
          'continue_watching': _serializeContinueWatching(),
          'watch_history': _serializeWatchHistory(),
          'search_history': _serializeSearchHistory(),
          'cached_details': _serializeCachedDetails(),
        },
      };

      // Create filename with timestamp
      final timestamp = DateFormat(
        'yyyy-MM-dd_HH-mm-ss',
      ).format(DateTime.now());
      final backupFileName = 'suinime_backup_$timestamp$backupFileExt';
      final backupFile = File('${backupDir.path}/$backupFileName');

      // Write backup file
      await backupFile.writeAsString(jsonEncode(backupData));

      return backupFile.path;
    } catch (e) {
      throw Exception('Failed to create backup: $e');
    }
  }

  /// Restore Hive data from backup file
  /// Validates backup integrity before restoration
  static Future<bool> restoreBackup(String backupFilePath) async {
    try {
      final backupFile = File(backupFilePath);

      // Check if file exists
      if (!await backupFile.exists()) {
        throw Exception('Backup file not found: $backupFilePath');
      }

      // Read and parse backup file
      final backupContent = await backupFile.readAsString();
      final backupData = jsonDecode(backupContent) as Map<String, dynamic>;

      // Validate backup version
      if (backupData['version'] != backupVersion) {
        throw Exception(
          'Backup version mismatch. Expected $backupVersion, got ${backupData['version']}',
        );
      }

      // Extract data
      final data = backupData['data'] as Map<String, dynamic>;

      // Restore data in order
      await _restoreLibraryItems(data['library_items']);
      await _restoreLibraryCategories(data['library_categories']);
      await _restoreContinueWatching(data['continue_watching']);
      await _restoreWatchHistory(data['watch_history']);
      await _restoreSearchHistory(data['search_history']);
      await _restoreCachedDetails(data['cached_details']);

      return true;
    } catch (e) {
      throw Exception('Failed to restore backup: $e');
    }
  }

  // ===== SERIALIZATION =====

  static List<Map<String, dynamic>> _serializeLibraryItems() {
    final box = Hive.box<LibraryItemHive>(HiveService.libraryBox);
    return box.values
        .map(
          (item) => {
            'malId': item.malId,
            'title': item.title,
            'imageUrl': item.imageUrl,
            'score': item.score,
            'categoryId': item.categoryId,
          },
        )
        .toList();
  }

  static List<Map<String, dynamic>> _serializeLibraryCategories() {
    final box = Hive.box<LibraryCategoryHive>(HiveService.libraryCategories);
    return box.values
        .map((item) => {'id': item.id, 'name': item.name})
        .toList();
  }

  static List<Map<String, dynamic>> _serializeContinueWatching() {
    final box = Hive.box<ContinueWatchingHive>(HiveService.continueWatchingBox);
    return box.values
        .map(
          (item) => {
            'malId': item.malId,
            'animeTitle': item.animeTitle,
            'imageUrl': item.imageUrl,
            'episodeNumber': item.episodeNumber,
            'position': item.position,
            'duration': item.duration,
            'updatedAt': item.updatedAt.toIso8601String(),
          },
        )
        .toList();
  }

  static List<Map<String, dynamic>> _serializeWatchHistory() {
    final box = Hive.box<WatchHistoryHive>(HiveService.watchHistoryBox);
    return box.values
        .map(
          (item) => {
            'malId': item.malId,
            'title': item.title,
            'imageUrl': item.imageUrl,
            'lastEpisode': item.lastEpisode,
            'watchedAt': item.watchedAt.toIso8601String(),
          },
        )
        .toList();
  }

  static List<Map<String, dynamic>> _serializeSearchHistory() {
    final box = Hive.box<SearchHistoryHive>(HiveService.searchHistoryBox);
    return box.values
        .map(
          (item) => {
            'keyword': item.keyword,
            'searchedAt': item.searchedAt.toIso8601String(),
          },
        )
        .toList();
  }

  static List<Map<String, dynamic>> _serializeCachedDetails() {
    final box = Hive.box<CachedAnimeDetailHive>(HiveService.cachedDetailBox);
    return box.values
        .map(
          (item) => {
            'malId': item.malId,
            'title': item.title,
            'imageUrl': item.imageUrl,
            'synopsis': item.synopsis,
            'status': item.status,
            'episodes': item.episodes,
            'genres': item.genres,
            'rating': item.rating,
            'cachedAt': item.cachedAt.toIso8601String(),
          },
        )
        .toList();
  }

  // ===== RESTORATION =====

  static Future<void> _restoreLibraryItems(List<dynamic>? items) async {
    if (items == null) return;

    final box = Hive.box<LibraryItemHive>(HiveService.libraryBox);
    await box.clear();

    for (final item in items) {
      final hiveItem = LibraryItemHive(
        malId: item['malId'] as int,
        title: item['title'] as String,
        imageUrl: item['imageUrl'] as String,
        score: item['score'] as double?,
        categoryId: item['categoryId'] as String,
      );
      await box.put('${item['malId']}_${item['categoryId']}', hiveItem);
    }
  }

  static Future<void> _restoreLibraryCategories(List<dynamic>? items) async {
    if (items == null) return;

    final box = Hive.box<LibraryCategoryHive>(HiveService.libraryCategories);
    await box.clear();

    for (final item in items) {
      final hiveItem = LibraryCategoryHive(
        id: item['id'] as String,
        name: item['name'] as String,
      );
      await box.put(item['id'] as String, hiveItem);
    }
  }

  static Future<void> _restoreContinueWatching(List<dynamic>? items) async {
    if (items == null) return;

    final box = Hive.box<ContinueWatchingHive>(HiveService.continueWatchingBox);
    await box.clear();

    for (final item in items) {
      final hiveItem = ContinueWatchingHive(
        malId: item['malId'] as int,
        animeTitle: item['animeTitle'] as String,
        imageUrl: item['imageUrl'] as String,
        episodeNumber: item['episodeNumber'] as int,
        position: item['position'] as int,
        duration: item['duration'] as int,
        updatedAt: DateTime.parse(item['updatedAt'] as String),
      );
      await box.put(item['malId'] as int, hiveItem);
    }
  }

  static Future<void> _restoreWatchHistory(List<dynamic>? items) async {
    if (items == null) return;

    final box = Hive.box<WatchHistoryHive>(HiveService.watchHistoryBox);
    await box.clear();

    for (final item in items) {
      final hiveItem = WatchHistoryHive(
        malId: item['malId'] as int,
        title: item['title'] as String,
        imageUrl: item['imageUrl'] as String,
        lastEpisode: item['lastEpisode'] as int,
        watchedAt: DateTime.parse(item['watchedAt'] as String),
      );
      await box.put(item['malId'] as int, hiveItem);
    }
  }

  static Future<void> _restoreSearchHistory(List<dynamic>? items) async {
    if (items == null) return;

    final box = Hive.box<SearchHistoryHive>(HiveService.searchHistoryBox);
    await box.clear();

    for (final item in items) {
      final hiveItem = SearchHistoryHive(
        keyword: item['keyword'] as String,
        searchedAt: DateTime.parse(item['searchedAt'] as String),
      );
      await box.add(hiveItem);
    }
  }

  static Future<void> _restoreCachedDetails(List<dynamic>? items) async {
    if (items == null) return;

    final box = Hive.box<CachedAnimeDetailHive>(HiveService.cachedDetailBox);
    await box.clear();

    for (final item in items) {
      final hiveItem = CachedAnimeDetailHive(
        malId: item['malId'] as int,
        title: item['title'] as String,
        imageUrl: item['imageUrl'] as String,
        synopsis: item['synopsis'] as String?,
        status: item['status'] as String?,
        episodes: item['episodes'] as int?,
        genres: item['genres'] != null
            ? List<String>.from(item['genres'] as List<dynamic>)
            : null,
        rating: item['rating'] as double?,
        cachedAt: DateTime.parse(item['cachedAt'] as String),
      );
      await box.put(item['malId'] as int, hiveItem);
    }
  }

  /// Get list of backup files in a directory
  static Future<List<FileSystemEntity>> getBackupFiles(
    String backupLocation,
  ) async {
    try {
      final backupDir = Directory(backupLocation);
      if (!await backupDir.exists()) {
        return [];
      }

      final files = await backupDir.list().toList();
      return files
          .where(
            (file) =>
                file.path.endsWith(backupFileExt) &&
                file.path.contains(backupFileName),
          )
          .toList()
        ..sort(
          (a, b) => b.statSync().modified.compareTo(a.statSync().modified),
        );
    } catch (e) {
      throw Exception('Failed to get backup files: $e');
    }
  }

  /// Get backup file info
  static Map<String, dynamic> getBackupFileInfo(String filePath) {
    final file = File(filePath);
    final stat = file.statSync();
    final name = file.path.split('/').last;

    return {
      'name': name,
      'path': filePath,
      'size': _formatBytes(stat.size),
      'sizeBytes': stat.size,
      'modified': stat.modified,
      'modifiedFormatted': DateFormat(
        'dd MMM yyyy - HH:mm',
      ).format(stat.modified),
    };
  }

  static String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
