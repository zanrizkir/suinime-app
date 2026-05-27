import 'dart:convert';
import 'package:http/http.dart' as http;

class OtakudesuService {
  final String baseUrl =
      'https://a7da-2404-c0-a702-8f8c-d808-f3a9-951-bd27.ngrok-free.app';

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
          final data = json['data'] as Map?;
          if (data == null) {
            return {'success': false, 'error': 'Data episode tidak ditemukan'};
          }
          final mirrors = _parseStreamMirrors(data);
          final streamUrl = mirrors.isNotEmpty
              ? mirrors.first['url']
              : _firstText([data['stream_url'], data['streaming_url']]);
          return {
            'success': true,
            'streamUrl': streamUrl,
            'mirrors': mirrors,
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

  List<Map<String, String>> _parseStreamMirrors(dynamic data) {
    final mirrors = <Map<String, String>>[];

    void addMirror({
      required String? url,
      String? label,
      String? quality,
      String? server,
    }) {
      final cleanUrl = url?.trim();
      if (cleanUrl == null || cleanUrl.isEmpty) return;
      if (mirrors.any((mirror) => mirror['url'] == cleanUrl)) return;

      final parts = <String>[
        if (quality != null && quality.trim().isNotEmpty) quality.trim(),
        if (server != null && server.trim().isNotEmpty) server.trim(),
      ];
      final cleanLabel = label?.trim().isNotEmpty == true
          ? label!.trim()
          : parts.join(' - ');

      mirrors.add({
        'label': cleanLabel.isEmpty
            ? 'Server ${mirrors.length + 1}'
            : cleanLabel,
        'url': cleanUrl,
        if (quality != null && quality.trim().isNotEmpty)
          'quality': quality.trim(),
        if (server != null && server.trim().isNotEmpty) 'server': server.trim(),
      });
    }

    void parseItem(dynamic item, {String? inheritedQuality}) {
      if (item is String) {
        addMirror(url: item, quality: inheritedQuality);
        return;
      }

      if (item is! Map) return;

      final quality = _firstText([
        item['quality'],
        item['resolution'],
        item['resolusi'],
      ]);

      final server = _firstText([
        item['server'],
        item['server_name'],
        item['name'],
        item['title'],
      ]);

      final url = _firstText([
        item['url'],
        item['stream_url'],
        item['streaming_url'],
        item['embed_url'],
        item['link'],
        item['iframe'],
        item['file'],
      ]);

      addMirror(
        url: url,
        label: item['label']?.toString(),
        quality: quality ?? inheritedQuality,
        server: server,
      );

      for (final key in [
        'servers',
        'server_list',
        'mirrors',
        'sources',
        'urls',
        'links',
      ]) {
        final children = item[key];
        if (children is List) {
          for (final child in children) {
            parseItem(child, inheritedQuality: quality ?? inheritedQuality);
          }
        }
      }
    }

    if (data is Map) {
      for (final key in [
        'mirrors',
        'mirror',
        'servers',
        'server',
        'qualities',
        'quality',
        'sources',
        'video_sources',
        'stream_urls',
        'streaming_urls',
      ]) {
        final source = data[key];
        if (source is List) {
          for (final item in source) {
            parseItem(item);
          }
        } else if (source is Map) {
          for (final entry in source.entries) {
            final inheritedQuality = entry.key.toString();
            final value = entry.value;
            if (value is List) {
              for (final item in value) {
                parseItem(item, inheritedQuality: inheritedQuality);
              }
            } else {
              parseItem(value, inheritedQuality: inheritedQuality);
            }
          }
        }
      }

      addMirror(
        url: _firstText([data['stream_url'], data['streaming_url']]),
        label: 'Default',
      );
    }

    return mirrors;
  }

  String? _firstText(Iterable<dynamic> values) {
    for (final value in values) {
      final text = value?.toString().trim();
      if (text != null && text.isNotEmpty) return text;
    }
    return null;
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
