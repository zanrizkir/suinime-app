import 'package:flutter/foundation.dart';
import 'hive_service.dart';

/// Provider for managing search history
class SearchHistoryNotifier extends ChangeNotifier {
  List<String> _recentKeywords = [];

  SearchHistoryNotifier() {
    _loadHistory();
  }

  List<String> get recentKeywords => _recentKeywords;

  /// Load recent search keywords
  Future<void> _loadHistory() async {
    try {
      _recentKeywords = HiveService.getSearchKeywords(limit: 20);
      notifyListeners();
    } catch (e) {
      print('Error loading search history: $e');
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
}
