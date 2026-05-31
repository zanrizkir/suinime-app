import 'package:flutter/material.dart';
import '../config/theme/app_theme.dart';
import '../services/api_service.dart';
import '../models/anime_model.dart';
import '../widgets/skeleton_loaders.dart';
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
  int totalPages = 1;
  bool hasNextPage = false;
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
      final fetched = await _apiService.fetchAnimeByGenrePaginated(
        genreId,
        page: currentPage,
      );
      if (mounted) {
        setState(() {
          genreAnimeList = ApiService.deduplicateAnimeList(fetched.anime);
          totalPages = fetched.totalPages;
          hasNextPage = fetched.hasNextPage;
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

  /// Group genres by their first letter (A-Z) or '#' for non-alphabetic
  Map<String, List<Map<String, dynamic>>> _groupGenresByLetter(
    List<Map<String, dynamic>> genres,
  ) {
    final grouped = <String, List<Map<String, dynamic>>>{};

    for (final genre in genres) {
      final name = genre['name'] as String;
      final firstChar = name.isNotEmpty ? name[0] : '';
      final letter = RegExp(r'^[a-zA-Z]').hasMatch(firstChar)
          ? firstChar.toUpperCase()
          : '#';

      grouped.putIfAbsent(letter, () => []);
      grouped[letter]!.add(genre);
    }

    // Sort each group alphabetically
    grouped.forEach((key, genreList) {
      genreList.sort(
        (a, b) => (a['name'] as String).compareTo(b['name'] as String),
      );
    });

    return grouped;
  }

  void _selectGenre(Map<String, dynamic> genre) {
    setState(() {
      selectedGenre = genre;
      currentPage = 1;
      genreAnimeList = [];
      totalPages = 1;
      hasNextPage = false;
    });
    _fetchGenreAnime(genre['id'] as int);
  }

  void _nextPage() {
    if (!hasNextPage && currentPage >= totalPages) return;
    setState(() {
      currentPage++;
      genreAnimeList = [];
    });
    if (selectedGenre != null) {
      _fetchGenreAnime(selectedGenre!['id'] as int);
    }
  }

  void _goToPage(int page) {
    final targetPage = page < 1 ? 1 : (page > totalPages ? totalPages : page);
    if (targetPage == currentPage) return;
    setState(() {
      currentPage = targetPage;
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

  /// Build grouped genre list with alphabetical timeline sections
  Widget _buildGroupedGenreList() {
    final groupedGenres = _groupGenresByLetter(genres);
    final sortedKeys = groupedGenres.keys.toList();

    // Put '#' first if it exists, then sort A-Z
    sortedKeys.sort((a, b) {
      if (a == '#') return -1;
      if (b == '#') return 1;
      return a.compareTo(b);
    });

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: sortedKeys.length,
      itemBuilder: (context, index) {
        final letter = sortedKeys[index];
        final genresInGroup = groupedGenres[letter]!;

        return Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Letter - prominent display on left
                SizedBox(
                  width: 50,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 4, right: 12),
                    child: Text(
                      letter,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ),
                // Vertical divider - continuous line
                Container(
                  width: 2,
                  color: AppColors.primary.withValues(alpha: 0.3),
                ),
                // Genre chips - wrapped responsive layout
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      alignment: WrapAlignment.start,
                      children: List.generate(genresInGroup.length, (
                        genreIndex,
                      ) {
                        final genre = genresInGroup[genreIndex];
                        final isSelected = selectedGenre?['id'] == genre['id'];

                        return GestureDetector(
                          onTap: () => _selectGenre(genre),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.darkSurface,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.border.withValues(alpha: 0.4),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              genre['name'],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: isSelected
                                    ? AppColors.dark
                                    : AppColors.textSecondary,
                                fontSize: 12,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
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
          ? const GenreListSkeleton(groupCount: 5, itemsPerGroup: 4)
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
                    _buildGroupedGenreList(),
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
                        child: AnimeGridSkeleton(count: 8),
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
                        totalPages: totalPages,
                        hasNextPage: hasNextPage,
                        onPrevPage: currentPage == 1 ? null : _prevPage,
                        onNextPage: _nextPage,
                        onPageSelected: _goToPage,
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
