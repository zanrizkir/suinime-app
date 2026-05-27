// lib/screens/home/home_screen.dart
import 'package:flutter/material.dart';
import '../../models/anime_model.dart';
import '../../models/paginated_anime_response.dart';
import '../../config/theme/app_theme.dart';
import '../../services/api_service.dart';
import '../dashboard_anime_list_screen.dart';
import '../search_screen.dart';
import '../../widgets/custom_text_field.dart';
import 'widgets/home_views.dart';
import 'tabs/dashboard_tab.dart';
import 'tabs/history_tab.dart';
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
  List<AnimeModel> animeList = [];
  String selectedDay = 'Senin';
  int totalPages = 1;
  bool hasNextPage = false;

  final TextEditingController _searchEntryController = TextEditingController();
  final ApiService _apiService = ApiService();

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

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _searchEntryController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    setState(() {
      isLoading = true;
    });

    await _fetchData(updateLoading: false, showError: false);
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _fetchData({
    bool updateLoading = true,
    bool showError = true,
  }) async {
    if (updateLoading) {
      setState(() {
        isLoading = true;
      });
    }

    try {
      final requestedPage = currentPage;
      PaginatedAnimeResponse? paginated;

      if (selectedFilter == 'Home') {
        paginated = await _apiService.fetchTopAnimePaginated(
          page: requestedPage,
        );
      } else if (selectedFilter == 'Jadwal Rilis') {
        final dayApi = _days.firstWhere(
          (d) => d['label'] == selectedDay,
          orElse: () => {'label': 'Senin', 'api': 'monday'},
        )['api']!;
        paginated = await _apiService.fetchSchedulePaginated(
          dayApi: dayApi,
          page: requestedPage,
        );
      } else if (selectedFilter == 'Pustaka' ||
          selectedFilter == 'Riwayat' ||
          selectedFilter == 'Lainnya') {
        if (updateLoading) {
          setState(() {
            isLoading = false;
          });
        }
        return;
      }

      final safePaginated = paginated;
      if (safePaginated == null) {
        if (mounted && updateLoading) {
          setState(() {
            isLoading = false;
          });
        }
        return;
      }

      final fetched = ApiService.deduplicateAnimeList(safePaginated.anime);
      if (mounted) {
        setState(() {
          totalPages = safePaginated.totalPages;
          hasNextPage = safePaginated.hasNextPage;
        });
      }

      if (mounted) {
        setState(() {
          animeList = fetched;
          if (updateLoading) isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
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

  void _changeFilter(String filter) {
    if (selectedFilter == filter) return;
    setState(() {
      selectedFilter = filter;
      currentPage = 1;
      totalPages = 1;
      hasNextPage = false;
      animeList = [];
    });
    _fetchData();
  }

  void _changeDay(String day) {
    if (selectedDay == day) return;
    setState(() {
      selectedDay = day;
      currentPage = 1;
      totalPages = 1;
      hasNextPage = false;
      animeList = [];
    });
    _fetchData();
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

  void _returnToHomeTab() {
    if (selectedFilter == 'Home') return;
    setState(() {
      selectedFilter = 'Home';
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: selectedFilter == 'Home',
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _returnToHomeTab();
      },
      child: Scaffold(
        backgroundColor: AppColors.darkBg,
        appBar: _buildAppBar(),
        body: _buildBody(),
        bottomNavigationBar: _buildBottomNavigationBar(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final activeIndex = _activeBottomNavIndex;
    final showDashboardHeader = activeIndex == 0;

    return AppBar(
      toolbarHeight: 72,
      backgroundColor: AppColors.darkBg,
      elevation: 0,
      centerTitle: false,
      titleSpacing: 16,
      title: AnimatedSwitcher(
        duration: const Duration(milliseconds: 180),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeOut,
        child: showDashboardHeader
            ? Row(
                key: const ValueKey('dashboard-header'),
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
              )
            : Text(
                _headerTitleForIndex(activeIndex),
                key: ValueKey('tab-header-$activeIndex'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.heading3.copyWith(color: AppColors.white),
              ),
      ),
    );
  }

  String _headerTitleForIndex(int index) {
    switch (index) {
      case 1:
        return 'Jadwal Rilis';
      case 2:
        return 'Pustaka';
      case 3:
        return 'Riwayat';
      case 4:
        return 'Lainnya';
      case 0:
      default:
        return 'Suinime';
    }
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
    final index = _bottomNavItems.indexWhere(
      (item) => item.filter == selectedFilter,
    );
    return index == -1 ? 0 : index;
  }

  Widget _buildBody() {
    return IndexedStack(
      index: _activeBottomNavIndex,
      children: [
        _buildHomeBody(),
        _buildJadwalBody(),
        const LibraryTab(),
        const HistoryTab(),
        _buildMoreBody(),
      ],
    );
  }

  //==== HOME =====

  Widget _buildHomeBody() {
    return DashboardTab(
      filter: 'Home',
      onTopAnimeSeeAll: () =>
          _openDashboardList(title: 'Top Anime', filter: 'Top Anime'),
      onLatestAnimeSeeAll: () =>
          _openDashboardList(title: 'Update Terbaru', filter: 'On-going Anime'),
    );
  }

  void _openDashboardList({required String title, required String filter}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DashboardAnimeListScreen(title: title, filter: filter),
      ),
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
            totalPages: totalPages,
            onPrevPage: currentPage == 1 ? null : _prevPage,
            onNextPage: _nextPage,
            onPageSelected: _goToPage,
            hasNextPage: hasNextPage,
          ),
        ),
      ],
    );
  }

  //==== LAINNYA =====

  Widget _buildMoreBody() {
    return const MoreTab();
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
