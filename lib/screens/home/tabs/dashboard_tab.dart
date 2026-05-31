import 'package:flutter/material.dart';
import '../../../models/anime_model.dart';
import '../../../config/theme/app_theme.dart';
import '../../../services/api_service.dart';
import '../widgets/home_views.dart';

class DashboardTab extends StatefulWidget {
  final String filter;
  final VoidCallback onTopAnimeSeeAll;
  final VoidCallback onLatestAnimeSeeAll;

  const DashboardTab({
    super.key,
    required this.filter,
    required this.onTopAnimeSeeAll,
    required this.onLatestAnimeSeeAll,
  });

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab>
    with AutomaticKeepAliveClientMixin {
  int currentPage = 1;
  bool isLoading = false;
  bool isLatestLoading = false;
  List<AnimeModel> animeList = [];
  List<AnimeModel> latestAnimeList = [];
  List<Map<String, dynamic>> watchHistory = [];
  int totalPages = 1;
  int perPage = 25;
  bool hasNextPage = false;

  final ApiService _apiService = ApiService();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _loadWatchHistory();
  }

  Future<void> _loadInitialData() async {
    setState(() {
      isLoading = true;
      isLatestLoading = widget.filter == 'Home';
    });

    await _fetchData(updateLoading: false, showError: false);

    if (widget.filter == 'Home') {
      await Future.delayed(const Duration(milliseconds: 500));
      await _fetchLatestAnime(updateLoading: false);
    }

    if (!mounted) return;
    setState(() {
      isLoading = false;
      isLatestLoading = false;
    });
  }

  @override
  void didUpdateWidget(covariant DashboardTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.filter != widget.filter) {
      setState(() {
        currentPage = 1;
        totalPages = 1;
        perPage = 25;
        hasNextPage = false;
        animeList = [];
      });
      _fetchData();
    }
  }

  Future<void> _loadWatchHistory() async {
    await Future.delayed(const Duration(milliseconds: 200));
    if (mounted) {
      setState(() {
        watchHistory = [];
      });
    }
  }

  Future<void> _fetchLatestAnime({bool updateLoading = true}) async {
    if (updateLoading) {
      setState(() {
        isLatestLoading = true;
      });
    }

    try {
      final fetched = ApiService.deduplicateAnimeList(
        await _apiService.fetchSeasonNow(page: 1),
      );

      if (mounted) {
        setState(() {
          latestAnimeList = fetched;
          if (updateLoading) isLatestLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          latestAnimeList = [];
          if (updateLoading) isLatestLoading = false;
        });
        debugPrint('Error fetching latest anime: $e');
      }
    }
  }

  Future<void> _fetchData({
    bool updateLoading = true,
    bool showError = true,
  }) async {
    final filter = widget.filter;

    if (updateLoading) {
      setState(() {
        isLoading = true;
      });
    }

    try {
      final requestedPage = currentPage;
      final paginated = filter == 'On-going Anime'
          ? await _apiService.fetchSeasonNowPaginated(page: requestedPage)
          : await _apiService.fetchTopAnimePaginated(page: requestedPage);

      if (mounted && widget.filter == filter) {
        setState(() {
          totalPages = paginated.totalPages;
          perPage = paginated.perPage > 0 ? paginated.perPage : perPage;
          hasNextPage = paginated.hasNextPage;
        });
      }

      if (mounted && widget.filter == filter) {
        setState(() {
          animeList = ApiService.deduplicateAnimeList(paginated.anime);
          if (updateLoading) isLoading = false;
        });
      }
    } catch (e) {
      if (mounted && widget.filter == filter) {
        setState(() {
          animeList = [];
          if (updateLoading) isLoading = false;
        });
        if (showError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      }
    }
  }

  void _nextPage() {
    if (!hasNextPage && currentPage >= totalPages) return;
    setState(() {
      currentPage++;
      animeList = [];
    });
    _fetchData();
  }

  void _goToPage(int page) {
    final targetPage = page < 1 ? 1 : (page > totalPages ? totalPages : page);
    if (targetPage == currentPage) return;
    setState(() {
      currentPage = targetPage;
      animeList = [];
    });
    _fetchData();
  }

  void _prevPage() {
    if (currentPage <= 1) return;
    setState(() {
      currentPage--;
      animeList = [];
    });
    _fetchData();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (widget.filter == 'Home') {
      return _buildHomeBody();
    } else if (widget.filter == 'Top Anime') {
      return _buildTopAnimeBody();
    } else if (widget.filter == 'On-going Anime') {
      return _buildOngoingAnimeBody();
    }
    return const SizedBox.shrink();
  }

  //==== HOME =====

  Widget _buildHomeBody() {
    if (isLoading && animeList.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }
    if (animeList.isEmpty && !isLoading) {
      return const Center(
        child: Text(
          'No data',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    final heroList = animeList.take(5).toList();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (heroList.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.fromLTRB(12, 12, 12, 8),
              child: Text('Featured', style: AppTextStyles.heading4),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: PageView.builder(
                    itemCount: heroList.length,
                    itemBuilder: (context, index) {
                      final anime = heroList[index];
                      return GestureDetector(
                        onTap: () => HomeViews.openDetail(context, anime),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.network(
                              anime.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => Container(
                                color: AppColors.darkSurface,
                                child: const Icon(
                                  Icons.broken_image,
                                  color: AppColors.textTertiary,
                                ),
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    AppColors.dark.withValues(alpha: 0),
                                    AppColors.dark.withValues(alpha: 0.7),
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 16,
                              left: 16,
                              right: 16,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    anime.title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTextStyles.bodyLarge,
                                  ),
                                  if (anime.score != null)
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.star,
                                          color: AppColors.warning,
                                          size: 14,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          anime.score!.toStringAsFixed(1),
                                          style: AppTextStyles.caption,
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],

          if (watchHistory.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.fromLTRB(12, 16, 12, 8),
              child: Text('Tontonan Terakhir', style: AppTextStyles.heading4),
            ),
            SizedBox(
              height: 130,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: watchHistory.length,
                itemBuilder: (context, index) => Container(
                  width: 100,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],

          HomeViews.buildPreviewSection(
            context: context,
            title: 'Update Terbaru',
            animeList: latestAnimeList.take(6).toList(),
            isLoading: isLatestLoading,
            onSeeAll: widget.onLatestAnimeSeeAll,
          ),
          HomeViews.buildPreviewSection(
            context: context,
            title: 'Top Anime',
            animeList: animeList.take(6).toList(),
            isLoading: isLoading,
            onSeeAll: widget.onTopAnimeSeeAll,
            ranked: true,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  //==== TOP ANIME =====

  Widget _buildTopAnimeBody() {
    return HomeViews.buildScrollableRankedSection(
      context: context,
      animeList: animeList,
      isLoading: isLoading,
      currentPage: currentPage,
      totalPages: totalPages,
      perPage: perPage,
      onPrevPage: currentPage == 1 ? null : _prevPage,
      onNextPage: _nextPage,
      onPageSelected: _goToPage,
      hasNextPage: hasNextPage,
    );
  }

  Widget _buildOngoingAnimeBody() {
    return HomeViews.buildScrollableGridSection(
      context: context,
      animeList: animeList,
      isLoading: isLoading,
      currentPage: currentPage,
      totalPages: totalPages,
      onPrevPage: currentPage == 1 ? null : _prevPage,
      onNextPage: _nextPage,
      onPageSelected: _goToPage,
      hasNextPage: hasNextPage,
    );
  }
}
