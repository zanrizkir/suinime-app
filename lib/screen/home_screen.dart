import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/anime_model.dart';
import 'detail_screen.dart';
import 'search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedFilter = 'Home';
  int currentPage = 1;
  bool isLoading = false;
  bool isGenreAnimeLoading = false;
  List<AnimeModel> animeList = [];
  List<AnimeModel> genreAnimeList = [];
  List<Map<String, dynamic>> watchHistory = [];
  List<Map<String, dynamic>> genres = [];
  String selectedDay = 'Senin';
  Map<String, dynamic>? selectedGenre;

  final List<String> _filters = [
    'Home',
    'Jadwal Rilis',
    'On-going Anime',
    'Genre List',
  ];

  final List<Map<String, String>> _days = [
    {'label': 'Senin', 'api': 'monday'},
    {'label': 'Selasa', 'api': 'tuesday'},
    {'label': 'Rabu', 'api': 'wednesday'},
    {'label': 'Kamis', 'api': 'thursday'},
    {'label': 'Jumat', 'api': 'friday'},
    {'label': 'Sabtu', 'api': 'saturday'},
    {'label': 'Minggu', 'api': 'sunday'},
  ];

  final String baseUrl = 'https://api.jikan.moe/v4';

  @override
  void initState() {
    super.initState();
    _fetchData();
    _loadWatchHistory();
    _fetchGenres();
  }

  Future<void> _loadWatchHistory() async {
    await Future.delayed(const Duration(milliseconds: 200));
    if (mounted) {
      setState(() {
        watchHistory = [];
      });
    }
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

  Future<void> _fetchData() async {
    setState(() {
      isLoading = true;
    });

    try {
      String url = '';

      if (selectedFilter == 'Home') {
        url = '$baseUrl/top/anime?page=$currentPage';
      } else if (selectedFilter == 'Jadwal Rilis') {
        final dayApi = _days
            .firstWhere((d) => d['label'] == selectedDay,
                orElse: () => {'label': 'Senin', 'api': 'monday'})['api']!;
        url = '$baseUrl/schedules?filter=$dayApi&page=$currentPage';
      } else if (selectedFilter == 'On-going Anime') {
        url = '$baseUrl/top/anime?filter=airing&page=$currentPage';
      } else if (selectedFilter == 'Genre List') {
        setState(() {
          isLoading = false;
        });
        return;
      }

      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);
        final List<dynamic> dataList = jsonData['data'];
        final List<AnimeModel> fetched =
            dataList.map((item) => AnimeModel.fromJson(item)).toList();
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
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
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
        final List<AnimeModel> fetched =
            dataList.map((item) => AnimeModel.fromJson(item)).toList();
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
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _changeFilter(String filter) {
    if (selectedFilter == filter) return;
    setState(() {
      selectedFilter = filter;
      currentPage = 1;
      animeList = [];
      genreAnimeList = [];
      selectedGenre = null;
    });
    _fetchData();
  }

  void _changeDay(String day) {
    if (selectedDay == day) return;
    setState(() {
      selectedDay = day;
      currentPage = 1;
      animeList = [];
    });
    _fetchData();
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
      if (selectedFilter == 'Genre List') {
        genreAnimeList = [];
      } else {
        animeList = [];
      }
    });
    if (selectedFilter == 'Genre List' && selectedGenre != null) {
      _fetchGenreAnime(selectedGenre!['id'] as int);
    } else {
      _fetchData();
    }
  }

  void _prevPage() {
    if (currentPage <= 1) return;
    setState(() {
      currentPage--;
      if (selectedFilter == 'Genre List') {
        genreAnimeList = [];
      } else {
        animeList = [];
      }
    });
    if (selectedFilter == 'Genre List' && selectedGenre != null) {
      _fetchGenreAnime(selectedGenre!['id'] as int);
    } else {
      _fetchData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        title: const Text(
          'Suinime',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SearchScreen()),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterNavigation(),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildFilterNavigation() {
    return Container(
      height: 48,
      color: const Color(0xFF1A1A1A),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        itemCount: _filters.length,
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final isSelected = selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (_) => _changeFilter(filter),
              backgroundColor: const Color(0xFF2A2A2A),
              selectedColor: Colors.orange,
              labelStyle: TextStyle(
                color: isSelected ? Colors.black : Colors.white,
                fontWeight:
                    isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 13,
              ),
              side: BorderSide.none,
              showCheckmark: false,
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody() {
    switch (selectedFilter) {
      case 'Home':
        return _buildHomeBody();
      case 'Jadwal Rilis':
        return _buildJadwalBody();
      case 'On-going Anime':
        return _buildOngoingBody();
      case 'Completed Anime':
        return _buildCompletedBody();
      case 'Genre List':
        return _buildGenreBody();
      default:
        return const SizedBox.shrink();
    }
  }

  //==== HOME =====
  Widget _buildHomeBody() {
    if (isLoading && animeList.isEmpty) {
      return const Center(
          child: CircularProgressIndicator(color: Colors.orange));
    }
    if (animeList.isEmpty && !isLoading) {
      return const Center(
        child: Text('No data', style: TextStyle(color: Colors.white70)),
      );
    }

    final heroList = animeList.take(5).toList();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero Banner
          if (heroList.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.fromLTRB(12, 12, 12, 8),
              child: Text('Featured',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
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
                              builder: (_) =>
                                  DetailScreen(malId: anime.malId)),
                        ),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.network(anime.imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                    color: Colors.grey[900],
                                    child: const Icon(Icons.broken_image,
                                        color: Colors.white54))),
                            Container(
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black87
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
                                  Text(anime.title,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold)),
                                  if (anime.score != null)
                                    Row(children: [
                                      const Icon(Icons.star,
                                          color: Colors.orange, size: 14),
                                      const SizedBox(width: 4),
                                      Text(anime.score!.toStringAsFixed(1),
                                          style: const TextStyle(
                                              color: Colors.white70,
                                              fontSize: 12)),
                                    ]),
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

          // Recent Watch History
          if (watchHistory.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.fromLTRB(12, 16, 12, 8),
              child: Text('Tontonan Terakhir',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
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
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],

          // Top Anime Grid (no pagination on Home)
          const Padding(
            padding: EdgeInsets.fromLTRB(12, 16, 12, 8),
            child: Text('Top Anime',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
          ),
          _buildAnimeGrid(animeList),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  //==== JADWAL RILIS =====

  Widget _buildJadwalBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Sub-filter Hari
        SizedBox(
          height: 48,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            itemCount: _days.length,
            itemBuilder: (context, index) {
              final day = _days[index]['label']!;
              final isSelected = selectedDay == day;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => _changeDay(day),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.orange
                          : const Color(0xFF2A2A2A),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        day,
                        style: TextStyle(
                          color: isSelected ? Colors.black : Colors.white,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        Expanded(
          child: _buildScrollableGridSection(animeList, isLoading),
        ),
      ],
    );
  }

  //==== ON-GOING =====
  Widget _buildOngoingBody() {
    return _buildScrollableGridSection(animeList, isLoading);
  }
  Widget _buildCompletedBody() {
    return _buildScrollableGridSection(animeList, isLoading);
  }

  //==== GENRE LIST =====

  Widget _buildGenreBody() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Genre Chips Wrap
          if (genres.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(
                  child: CircularProgressIndicator(color: Colors.orange)),
            )
          else
            Padding(
              padding: const EdgeInsets.all(12),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: genres.map((genre) {
                  final isSelected =
                      selectedGenre?['id'] == genre['id'];
                  return GestureDetector(
                    onTap: () => _selectGenre(genre),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.orange
                            : const Color(0xFF1A1A1A),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? Colors.orange
                              : Colors.white24,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        genre['name'],
                        style: TextStyle(
                          color: isSelected ? Colors.black : Colors.white70,
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

          // Genre Anime Results
          if (selectedGenre != null) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
              child: Text(
                selectedGenre!['name'],
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
            ),
            if (isGenreAnimeLoading)
              const Padding(
                padding: EdgeInsets.all(40),
                child: Center(
                    child: CircularProgressIndicator(color: Colors.orange)),
              )
            else if (genreAnimeList.isEmpty)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(
                  child: Text('No anime found',
                      style: TextStyle(color: Colors.white54)),
                ),
              )
            else ...[
              _buildAnimeGrid(genreAnimeList),
              _buildPaginationControls(),
            ],
          ],
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  //==== SHARED WIDGETS =====

  Widget _buildScrollableGridSection(
      List<AnimeModel> list, bool loading) {
    if (loading && list.isEmpty) {
      return const Center(
          child: CircularProgressIndicator(color: Colors.orange));
    }
    if (list.isEmpty && !loading) {
      return const Center(
        child: Text('No data', style: TextStyle(color: Colors.white70)),
      );
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          _buildAnimeGrid(list),
          _buildPaginationControls(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildAnimeGrid(List<AnimeModel> list) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 180,
        childAspectRatio: 0.6,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: list.length,
      itemBuilder: (context, index) {
        return _buildAnimeCard(list[index]);
      },
    );
  }

  Widget _buildAnimeCard(AnimeModel anime) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => DetailScreen(malId: anime.malId)),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image — gunakan Expanded agar responsif
            Expanded(
              flex: 7,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                child: Image.network(
                  anime.imageUrl,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: Colors.grey[900],
                    child: const Center(
                      child:
                          Icon(Icons.broken_image, color: Colors.white54),
                    ),
                  ),
                  loadingBuilder: (_, child, progress) {
                    if (progress == null) return child;
                    return Container(
                      color: Colors.grey[900],
                      child: const Center(
                        child:
                            CircularProgressIndicator(color: Colors.orange),
                      ),
                    );
                  },
                ),
              ),
            ),
            // Info — gunakan Expanded agar tidak overflow
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(6, 6, 6, 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      anime.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                    if (anime.score != null)
                      Row(
                        children: [
                          const Icon(Icons.star,
                              color: Colors.orange, size: 12),
                          const SizedBox(width: 3),
                          Text(
                            anime.score!.toStringAsFixed(1),
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
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

  Widget _buildPaginationControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: currentPage == 1 ? null : _prevPage,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              disabledBackgroundColor: Colors.grey[800],
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            child: const Text('Previous',
                style: TextStyle(color: Colors.white)),
          ),
          const SizedBox(width: 16),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange, width: 1),
            ),
            child: Text(
              'Page $currentPage',
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14),
            ),
          ),
          const SizedBox(width: 16),
          ElevatedButton(
            onPressed: _nextPage,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            child:
                const Text('Next', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}