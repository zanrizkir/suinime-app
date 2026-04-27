class AnimeModel {
  final int malId;
  final String title;
  final String imageUrl;
  final double? score;

  AnimeModel({
    required this.malId,
    required this.title,
    required this.imageUrl,
    this.score,
  });

  // Fungsi untuk mengubah JSON dari API menjadi Object Dart
  factory AnimeModel.fromJson(Map<String, dynamic> json) {
    return AnimeModel(
      malId: json['mal_id'] ?? 0,
      title: json['title'] ?? 'No Title',
      // Mengambil URL gambar dari struktur JSON Jikan API yang bertingkat
      imageUrl: json['images']['jpg']['image_url'] ?? '',
      score: (json['score'] as num?)?.toDouble(),
    );
  }
}