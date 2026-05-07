import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../models/anime_model.dart';
import '../../../config/theme/app_theme.dart';
import '../../detail_screen.dart';
import '../widgets/home_views.dart';
import '../widgets/pagination_controls.dart';

class DashboardTab extends StatefulWidget {
  final String filter;

  const DashboardTab({super.key, required this.filter});

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  int currentPage = 1;
  bool isLoading = false;
  bool isLatestLoading = false;
  List<AnimeModel> animeList = [];
  List<AnimeModel> latestAnimeList = [];
  List<Map<String, dynamic>> watchHistory = [];

  final String baseUrl = 'https://api.jikan.moe/v4';

  @override
  void initState() {
    super.initState();
    _fetchData();
    _fetchLatestAnime();
    _loadWatchHistory();
  }

  Future<void> _loadWatchHistory() async {
    await Future.delayed(const Duration(milliseconds: 200));
    if (mounted) {
      setState(() {
        watchHistory = [];
      });
    }
  }

  Future<void> _fetchLatestAnime() async {
    setState(() {
      isLatestLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/top/anime?filter=airing&page=1'),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);
        final List<dynamic> dataList = jsonData['data'] ?? [];
        final List<AnimeModel> fetched = dataList
            .map((item) => AnimeModel.fromJson(item))
            .toList();
        if (mounted) {
          setState(() {
            latestAnimeList = fetched;
            isLatestLoading = false;
          });
        }
      } else {
        throw Exception('Failed to load latest anime');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLatestLoading = false;
        });
        debugPrint('Error fetching latest anime: $e');
      }
    }
  }

  Future<void> _fetchData() async {
    setState(() {
      isLoading = true;
    });

    try {
      String url = '';

      if (widget.filter == 'Home' || widget.filter == 'Top Anime') {
        url = '$baseUrl/top/anime?page=$currentPage';
      }

      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);
        final List<dynamic> dataList = jsonData['data'];
        final List<AnimeModel> fetched = dataList
            .map((item) => AnimeModel.fromJson(item))
            .toList();
        if (mounted) {
          setState(() {
            animeList = fetched;
            isLoading = false;
          });
        }
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _nextPage() {
    setState(() {
      currentPage++;
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
    if (widget.filter == 'Home') {
      return _buildHomeBody();
    } else if (widget.filter == 'Top Anime') {
      return _buildTopAnimeBody();
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
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DetailScreen(malId: anime.malId),
                          ),
                        ),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.network(
                              anime.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
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
            title: 'Top Anime',
            animeList: animeList.take(6).toList(),
            isLoading: isLoading,
            onSeeAll: () {},
          ),
          HomeViews.buildPreviewSection(
            context: context,
            title: 'Update Terbaru',
            animeList: latestAnimeList.take(6).toList(),
            isLoading: isLatestLoading,
            onSeeAll: () {},
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  //==== TOP ANIME =====

  Widget _buildTopAnimeBody() {
    return HomeViews.buildScrollableGridSection(
      context: context,
      animeList: animeList,
      isLoading: isLoading,
      currentPage: currentPage,
      onPrevPage: currentPage == 1 ? null : _prevPage,
      onNextPage: _nextPage,
    );
  }
}
