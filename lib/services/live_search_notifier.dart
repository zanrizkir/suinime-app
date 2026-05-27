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
  int _currentPage = 1;
  int _totalPages = 1;
  bool _hasNextPage = false;
  Timer? _debounceTimer;

  // To cancel outdated requests
  int _requestCounter = 0;
  int _lastCompletedRequest = 0;

  LiveSearchNotifier();

  List<AnimeModel> get searchResults => _searchResults;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get currentQuery => _currentQuery;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  bool get hasNextPage => _hasNextPage;

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
      _currentPage = 1;
      _totalPages = 1;
      _hasNextPage = false;
      notifyListeners();
      return;
    }

    // Set loading state
    _isLoading = true;
    _errorMessage = null;
    _currentPage = 1;
    _totalPages = 1;
    _hasNextPage = false;
    notifyListeners();

    // Debounce the search
    _debounceTimer = Timer(Duration(milliseconds: debounceMs), () {
      _performSearch(_currentQuery, page: 1);
    });
  }

  /// Execute the API search
  Future<void> _performSearch(String query, {required int page}) async {
    // Track request order
    _requestCounter++;
    final currentRequest = _requestCounter;

    try {
      final results = await _apiService.searchAnimePaginated(query, page: page);

      // Ignore outdated responses
      if (currentRequest < _lastCompletedRequest) {
        return;
      }

      _lastCompletedRequest = currentRequest;
      _searchResults = ApiService.deduplicateAnimeList(results.anime);
      _currentPage = results.currentPage;
      _totalPages = results.totalPages;
      _hasNextPage = results.hasNextPage;
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
      _totalPages = _currentPage;
      _hasNextPage = false;
      _isLoading = false;
      notifyListeners();
    }
  }

  void nextPage() {
    if (_currentQuery.isEmpty ||
        (!_hasNextPage && _currentPage >= _totalPages)) {
      return;
    }
    _goToPage(_currentPage + 1);
  }

  void previousPage() {
    if (_currentPage <= 1) return;
    _goToPage(_currentPage - 1);
  }

  void goToPage(int page) {
    final targetPage = page < 1 ? 1 : (page > _totalPages ? _totalPages : page);
    if (targetPage == _currentPage) return;
    _goToPage(targetPage);
  }

  void _goToPage(int page) {
    _debounceTimer?.cancel();
    _currentPage = page;
    _searchResults = [];
    _errorMessage = null;
    _isLoading = true;
    notifyListeners();
    _performSearch(_currentQuery, page: page);
  }

  /// Clear search and results
  void clearSearch() {
    _debounceTimer?.cancel();
    _currentQuery = '';
    _searchResults = [];
    _errorMessage = null;
    _isLoading = false;
    _currentPage = 1;
    _totalPages = 1;
    _hasNextPage = false;
    _requestCounter = 0;
    _lastCompletedRequest = 0;
    notifyListeners();
  }

  /// Retry search (for error state)
  void retrySearch() {
    if (_currentQuery.isNotEmpty) {
      _performSearch(_currentQuery, page: _currentPage);
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}
