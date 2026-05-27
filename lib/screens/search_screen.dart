import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme/app_theme.dart';
import '../models/anime_model.dart';
import '../services/live_search_notifier.dart';
import '../services/search_history_notifier.dart';
import '../utils/responsive.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import 'detail_screen.dart';
import 'home/widgets/anime_card.dart';
import 'home/widgets/pagination_controls.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  Timer? _keywordSaveTimer;
  bool _hasInteracted = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _searchFocusNode.requestFocus();
      }
    });
  }

  void _onSearchChanged() {
    final notifier = context.read<LiveSearchNotifier>();
    final query = _searchController.text;
    notifier.onSearchQueryChanged(query, debounceMs: 400);
    _scheduleKeywordSave(query);

    if (!_hasInteracted && _searchController.text.isNotEmpty) {
      setState(() => _hasInteracted = true);
    }
    if (_searchController.text.isEmpty) {
      setState(() => _hasInteracted = false);
    }
  }

  void _scheduleKeywordSave(String query) {
    _keywordSaveTimer?.cancel();
    final keyword = query.trim();
    if (keyword.length < 2) return;

    _keywordSaveTimer = Timer(const Duration(milliseconds: 1200), () {
      if (!mounted || _searchController.text.trim() != keyword) return;
      context.read<SearchHistoryNotifier>().addSearchKeyword(keyword);
    });
  }

  void _saveCurrentKeywordNow() {
    _keywordSaveTimer?.cancel();
    final keyword = _searchController.text.trim();
    if (keyword.length >= 2) {
      context.read<SearchHistoryNotifier>().addSearchKeyword(keyword);
    }
  }

  @override
  void dispose() {
    _keywordSaveTimer?.cancel();
    _searchFocusNode.dispose();
    _searchController.dispose();
    context.read<LiveSearchNotifier>().clearSearch();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      appBar: AppBar(
        title: CustomTextField(
          controller: _searchController,
          focusNode: _searchFocusNode,
          autofocus: true,
          hintText: 'Cari anime favoritmu...',
          prefixIcon: Icons.search_rounded,
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.search,
          onSubmitted: (_) => _saveCurrentKeywordNow(),
        ),
        backgroundColor: AppColors.darkSurface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer2<LiveSearchNotifier, SearchHistoryNotifier>(
        builder: (context, liveSearch, searchHistory, _) {
          return _buildBody(liveSearch, searchHistory);
        },
      ),
    );
  }

  Widget _buildBody(
    LiveSearchNotifier liveSearch,
    SearchHistoryNotifier searchHistory,
  ) {
    // Show initial state when user hasn't typed yet
    if (!_hasInteracted) {
      return _buildInitialState(searchHistory);
    }

    // Show empty query state (user cleared the search)
    if (liveSearch.currentQuery.isEmpty) {
      return _buildInitialState(searchHistory);
    }

    // Show loading state
    if (liveSearch.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    // Show error state
    if (liveSearch.errorMessage != null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(Responsive.paddingLarge(context)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                color: AppColors.error,
                size: Responsive.iconSizeXLarge(context),
              ),
              SizedBox(height: Responsive.spacingLarge(context)),
              Text(
                liveSearch.errorMessage!,
                style: const TextStyle(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: Responsive.spacingLarge(context)),
              CustomButton(
                text: 'Coba Lagi',
                onPressed: () => liveSearch.retrySearch(),
              ),
            ],
          ),
        ),
      );
    }

    // Show empty results
    if (liveSearch.searchResults.isEmpty) {
      return const Center(
        child: Text(
          'Tidak ada anime ditemukan',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    // Show search results
    return _buildSearchResults(liveSearch);
  }

  Widget _buildInitialState(SearchHistoryNotifier searchHistory) {
    final recentKeywords = searchHistory.recentKeywords;

    return SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: EdgeInsets.fromLTRB(
        Responsive.paddingLarge(context),
        Responsive.paddingMedium(context),
        Responsive.paddingLarge(context),
        Responsive.safeBottomSpacing(context, minimum: 24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (recentKeywords.isNotEmpty) ...[
            _buildSectionTitle('Pencarian Terakhir'),
            SizedBox(height: Responsive.spacingMedium(context)),
            Wrap(
              spacing: Responsive.spacingSmall(context),
              runSpacing: Responsive.spacingSmall(context),
              children: recentKeywords.map((keyword) {
                return GestureDetector(
                  onTap: () {
                    _searchController.text = keyword;
                    _searchController.selection = TextSelection.collapsed(
                      offset: keyword.length,
                    );
                    _searchFocusNode.requestFocus();
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: Responsive.paddingMedium(context),
                      vertical: Responsive.paddingSmall(context),
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.darkSurface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      keyword,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: Responsive.fontSizeSmall(context),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
          if (searchHistory.recentAnime.isNotEmpty) ...[
            if (recentKeywords.isNotEmpty)
              SizedBox(height: Responsive.spacingXLarge(context)),
            _buildSectionTitle('Baru Dibuka dari Pencarian'),
            SizedBox(height: Responsive.spacingMedium(context)),
            ...searchHistory.recentAnime.map(_buildRecentAnimeTile),
          ],
          if (!searchHistory.hasAnyHistory)
            SizedBox(
              height: MediaQuery.sizeOf(context).height * 0.55,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.search,
                      size: Responsive.iconSizeXLarge(context),
                      color: AppColors.textTertiary,
                    ),
                    SizedBox(height: Responsive.spacingLarge(context)),
                    Text(
                      'Cari anime favoritmu',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: Responsive.fontSizeLarge(context),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w700,
        fontSize: Responsive.fontSizeMedium(context),
      ),
    );
  }

  Widget _buildRecentAnimeTile(SearchAnimeHistoryEntry item) {
    return Padding(
      padding: EdgeInsets.only(bottom: Responsive.spacingMedium(context)),
      child: Material(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => _openHistoryDetail(item),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.network(
                    item.imageUrl,
                    width: 48,
                    height: 64,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      width: 48,
                      height: 64,
                      color: AppColors.darkBg,
                      child: const Icon(
                        Icons.broken_image,
                        color: AppColors.textTertiary,
                        size: 20,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        item.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: Responsive.fontSizeMedium(context),
                        ),
                      ),
                      if (item.metadata != null &&
                          item.metadata!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          item.metadata!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: Responsive.fontSizeSmall(context),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textTertiary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResults(LiveSearchNotifier liveSearch) {
    final results = liveSearch.searchResults;

    return SingleChildScrollView(
      child: Column(
        children: [
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.all(Responsive.paddingMedium(context)),
            gridDelegate: Responsive.gridDelegateSmall(context),
            itemCount: results.length,
            itemBuilder: (context, index) {
              final anime = results[index];
              return _buildGridCard(anime);
            },
          ),
          PaginationControls(
            currentPage: liveSearch.currentPage,
            totalPages: liveSearch.totalPages,
            hasNextPage: liveSearch.hasNextPage,
            onPrevPage: liveSearch.currentPage == 1
                ? null
                : liveSearch.previousPage,
            onNextPage: liveSearch.nextPage,
            onPageSelected: liveSearch.goToPage,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  void _openDetail(AnimeModel anime) {
    _saveCurrentKeywordNow();
    context.read<SearchHistoryNotifier>().addSearchAnime(anime);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetailScreen(
          malId: anime.malId,
          animeInfo: {
            'title': anime.title,
            'imageUrl': anime.imageUrl,
            'score': anime.score,
          },
        ),
      ),
    );
  }

  void _openHistoryDetail(SearchAnimeHistoryEntry item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetailScreen(
          malId: item.animeId,
          animeInfo: {
            'title': item.title,
            'imageUrl': item.imageUrl,
          },
        ),
      ),
    );
  }

  Widget _buildGridCard(AnimeModel anime) {
    return AnimeCard(anime: anime, onTap: () => _openDetail(anime));
  }
}
