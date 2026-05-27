class AnimeModel {
  final int malId;
  final String title;
  final String imageUrl;
  final double? score;
  final String? type;
  final int? episodes;
  final int? year;
  final int? members;
  final int? rank;

  AnimeModel({
    required this.malId,
    required this.title,
    required this.imageUrl,
    this.score,
    this.type,
    this.episodes,
    this.year,
    this.members,
    this.rank,
  });

  factory AnimeModel.fromJson(Map<String, dynamic> json) {
    return AnimeModel(
      malId: json['mal_id'] ?? 0,
      title: json['title'] ?? 'No Title',
      imageUrl: json['images']['jpg']['image_url'] ?? '',
      score: (json['score'] as num?)?.toDouble(),
      type: json['type']?.toString(),
      episodes: (json['episodes'] as num?)?.toInt(),
      year: (json['year'] as num?)?.toInt(),
      members: (json['members'] as num?)?.toInt(),
      rank: (json['rank'] as num?)?.toInt(),
    );
  }
}

// Model baru untuk detail anime
class AnimeDetailModel {
  final int malId;
  final String title;
  final String imageUrl;
  final double? score;
  final String? synopsis;
  final String? status;
  final int? episodes;
  final List<String> genres;

  AnimeDetailModel({
    required this.malId,
    required this.title,
    required this.imageUrl,
    this.score,
    this.synopsis,
    this.status,
    this.episodes,
    required this.genres,
  });

  factory AnimeDetailModel.fromJson(Map<String, dynamic> json) {
    // Ekstrak daftar genre
    List<String> genreList = [];
    if (json['genres'] != null && json['genres'] is List) {
      genreList = (json['genres'] as List)
          .map((genre) => genre['name']?.toString() ?? 'Unknown')
          .toList();
    }

    return AnimeDetailModel(
      malId: json['mal_id'] ?? 0,
      title: json['title'] ?? 'No Title',
      imageUrl: json['images']['jpg']['image_url'] ?? '',
      score: (json['score'] as num?)?.toDouble(),
      synopsis: json['synopsis']?.toString(),
      status: json['status']?.toString(),
      episodes: json['episodes'],
      genres: genreList,
    );
  }
}
