import 'package:flutter/material.dart';
import '../config/theme/app_theme.dart';
import '../services/api_service.dart';
import '../models/anime_model.dart';
import 'home/widgets/home_views.dart';

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
      final fetched = await _apiService.getCompletedAnime(page: currentPage);
      if (mounted) {
        setState(() {
          animeList = fetched;
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
    setState(() {
      currentPage++;
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
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
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
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 12,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (currentPage > 1)
                          ElevatedButton.icon(
                            onPressed: _prevPage,
                            icon: const Icon(Icons.arrow_back_rounded),
                            label: const Text('Previous'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                            ),
                          ),
                        if (currentPage > 1) const SizedBox(width: 10),
                        Text(
                          'Page $currentPage',
                          style: const TextStyle(color: AppColors.white),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton.icon(
                          onPressed: _nextPage,
                          icon: const Icon(Icons.arrow_forward_rounded),
                          label: const Text('Next'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }
}
