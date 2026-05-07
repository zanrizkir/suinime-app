import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/theme/app_theme.dart';
import '../widgets/custom_button.dart';

class DetailScreen extends StatefulWidget {
  final int malId;
  final Map<String, dynamic>? animeInfo;

  const DetailScreen({super.key, required this.malId, this.animeInfo});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final String baseUrl = 'https://api.jikan.moe/v4';

  bool isDetailLoading = false;
  Map<String, dynamic> detailData = {};

  List<Map<String, dynamic>> episodes = [];
  bool isEpisodeLoading = false;
  String? episodeError;
  int episodePage = 1;
  bool hasMoreEpisodes = true;

  @override
  void initState() {
    super.initState();
    _loadDetail();
    _loadEpisodes();
  }

  //==== API CALLS =====

  Future<void> _loadDetail() async {
    final existingSynopsis = widget.animeInfo?['synopsis']?.toString() ?? '';
    if (existingSynopsis.isNotEmpty) {
      setState(() {
        detailData = widget.animeInfo ?? {};
      });
      return;
    }

    setState(() {
      isDetailLoading = true;
    });

    try {
      final response = await http
          .get(Uri.parse('$baseUrl/anime/${widget.malId}'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final data = json['data'] as Map<String, dynamic>;

        if (mounted) {
          setState(() {
            detailData = {
              'title': data['title'] ?? widget.animeInfo?['title'] ?? '',
              'imageUrl':
                  data['images']?['jpg']?['large_image_url'] ??
                  widget.animeInfo?['imageUrl'] ??
                  '',
              'backdropUrl':
                  data['trailer']?['images']?['maximum_image_url'] ??
                  data['images']?['jpg']?['large_image_url'] ??
                  widget.animeInfo?['imageUrl'] ??
                  '',
              'score': data['score'],
              'synopsis': data['synopsis'] ?? '',
              'status': data['status'] ?? '',
              'releaseDate': data['aired']?['string'] ?? '',
              'genres': (data['genres'] as List<dynamic>? ?? [])
                  .map((g) => g['name']?.toString() ?? '')
                  .where((g) => g.isNotEmpty)
                  .toList(),
              'episodes': data['episodes'],
              'duration': data['duration'] ?? '',
              'rating': data['rating'] ?? '',
              'studios': (data['studios'] as List<dynamic>? ?? [])
                  .map((s) => s['name']?.toString() ?? '')
                  .where((s) => s.isNotEmpty)
                  .toList(),
              'source': data['source'] ?? '',
              'type': data['type'] ?? '',
            };
            isDetailLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            detailData = widget.animeInfo ?? {};
            isDetailLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          detailData = widget.animeInfo ?? {};
          isDetailLoading = false;
        });
      }
    }
  }

  Future<void> _loadEpisodes() async {
    setState(() {
      isEpisodeLoading = true;
      episodeError = null;
    });

    try {
      final result = await fetchEpisodes(widget.malId, page: episodePage);
      if (mounted) {
        setState(() {
          episodes = result['episodes'] as List<Map<String, dynamic>>;
          hasMoreEpisodes = result['hasMore'] as bool;
          isEpisodeLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          episodeError = e.toString();
          isEpisodeLoading = false;
        });
      }
    }
  }

  Future<Map<String, dynamic>> fetchEpisodes(int malId,
      {int page = 1}) async {
    final response = await http
        .get(Uri.parse('$baseUrl/anime/$malId/episodes?page=$page'))
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final List<dynamic> data = json['data'] ?? [];
      final pagination = json['pagination'];
      final bool hasMore = pagination?['has_next_page'] ?? false;

      return {
        'episodes': data.map<Map<String, dynamic>>((ep) {
          return {
            'number': ep['mal_id'] ?? 0,
            'title': ep['title'] ?? '',
            'aired': ep['aired'] ?? '',
            'filler': ep['filler'] ?? false,
            'recap': ep['recap'] ?? false,
          };
        }).toList(),
        'hasMore': hasMore,
      };
    } else {
      throw Exception('Failed to load episodes (${response.statusCode})');
    }
  }

  void _loadMoreEpisodes() {
    setState(() {
      episodePage++;
    });
    _loadMoreEpisodesAppend();
  }

  Future<void> _loadMoreEpisodesAppend() async {
    try {
      final result = await fetchEpisodes(widget.malId, page: episodePage);
      if (mounted) {
        setState(() {
          episodes.addAll(
              result['episodes'] as List<Map<String, dynamic>>);
          hasMoreEpisodes = result['hasMore'] as bool;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          episodePage--;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load more episodes: $e')),
        );
      }
    }
  }

  //==== BUILD =====

  @override
  Widget build(BuildContext context) {
    final info =
        detailData.isNotEmpty ? detailData : (widget.animeInfo ?? {});

    final String title = info['title']?.toString() ?? 'Unknown Title';
    final String imageUrl = info['imageUrl']?.toString() ?? '';
    final String backdropUrl =
        info['backdropUrl']?.toString() ?? imageUrl;
    final double? score = info['score'] != null
        ? double.tryParse(info['score'].toString())
        : null;
    final String synopsis =
        info['synopsis']?.toString() ?? 'No synopsis available.';
    final String status = info['status']?.toString() ?? '-';
    final String releaseDate = info['releaseDate']?.toString() ?? '-';
    final List<String> genres = info['genres'] is List
        ? List<String>.from(
            (info['genres'] as List).map((g) => g.toString()))
        : [];
    final String duration = info['duration']?.toString() ?? '-';
    final String rating = info['rating']?.toString() ?? '-';
    final String source = info['source']?.toString() ?? '-';
    final String type = info['type']?.toString() ?? '-';
    final List<String> studios = info['studios'] is List
        ? List<String>.from(
            (info['studios'] as List).map((s) => s.toString()))
        : [];

    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: SafeArea(
        top: false,
        child: isDetailLoading && detailData.isEmpty
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              )
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(
                      context,
                      title: title,
                      imageUrl: imageUrl,
                      backdropUrl: backdropUrl,
                      score: score,
                      status: status,
                    ),
                    _buildDescriptionSection(synopsis),
                    if (genres.isNotEmpty) _buildGenresSection(genres),
                    _buildInfoSection(
                      status: status,
                      releaseDate: releaseDate,
                      duration: duration,
                      rating: rating,
                      source: source,
                      type: type,
                      studios: studios,
                    ),
                    _buildEpisodeSection(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
      ),
    );
  }

  //===== HEADER =====

  Widget _buildHeader(
    BuildContext context, {
    required String title,
    required String imageUrl,
    required String backdropUrl,
    required double? score,
    required String status,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = MediaQuery.of(context).size.width;
        final backdropHeight = screenWidth * 9 / 16;
        final posterHeight = backdropHeight * 0.75;
        final posterWidth = posterHeight * 0.65;
        final overlapOffset = backdropHeight - (posterHeight * 0.4);

        return SizedBox(
          height: backdropHeight + (posterHeight * 0.6),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              SizedBox(
                height: backdropHeight,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    backdropUrl.isNotEmpty
                        ? Image.network(
                            backdropUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                Container(color: AppColors.darkSurface),
                          )
                        : Container(color: AppColors.darkSurface),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppColors.dark.withValues(alpha: 0),
                            AppColors.dark.withValues(alpha: 0.7),
                          ],
                          stops: const [0.4, 1.0],
                        ),
                      ),
                    ),
                    Positioned(
                      top: MediaQuery.of(context).padding.top + 8,
                      left: 8,
                      child: IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios_new,
                          color: AppColors.white,
                        ),
                        onPressed: () => Navigator.pop(context),
                        style: IconButton.styleFrom(
                          backgroundColor:
                              AppColors.dark.withValues(alpha: 0.3),
                          shape: const CircleBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: overlapOffset,
                left: 16,
                right: 16,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      width: posterWidth,
                      height: posterHeight,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.dark.withValues(alpha: 0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: imageUrl.isNotEmpty
                            ? Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  color: AppColors.darkSurface,
                                  child: const Icon(
                                    Icons.broken_image,
                                    color: AppColors.textTertiary,
                                  ),
                                ),
                              )
                            : Container(
                                color: AppColors.darkSurface,
                                child: const Icon(
                                  Icons.broken_image,
                                  color: AppColors.textTertiary,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              title,
                              style: AppTextStyles.heading4,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            if (score != null)
                              Row(
                                children: [
                                  const Icon(
                                    Icons.star,
                                    color: AppColors.warning,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    score.toStringAsFixed(1),
                                    style: const TextStyle(
                                      color: AppColors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const Text(
                                    ' / 10',
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            const SizedBox(height: 6),
                            _statusBadge(status),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _statusBadge(String status) {
    if (status.isEmpty || status == '-') return const SizedBox.shrink();
    final color = status.toLowerCase().contains('airing')
        ? AppColors.success
        : AppColors.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  //==== DESCRIPTION =====

  Widget _buildDescriptionSection(String synopsis) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Description'),
          const SizedBox(height: 8),
          Text(synopsis, style: AppTextStyles.textSecondary),
        ],
      ),
    );
  }

  //==== GENRES =====

  Widget _buildGenresSection(List<String> genres) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Genres'),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: genres.map((genre) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.6),
                    width: 1,
                  ),
                ),
                child: Text(
                  genre,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  //==== INFO =====

  Widget _buildInfoSection({
    required String status,
    required String releaseDate,
    required String duration,
    required String rating,
    required String source,
    required String type,
    required List<String> studios,
  }) {
    final List<Map<String, String>> metadata = [
      {'label': 'Status', 'value': status},
      {'label': 'Release Date', 'value': releaseDate},
      {'label': 'Type', 'value': type},
      {'label': 'Source', 'value': source},
      {'label': 'Duration', 'value': duration},
      {'label': 'Rating', 'value': rating},
      if (studios.isNotEmpty) {'label': 'Studio', 'value': studios.join(', ')},
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Information'),
          const SizedBox(height: 10),
          Wrap(
            spacing: 12,
            runSpacing: 10,
            children: metadata.map((item) {
              return SizedBox(
                width: (MediaQuery.of(context).size.width - 44) / 2,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${item['label']}: ',
                      style: AppTextStyles.textTertiary,
                    ),
                    Flexible(
                      child: Text(
                        item['value'] ?? '-',
                        style: AppTextStyles.labelMedium,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  //==== EPISODE LIST =====

  Widget _buildEpisodeSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _sectionTitle('Episode List'),
              if (episodes.isNotEmpty)
                Text(
                  '${episodes.length} eps',
                  style: AppTextStyles.textTertiary,
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (isEpisodeLoading && episodes.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            )
          else if (episodeError != null && episodes.isEmpty)
            Center(
              child: Column(
                children: [
                  Text(
                    episodeError!,
                    style: const TextStyle(
                      color: AppColors.error,
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: _loadEpisodes,
                    child: const Text(
                      'Retry',
                      style: TextStyle(color: AppColors.primary),
                    ),
                  ),
                ],
              ),
            )
          else if (episodes.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'No episodes available.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ),
            )
          else
            Column(
              children: [
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate:
                      const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 72,
                    mainAxisExtent: 52,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: episodes.length,
                  itemBuilder: (context, index) {
                    final ep = episodes[index];
                    final epNumber =
                        ep['number']?.toString() ?? '${index + 1}';
                    final bool isFiller = ep['filler'] == true;
                    final bool isRecap = ep['recap'] == true;

                    return GestureDetector(
                      onTap: () {
                        // TODO: Navigate to video player with episode data
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: isFiller
                              ? AppColors.primary.withValues(alpha: 0.15)
                              : isRecap
                                  ? AppColors.warning.withValues(alpha: 0.15)
                                  : AppColors.darkSurface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isFiller
                                ? AppColors.primary.withValues(alpha: 0.5)
                                : isRecap
                                    ? AppColors.warning
                                        .withValues(alpha: 0.5)
                                    : AppColors.primary
                                        .withValues(alpha: 0.4),
                            width: 1,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            epNumber,
                            style: AppTextStyles.heading4,
                          ),
                        ),
                      ),
                    );
                  },
                ),

                // Load More
                if (hasMoreEpisodes) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: CustomButton(
                      text: 'Load More Episodes',
                      isOutlined: true,
                      isLoading: isEpisodeLoading,
                      onPressed:
                          isEpisodeLoading ? null : _loadMoreEpisodes,
                    ),
                  ),
                ],
              ],
            ),
        ],
      ),
    );
  }

  //==== HELPER =====

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: AppColors.white,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}