import 'package:flutter/material.dart';
import '../config/theme/app_theme.dart';
import '../services/api_service.dart';
import '../models/anime_model.dart';
import '../widgets/skeleton_loaders.dart';
import 'home/widgets/home_views.dart';
import 'home/widgets/pagination_controls.dart';

class CompletedAnimeScreen extends StatefulWidget {
  const CompletedAnimeScreen({super.key});

  @override
  State<CompletedAnimeScreen> createState() => _CompletedAnimeScreenState();
}

class _CompletedAnimeScreenState extends State<CompletedAnimeScreen> {
  late ApiService _apiService;
  List<AnimeModel> animeList = [];
  bool isLoading = true;
  int currentPage = 1;
  int totalPages = 1;
  bool hasNextPage = false;

  @override
  void initState() {
    super.initState();
    _apiService = ApiService();
    _loadCompletedAnime();
  }

  Future<void> _loadCompletedAnime() async {
    try {
      setState(() {
        isLoading = true;
      });
      final fetched = await _apiService.getCompletedAnimePaginated(
        page: currentPage,
      );
      if (mounted) {
        setState(() {
          animeList = ApiService.deduplicateAnimeList(fetched.anime);
          totalPages = fetched.totalPages;
          hasNextPage = fetched.hasNextPage;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          animeList = [];
          isLoading = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      }
      debugPrint('Error fetching completed anime: $e');
    }
  }

  void _nextPage() {
    if (!hasNextPage && currentPage >= totalPages) return;
    setState(() {
      currentPage++;
      animeList = [];
    });
    _loadCompletedAnime();
  }

  void _goToPage(int page) {
    final targetPage = page < 1 ? 1 : (page > totalPages ? totalPages : page);
    if (targetPage == currentPage) return;
    setState(() {
      currentPage = targetPage;
      animeList = [];
    });
    _loadCompletedAnime();
  }

  void _prevPage() {
    if (currentPage <= 1) return;
    setState(() {
      currentPage--;
      animeList = [];
    });
    _loadCompletedAnime();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      appBar: AppBar(
        backgroundColor: AppColors.darkBg,
        elevation: 0,
        centerTitle: false,
        titleSpacing: 16,
        title: const Text(
          'Completed Anime',
          style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading && animeList.isEmpty
          ? const AnimeGridSkeleton(count: 8, crossAxisCount: 2)
          : animeList.isEmpty && !isLoading
          ? const Center(
              child: Text(
                'No completed anime found',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  HomeViews.buildAnimeGrid(
                    context: context,
                    animeList: animeList,
                  ),
                  PaginationControls(
                    currentPage: currentPage,
                    totalPages: totalPages,
                    hasNextPage: hasNextPage,
                    onPrevPage: currentPage == 1 ? null : _prevPage,
                    onNextPage: _nextPage,
                    onPageSelected: _goToPage,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }
}
