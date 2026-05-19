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

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _hasInteracted = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    final notifier = context.read<LiveSearchNotifier>();
    notifier.onSearchQueryChanged(_searchController.text, debounceMs: 400);

    if (!_hasInteracted && _searchController.text.isNotEmpty) {
      setState(() => _hasInteracted = true);
    }
    if (_searchController.text.isEmpty) {
      setState(() => _hasInteracted = false);
    }
  }

  @override
  void dispose() {
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
          hintText: 'Cari anime favoritmu...',
          prefixIcon: Icons.search_rounded,
          keyboardType: TextInputType.text,
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
    return _buildSearchResults(liveSearch.searchResults);
  }

  Widget _buildInitialState(SearchHistoryNotifier searchHistory) {
    final recentKeywords = searchHistory.recentKeywords;

    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(Responsive.paddingLarge(context)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
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
              if (recentKeywords.isNotEmpty) ...[
                SizedBox(height: Responsive.spacingXLarge(context)),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Pencarian Terakhir',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: Responsive.fontSizeMedium(context),
                    ),
                  ),
                ),
                SizedBox(height: Responsive.spacingMedium(context)),
                Wrap(
                  spacing: Responsive.spacingSmall(context),
                  runSpacing: Responsive.spacingSmall(context),
                  children: recentKeywords.map((keyword) {
                    return GestureDetector(
                      onTap: () {
                        _searchController.text = keyword;
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
                            color: AppColors.primary.withOpacity(0.3),
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResults(List<AnimeModel> results) {
    return GridView.builder(
      padding: EdgeInsets.all(Responsive.paddingMedium(context)),
      gridDelegate: Responsive.gridDelegateSmall(context),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final anime = results[index];
        return _buildGridCard(anime);
      },
    );
  }

  void _openDetail(AnimeModel anime) {
    // Save search query to history
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      final searchHistory = context.read<SearchHistoryNotifier>();
      searchHistory.addSearchKeyword(query);
    }

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

  Widget _buildGridCard(AnimeModel anime) {
    return AnimeCard(anime: anime, onTap: () => _openDetail(anime));
  }
}
