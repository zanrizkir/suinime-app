// lib/screens/home/home_screen.dart
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/anime_model.dart';
import '../../config/theme/app_theme.dart';
import '../search_screen.dart';
import '../../widgets/custom_text_field.dart';
import 'widgets/pagination_controls.dart';
import 'widgets/home_views.dart';
import 'tabs/dashboard_tab.dart';
import 'tabs/library_tab.dart';
import 'tabs/more_tab.dart';

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

  final TextEditingController _searchEntryController = TextEditingController();

  final List<_BottomNavItem> _bottomNavItems = const [
    _BottomNavItem(
      label: 'Home',
      filter: 'Home',
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
    ),
    _BottomNavItem(
      label: 'Jadwal',
      filter: 'Jadwal Rilis',
      icon: Icons.calendar_month_outlined,
      activeIcon: Icons.calendar_month_rounded,
    ),
    _BottomNavItem(
      label: 'Pustaka',
      filter: 'Pustaka',
      icon: Icons.video_library_outlined,
      activeIcon: Icons.video_library_rounded,
    ),
    _BottomNavItem(
      label: 'Riwayat',
      filter: 'Riwayat',
      icon: Icons.history_outlined,
      activeIcon: Icons.history_rounded,
    ),
    _BottomNavItem(
      label: 'Lainnya',
      filter: 'Lainnya',
      icon: Icons.menu_rounded,
      activeIcon: Icons.more_horiz_rounded,
    ),
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

  @override
  void dispose() {
    _searchEntryController.dispose();
    super.dispose();
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
            genres.sort(
              (a, b) => a['name']
                  .toString()
                  .toLowerCase()
                  .compareTo(b['name'].toString().toLowerCase()),
            );
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

      if (selectedFilter == 'Home' || selectedFilter == 'Top Anime') {
        url = '$baseUrl/top/anime?page=$currentPage';
      } else if (selectedFilter == 'Jadwal Rilis') {
        final dayApi = _days.firstWhere(
          (d) => d['label'] == selectedDay,
          orElse: () => {'label': 'Senin', 'api': 'monday'},
        )['api']!;
        url = '$baseUrl/schedules?filter=$dayApi&page=$currentPage';
      } else if (selectedFilter == 'Pustaka' ||
          selectedFilter == 'Genre List') {
        setState(() {
          isLoading = false;
        });
        return;
      } else if (selectedFilter == 'Riwayat' || selectedFilter == 'Lainnya') {
        setState(() {
          isLoading = false;
        });
        return;
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

  void _changeDashboardFilter(String filter) {
    if (selectedFilter == filter) return;
    setState(() {
      selectedFilter = filter;
      currentPage = 1;
      animeList = [];
      genreAnimeList = [];
      selectedGenre = null;
    });
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
      backgroundColor: AppColors.darkBg,
      appBar: _buildHomeAppBar(),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  PreferredSizeWidget _buildHomeAppBar() {
    return AppBar(
      toolbarHeight: 72,
      backgroundColor: AppColors.darkBg,
      elevation: 0,
      centerTitle: false,
      titleSpacing: 16,
      title: Row(
        children: [
          const Text(
            'Suinime',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.white,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(child: _buildSearchEntry()),
        ],
      ),
    );
  }

  Widget _buildSearchEntry() {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const SearchScreen()),
      ),
      child: AbsorbPointer(
        child: CustomTextField(
          controller: _searchEntryController,
          hintText: 'Cari anime...',
          prefixIcon: Icons.search_rounded,
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    final activeIndex = _activeBottomNavIndex;

    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.darkSurface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: AppColors.dark.withValues(alpha: 0.35),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: List.generate(_bottomNavItems.length, (index) {
            final item = _bottomNavItems[index];
            final isSelected = activeIndex == index;

            return Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () => _changeFilter(item.filter),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOut,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withValues(alpha: 0.14)
                        : AppColors.dark.withValues(alpha: 0),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isSelected ? item.activeIcon : item.icon,
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.lightGrey,
                        size: 22,
                      ),
                      const SizedBox(height: 4),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          item.label,
                          maxLines: 1,
                          style: TextStyle(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.lightGrey,
                            fontSize: 11,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  int get _activeBottomNavIndex {
    if (selectedFilter == 'Completed Anime') {
      return _bottomNavItems.indexWhere((item) => item.filter == 'Lainnya');
    }
    if (selectedFilter == 'Genre List') {
      return _bottomNavItems.indexWhere((item) => item.filter == 'Lainnya');
    }
    if (selectedFilter == 'Top Anime' || selectedFilter == 'On-going Anime') {
      return _bottomNavItems.indexWhere((item) => item.filter == 'Home');
    }
    final index = _bottomNavItems.indexWhere(
      (item) => item.filter == selectedFilter,
    );
    return index == -1 ? 0 : index;
  }

  Widget _buildBody() {
    switch (selectedFilter) {
      case 'Home':
        return _buildHomeBody();
      case 'Top Anime':
        return DashboardTab(
          filter: 'Top Anime',
          onTopAnimeSeeAll: () {},
          onLatestAnimeSeeAll: () {},
        );
      case 'Jadwal Rilis':
        return _buildJadwalBody();
      case 'On-going Anime':
        return DashboardTab(
          filter: 'On-going Anime',
          onTopAnimeSeeAll: () {},
          onLatestAnimeSeeAll: () {},
        );
      case 'Completed Anime':
        return _buildCompletedBody();
      case 'Pustaka':
        return const LibraryTab();
      case 'Genre List':
        return _buildGenreBody();
      case 'Riwayat':
        return _buildHistoryBody();
      case 'Lainnya':
        return _buildMoreBody();
      default:
        return const SizedBox.shrink();
    }
  }

  //==== HOME =====

  Widget _buildHomeBody() {
    return DashboardTab(
      filter: selectedFilter,
      onTopAnimeSeeAll: () => _changeDashboardFilter('Top Anime'),
      onLatestAnimeSeeAll: () => _changeDashboardFilter('On-going Anime'),
    );
  }

  //==== JADWAL RILIS ======

  Widget _buildJadwalBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                      horizontal: 16,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : AppColors.divider,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        day,
                        style: TextStyle(
                          color: isSelected ? AppColors.dark : AppColors.white,
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
          child: HomeViews.buildScrollableGridSection(
            context: context,
            animeList: animeList,
            isLoading: isLoading,
            currentPage: currentPage,
            onPrevPage: currentPage == 1 ? null : _prevPage,
            onNextPage: _nextPage,
          ),
        ),
      ],
    );
  }

  Widget _buildCompletedBody() {
    return HomeViews.buildScrollableGridSection(
      context: context,
      animeList: animeList,
      isLoading: isLoading,
      currentPage: currentPage,
      onPrevPage: currentPage == 1 ? null : _prevPage,
      onNextPage: _nextPage,
    );
  }

  //==== RIWAYAT =====

  Widget _buildHistoryBody() {
    if (watchHistory.isEmpty) {
      return const Center(
        child: Text(
          'Belum ada riwayat tontonan',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: watchHistory.length,
      itemBuilder: (context, index) {
        final item = watchHistory[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.darkSurface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            item['title']?.toString() ?? 'Untitled',
            style: AppTextStyles.labelLarge,
          ),
        );
      },
    );
  }

  //==== LAINNYA =====

  Widget _buildMoreBody() {
    return MoreTab(
      onGenreTap: () => _changeFilter('Genre List'),
      onCompletedTap: () => _changeFilter('Completed Anime'),
    );
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
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    crossAxisSpacing: spacing,
                    mainAxisSpacing: spacing,
                    mainAxisExtent: 40,
                  ),
                  itemBuilder: (context, index) {
                    final genre = genres[index];
                    final isSelected = selectedGenre?['id'] == genre['id'];
                    return GestureDetector(
                      onTap: () => _selectGenre(genre),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
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

class _BottomNavItem {
  final String label;
  final String filter;
  final IconData icon;
  final IconData activeIcon;

  const _BottomNavItem({
    required this.label,
    required this.filter,
    required this.icon,
    required this.activeIcon,
  });
}
