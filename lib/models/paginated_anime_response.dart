import 'anime_model.dart';

class PaginatedAnimeResponse {
  final List<AnimeModel> anime;
  final int currentPage;
  final int totalPages;
  final bool hasNextPage;

  const PaginatedAnimeResponse({
    required this.anime,
    required this.currentPage,
    required this.totalPages,
    required this.hasNextPage,
  });

  factory PaginatedAnimeResponse.fromJson(
    Map<String, dynamic> json, {
    required int requestedPage,
  }) {
    final dataList = json['data'] is List ? json['data'] as List : const [];
    final pagination = json['pagination'] is Map<String, dynamic>
        ? json['pagination'] as Map<String, dynamic>
        : const <String, dynamic>{};
    final items = pagination['items'] is Map<String, dynamic>
        ? pagination['items'] as Map<String, dynamic>
        : const <String, dynamic>{};

    final anime = dataList.map((item) => AnimeModel.fromJson(item)).toList();
    final perPage = _asInt(items['per_page']) ?? anime.length;
    final totalItems = _asInt(items['total']);
    final apiTotalPages = _asInt(pagination['last_visible_page']);
    final calculatedTotalPages = totalItems != null && perPage > 0
        ? (totalItems / perPage).ceil()
        : null;
    final hasNextPage = pagination['has_next_page'] == true;
    final fallbackTotalPages = hasNextPage ? requestedPage + 1 : requestedPage;

    return PaginatedAnimeResponse(
      anime: anime,
      currentPage: requestedPage,
      totalPages: [apiTotalPages, calculatedTotalPages, fallbackTotalPages]
          .whereType<int>()
          .where((page) => page > 0)
          .fold<int>(1, (maxPage, page) => page > maxPage ? page : maxPage),
      hasNextPage: hasNextPage,
    );
  }

  static int? _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }
}
