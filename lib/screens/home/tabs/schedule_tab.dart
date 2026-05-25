import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../models/anime_model.dart';
import '../../../models/paginated_anime_response.dart';
import '../../../config/theme/app_theme.dart';
import '../widgets/home_views.dart';

class ScheduleTab extends StatefulWidget {
  const ScheduleTab({super.key});

  @override
  State<ScheduleTab> createState() => _ScheduleTabState();
}

class _ScheduleTabState extends State<ScheduleTab> {
  int currentPage = 1;
  bool isLoading = false;
  List<AnimeModel> animeList = [];
  String selectedDay = 'Senin';
  int totalPages = 1;
  bool hasNextPage = false;

  final String baseUrl = 'https://api.jikan.moe/v4';

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
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final dayApi = _days.firstWhere(
        (d) => d['label'] == selectedDay,
        orElse: () => {'label': 'Senin', 'api': 'monday'},
      )['api']!;
      final url = '$baseUrl/schedules?filter=$dayApi&page=$currentPage';

      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);
        final paginated = PaginatedAnimeResponse.fromJson(
          jsonData,
          requestedPage: currentPage,
        );
        final fetched = paginated.anime;
        if (mounted) {
          setState(() {
            animeList = fetched;
            totalPages = paginated.totalPages;
            hasNextPage = paginated.hasNextPage;
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

  @override
  Widget build(BuildContext context) {
    return _buildJadwalBody();
  }

  //==== JADWAL RILIS =====

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
}
