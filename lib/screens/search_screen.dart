import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme/app_theme.dart';
import '../models/anime_model.dart';
import '../services/live_search_notifier.dart';
import '../services/search_history_notifier.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import 'detail_screen.dart';

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
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: AppColors.error, size: 60),
              const SizedBox(height: 16),
              Text(
                liveSearch.errorMessage!,
                style: const TextStyle(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
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
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.search, size: 64, color: AppColors.textTertiary),
              const SizedBox(height: 16),
              const Text(
                'Cari anime favoritmu',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
              ),
              if (recentKeywords.isNotEmpty) ...[
                const SizedBox(height: 32),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Pencarian Terakhir',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: recentKeywords.map((keyword) {
                    return GestureDetector(
                      onTap: () {
                        _searchController.text = keyword;
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
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
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTabletOrDesktop = constraints.maxWidth >= 600;

        if (isTabletOrDesktop) {
          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.7,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: results.length,
            itemBuilder: (context, index) {
              final anime = results[index];
              return _buildGridCard(anime);
            },
          );
        } else {
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: results.length,
            itemBuilder: (context, index) {
              final anime = results[index];
              return _buildListCard(anime);
            },
          );
        }
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

  Widget _buildListCard(AnimeModel anime) {
    return GestureDetector(
      onTap: () => _openDetail(anime),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.darkSurface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
              child: Image.network(
                anime.imageUrl,
                width: 80,
                height: 120,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 80,
                    height: 120,
                    color: AppColors.darkSurface,
                    child: const Icon(
                      Icons.broken_image,
                      color: AppColors.textTertiary,
                    ),
                  );
                },
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      anime.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (anime.score != null)
                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            color: AppColors.warning,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            anime.score!.toStringAsFixed(1),
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(12),
              child: Icon(Icons.chevron_right, color: AppColors.textTertiary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridCard(AnimeModel anime) {
    return GestureDetector(
      onTap: () => _openDetail(anime),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.darkSurface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              child: Image.network(
                anime.imageUrl,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 180,
                    color: AppColors.darkSurface,
                    child: const Center(
                      child: Icon(
                        Icons.broken_image,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  );
                },
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      anime.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (anime.score != null)
                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            color: AppColors.warning,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            anime.score!.toStringAsFixed(1),
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
