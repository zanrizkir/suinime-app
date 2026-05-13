import 'package:flutter/material.dart';
import '../config/theme/app_theme.dart';
import '../services/api_service.dart';
import '../models/anime_model.dart';
import 'home/widgets/home_views.dart';
import 'home/widgets/pagination_controls.dart';

class GenreListScreen extends StatefulWidget {
  const GenreListScreen({super.key});

  @override
  State<GenreListScreen> createState() => _GenreListScreenState();
}

class _GenreListScreenState extends State<GenreListScreen> {
  late ApiService _apiService;
  List<Map<String, dynamic>> genres = [];
  List<AnimeModel> genreAnimeList = [];
  bool isLoading = true;
  bool isGenreAnimeLoading = false;
  int currentPage = 1;
  Map<String, dynamic>? selectedGenre;

  @override
  void initState() {
    super.initState();
    _apiService = ApiService();
    _loadGenres();
  }

  Future<void> _loadGenres() async {
    try {
      setState(() {
        isLoading = true;
      });
      final fetchedGenres = await _apiService.fetchAnimeGenres();
      if (mounted) {
        setState(() {
          genres = fetchedGenres;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          genres = [];
          isLoading = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      }
      debugPrint('Error fetching genres: $e');
    }
  }

  Future<void> _fetchGenreAnime(int genreId) async {
    setState(() {
      isGenreAnimeLoading = true;
      genreAnimeList = [];
    });

    try {
      final fetched = await _apiService.fetchAnimeByGenre(
        genreId,
        page: currentPage,
      );
      if (mounted) {
        setState(() {
          genreAnimeList = fetched;
          isGenreAnimeLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          genreAnimeList = [];
          isGenreAnimeLoading = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _selectGenre(Map<String, dynamic> genre) {
    setState(() {
      selectedGenre = genre;
      currentPage = 1;
      genreAnimeList = [];
    });
    _fetchGenreAnime(genre['id'] as int);
  }

  void _nextPage() {
    setState(() {
      currentPage++;
      genreAnimeList = [];
    });
    if (selectedGenre != null) {
      _fetchGenreAnime(selectedGenre!['id'] as int);
    }
  }

  void _prevPage() {
    if (currentPage <= 1) return;
    setState(() {
      currentPage--;
      genreAnimeList = [];
    });
    if (selectedGenre != null) {
      _fetchGenreAnime(selectedGenre!['id'] as int);
    }
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
          'Genre List',
          style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (genres.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(
                        child: Text(
                          'No genres available',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ),
                    )
                  else
                    LayoutBuilder(
                      builder: (context, constraints) {
                        const spacing = 8.0;
                        final columns = (constraints.maxWidth / 132)
                            .floor()
                            .clamp(2, 4)
                            .toInt();

                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(12),
                          itemCount: genres.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: columns,
                                crossAxisSpacing: spacing,
                                mainAxisSpacing: spacing,
                                mainAxisExtent: 40,
                              ),
                          itemBuilder: (context, index) {
                            final genre = genres[index];
                            final isSelected =
                                selectedGenre?['id'] == genre['id'];
                            return GestureDetector(
                              onTap: () => _selectGenre(genre),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                alignment: Alignment.center,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.darkSurface,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.primary
                                        : AppColors.border.withValues(
                                            alpha: 0.5,
                                          ),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  genre['name'],
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: isSelected
                                        ? AppColors.dark
                                        : AppColors.textSecondary,
                                    fontSize: 13,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  if (selectedGenre != null) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
                      child: Text(
                        selectedGenre!['name'],
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (isGenreAnimeLoading)
                      const Padding(
                        padding: EdgeInsets.all(40),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                        ),
                      )
                    else if (genreAnimeList.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(24),
                        child: Center(
                          child: Text(
                            'No anime found',
                            style: TextStyle(color: AppColors.textTertiary),
                          ),
                        ),
                      )
                    else ...[
                      HomeViews.buildAnimeGrid(
                        context: context,
                        animeList: genreAnimeList,
                      ),
                      PaginationControls(
                        currentPage: currentPage,
                        onPrevPage: currentPage == 1 ? null : _prevPage,
                        onNextPage: _nextPage,
                      ),
                    ],
                  ],
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }
}
