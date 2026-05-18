import 'dart:convert';
import 'package:http/http.dart' as http;

class OtakudesuService {
  final String baseUrl = 'https://gala-seminar-seismic.ngrok-free.dev';

  final Map<String, String> _headers = {
    'ngrok-skip-browser-warning': 'true',
    'Content-Type': 'application/json',
  };

  /// Mencari anime berdasarkan kata kunci
  Future<List<Map<String, dynamic>>> searchAnime(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/v1/search/$query'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(json['data'] ?? []);
      }
      return [];
    } catch (e) {
      print('Error Search: $e');
      return [];
    }
  }

  /// Mendapatkan detail anime dan daftar episode berdasarkan slug anime
  Future<Map<String, dynamic>> getAnimeDetail(String slug) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/v1/anime/$slug'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return json['data'] as Map<String, dynamic>;
      }
      throw Exception('Gagal memuat detail anime');
    } catch (e) {
      print('Error Detail: $e');
      rethrow;
    }
  }

  /// Mendapatkan link streaming iframe berdasarkan slug episode
  Future<Map<String, dynamic>> fetchEpisodeStream(String episodeSlug) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/v1/episode/$episodeSlug'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['status'] == 'Ok') {
          final data = json['data'];
          return {
            'success': true,
            'streamUrl': data['stream_url'],
            'title': data['episode'],
            'hasNext': data['has_next_episode'] ?? false,
            'nextSlug': data['next_episode']?['slug'],
            'hasPrev': data['has_previous_episode'] ?? false,
            'prevSlug': data['previous_episode']?['slug'],
          };
        }
      }
      return {'success': false, 'error': 'Gagal mengambil data dari server'};
    } catch (e) {
      print('Error Stream: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<String?> findEpisodeSlugExact(
    String jikanTitle,
    int episodeNumber,
  ) async {
    try {
      final cleanedTitle = jikanTitle
          .toLowerCase()
          .replaceAll(RegExp(r'\b(season|part|cour)\s*\d*\b'), ' ')
          .replaceAll(RegExp(r'\bthe\s+movie\b'), ' ')
          .replaceAll(RegExp(r'[:\-\(\)]'), ' ')
          .replaceAll(RegExp(r'\s+'), ' ')
          .trim();
      final words = cleanedTitle
          .split(' ')
          .where((word) => word.trim().isNotEmpty)
          .take(3)
          .toList();
      if (words.length > 2) {
        words.removeRange(2, words.length);
      }
      final searchQuery = words.join(' ');
      if (searchQuery.isEmpty) return null;

      final searchResults = await searchAnime(searchQuery);
      if (searchResults.isEmpty) return null;

      final animeSlug = searchResults.first['slug']?.toString();
      if (animeSlug == null || animeSlug.isEmpty) return null;

      final detail = await getAnimeDetail(animeSlug);
      final List<dynamic> episodes = detail['episode_lists'] ?? [];
      final regex = RegExp(r'\b0?' + episodeNumber.toString() + r'\b');

      for (final ep in episodes) {
        if (ep is! Map) continue;

        final String epTitle = [
          ep['episode'],
          ep['title'],
          ep['name'],
        ].where((value) => value != null).join(' ').toLowerCase();

        if (regex.hasMatch(epTitle)) {
          final slug = ep['slug']?.toString();
          if (slug != null && slug.isNotEmpty) return slug;
        }
      }

      return null;
    } catch (e) {
      print('Error Bridging: $e');
      return null;
    }
  }
}
