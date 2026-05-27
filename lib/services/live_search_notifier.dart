import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/anime_model.dart';
import 'api_service.dart';

/// Manages real-time live search with debounce and request cancellation
class LiveSearchNotifier extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<AnimeModel> _searchResults = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _currentQuery = '';
  Timer? _debounceTimer;

  // To cancel outdated requests
  int _requestCounter = 0;
  int _lastCompletedRequest = 0;

  LiveSearchNotifier();

  List<AnimeModel> get searchResults => _searchResults;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get currentQuery => _currentQuery;

  /// Start live search with debounce
  void onSearchQueryChanged(String query, {int debounceMs = 400}) {
    _currentQuery = query.trim();

    // Cancel previous timer
    _debounceTimer?.cancel();

    // If query is empty, clear results and notify
    if (_currentQuery.isEmpty) {
      _searchResults = [];
      _errorMessage = null;
      _isLoading = false;
      notifyListeners();
      return;
    }

    // Set loading state
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    // Debounce the search
    _debounceTimer = Timer(Duration(milliseconds: debounceMs), () {
      _performSearch(_currentQuery);
    });
  }

  /// Execute the API search
  Future<void> _performSearch(String query) async {
    // Track request order
    _requestCounter++;
    final currentRequest = _requestCounter;

    try {
      final results = await _apiService.searchAnime(query);

      // Ignore outdated responses
      if (currentRequest < _lastCompletedRequest) {
        return;
      }

      _lastCompletedRequest = currentRequest;
      _searchResults = ApiService.deduplicateAnimeList(results);
      _errorMessage = null;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      // Ignore outdated responses
      if (currentRequest < _lastCompletedRequest) {
        return;
      }

      _lastCompletedRequest = currentRequest;
      _errorMessage = e.toString();
      _searchResults = [];
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clear search and results
  void clearSearch() {
    _debounceTimer?.cancel();
    _currentQuery = '';
    _searchResults = [];
    _errorMessage = null;
    _isLoading = false;
    _requestCounter = 0;
    _lastCompletedRequest = 0;
    notifyListeners();
  }

  /// Retry search (for error state)
  void retrySearch() {
    if (_currentQuery.isNotEmpty) {
      _performSearch(_currentQuery);
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}
