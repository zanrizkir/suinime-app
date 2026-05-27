import 'package:flutter/foundation.dart';
import '../models/anime_model.dart';
import 'hive_service.dart';

class SearchAnimeHistoryEntry {
  final int animeId;
  final String title;
  final String imageUrl;
  final String? metadata;
  final DateTime searchedAt;

  const SearchAnimeHistoryEntry({
    required this.animeId,
    required this.title,
    required this.imageUrl,
    required this.searchedAt,
    this.metadata,
  });
}

/// Provider for managing search history
class SearchHistoryNotifier extends ChangeNotifier {
  List<String> _recentKeywords = [];
  List<SearchAnimeHistoryEntry> _recentAnime = [];

  SearchHistoryNotifier() {
    _loadHistory();
  }

  List<String> get recentKeywords => _recentKeywords;
  List<SearchAnimeHistoryEntry> get recentAnime => _recentAnime;
  bool get hasAnyHistory =>
      _recentKeywords.isNotEmpty || _recentAnime.isNotEmpty;

  /// Load recent search keywords
  Future<void> _loadHistory() async {
    try {
      _recentKeywords = HiveService.getSearchKeywords(limit: 20);
      _recentAnime = HiveService.getSearchAnimeHistory(limit: 20)
          .map(
            (item) => SearchAnimeHistoryEntry(
              animeId: item.animeId!,
              title: item.animeTitle ?? 'Unknown Title',
              imageUrl: item.animeImageUrl ?? '',
              metadata: item.animeMetadata,
              searchedAt: item.searchedAt,
            ),
          )
          .toList();
      notifyListeners();
    } catch (e) {
      print('Error loading search history: $e');
    }
  }

  Future<void> addSearchAnime(AnimeModel anime) async {
    try {
      await HiveService.addSearchAnimeHistory(
        animeId: anime.malId,
        title: anime.title,
        imageUrl: anime.imageUrl,
        metadata: _metadataFor(anime),
      );
      await _loadHistory();
    } catch (e) {
      print('Error adding search anime history: $e');
    }
  }

  /// Add search keyword to history
  Future<void> addSearchKeyword(String keyword) async {
    if (keyword.trim().isEmpty) return;

    try {
      await HiveService.addSearchKeyword(keyword);
      await _loadHistory();
    } catch (e) {
      print('Error adding search keyword: $e');
    }
  }

  /// Remove specific keyword from history
  Future<void> removeKeyword(String keyword) async {
    try {
      await HiveService.removeSearchKeyword(keyword);
      await _loadHistory();
    } catch (e) {
      print('Error removing search keyword: $e');
    }
  }

  /// Clear all search history
  Future<void> clearHistory() async {
    try {
      await HiveService.clearSearchHistory();
      _recentKeywords.clear();
      _recentAnime.clear();
      notifyListeners();
    } catch (e) {
      print('Error clearing search history: $e');
    }
  }

  /// Get search suggestions (recent unique keywords)
  List<String> getSuggestions(String query) {
    if (query.isEmpty) {
      return _recentKeywords;
    }

    return _recentKeywords
        .where((keyword) => keyword.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  String? _metadataFor(AnimeModel anime) {
    final parts = [
      if (anime.type != null && anime.type!.isNotEmpty) anime.type!,
      if (anime.episodes != null) '${anime.episodes} eps',
      if (anime.year != null) anime.year.toString(),
    ];
    return parts.isEmpty ? null : parts.join(' / ');
  }
}
