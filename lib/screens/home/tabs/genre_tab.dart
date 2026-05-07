import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../models/anime_model.dart';
import '../../../config/theme/app_theme.dart';
import '../widgets/home_views.dart';
import '../widgets/pagination_controls.dart';

class GenreTab extends StatefulWidget {
  const GenreTab({super.key});

  @override
  State<GenreTab> createState() => _GenreTabState();
}

class _GenreTabState extends State<GenreTab> {
  int currentPage = 1;
  bool isGenreAnimeLoading = false;
  List<AnimeModel> genreAnimeList = [];
  List<Map<String, dynamic>> genres = [];
  Map<String, dynamic>? selectedGenre;

  final String baseUrl = 'https://api.jikan.moe/v4';

  @override
  void initState() {
    super.initState();
    _fetchGenres();
  }

  Future<void> _fetchGenres() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/genres/anime'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<dynamic> genreList = data['data'];
        if (mounted) {
          setState(() {
            genres = genreList
                .map((g) => {'id': g['mal_id'], 'name': g['name']})
                .toList();
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching genres: $e');
    }
  }

  Future<void> _fetchGenreAnime(int genreId) async {
    setState(() {
      isGenreAnimeLoading = true;
      genreAnimeList = [];
    });

    try {
      final url =
          '$baseUrl/anime?genres=$genreId&page=$currentPage&order_by=score&sort=desc';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);
        final List<dynamic> dataList = jsonData['data'];
        final List<AnimeModel> fetched = dataList
            .map((item) => AnimeModel.fromJson(item))
            .toList();
        if (mounted) {
          setState(() {
            genreAnimeList = fetched;
            isGenreAnimeLoading = false;
          });
        }
      } else {
        throw Exception('Failed to load genre anime');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
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
    return _buildGenreBody();
  }

  //==== GENRE LIST =====

  Widget _buildGenreBody() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (genres.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.all(12),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: genres.map((genre) {
                  final isSelected = selectedGenre?['id'] == genre['id'];
                  return GestureDetector(
                    onTap: () => _selectGenre(genre),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.darkSurface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.border.withValues(alpha: 0.5),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        genre['name'],
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
                }).toList(),
              ),
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
                  child: CircularProgressIndicator(color: AppColors.primary),
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
    );
  }
}
