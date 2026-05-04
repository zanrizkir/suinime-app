import 'dart:convert';
import 'package:http/http.dart' as http;

class ConsumetService {
  // Base URL Consumet API (menggunakan endpoint yang aktif)
  static const String baseUrl = 'https://api.consumet.org/anime/gogoanime';
  
  // Timeout duration
  static const Duration timeoutDuration = Duration(seconds: 10);

  /// Mencari ID anime di database Consumet berdasarkan judul
  /// Mengembalikan String berupa id anime Consumet dari hasil pencarian pertama
  Future<String> searchConsumetId(String title) async {
    if (title.isEmpty) {
      throw Exception('Judul anime tidak boleh kosong');
    }

    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/search?keyw=${Uri.encodeComponent(title)}'),
          )
          .timeout(timeoutDuration);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);
        
        if (jsonData['results'] != null && 
            jsonData['results'] is List && 
            (jsonData['results'] as List).isNotEmpty) {
          
          final firstResult = (jsonData['results'] as List).first;
          final consumetId = firstResult['id']?.toString();
          
          if (consumetId != null && consumetId.isNotEmpty) {
            print('Berhasil mencari ID Consumet untuk "$title": $consumetId');
            return consumetId;
          } else {
            throw Exception('ID anime tidak ditemukan dalam response');
          }
        } else {
          throw Exception('Tidak ada hasil pencarian untuk judul "$title"');
        }
      } else if (response.statusCode == 404) {
        throw Exception('Anime dengan judul "$title" tidak ditemukan');
      } else {
        throw Exception(
            'Gagal mencari anime. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      if (e is http.ClientException) {
        print('Kesalahan koneksi pada searchConsumetId: $e');
        throw Exception('Gagal terhubung ke server. Periksa koneksi internet Anda.');
      } else if (e.toString().contains('Timeout')) {
        throw Exception('Permintaan timeout setelah 10 detik. Silakan coba lagi.');
      } else {
        print('Kesalahan pada searchConsumetId: $e');
        throw Exception('Gagal mencari ID anime: $e');
      }
    }
  }

  /// Mengambil daftar episode berdasarkan ID Consumet
  /// Kembalikan List<Map<String, dynamic>> berisi ID episode dan nomor episodenya
  Future<List<Map<String, dynamic>>> fetchEpisodes(String consumetId) async {
    if (consumetId.isEmpty) {
      throw Exception('Consumet ID tidak boleh kosong');
    }

    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/info/$consumetId'),
          )
          .timeout(timeoutDuration);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);
        
        List<Map<String, dynamic>> episodeList = [];
        
        if (jsonData['episodes'] != null && jsonData['episodes'] is List) {
          final episodes = jsonData['episodes'] as List;
          
          for (var episode in episodes) {
            final episodeId = episode['id']?.toString();
            final episodeNumber = episode['number'];
            
            if (episodeId != null && episodeId.isNotEmpty) {
              episodeList.add({
                'episodeId': episodeId,
                'episodeNumber': episodeNumber ?? 0,
                'title': episode['title'] ?? 'Episode $episodeNumber',
              });
            }
          }
        }
        
        if (episodeList.isEmpty) {
          throw Exception('Tidak ada episode yang ditemukan untuk ID: $consumetId');
        }
        
        print('Berhasil mengambil ${episodeList.length} episode untuk ID: $consumetId');
        return episodeList;
      } else if (response.statusCode == 404) {
        throw Exception('Anime dengan ID $consumetId tidak ditemukan');
      } else {
        throw Exception(
            'Gagal mengambil daftar episode. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      if (e is http.ClientException) {
        print('Kesalahan koneksi pada fetchEpisodes: $e');
        throw Exception('Gagal terhubung ke server. Periksa koneksi internet Anda.');
      } else if (e.toString().contains('Timeout')) {
        throw Exception('Permintaan timeout setelah 10 detik. Silakan coba lagi.');
      } else {
        print('Kesalahan pada fetchEpisodes: $e');
        throw Exception('Gagal mengambil daftar episode: $e');
      }
    }
  }

  /// Mengambil link streaming video untuk diputar
  /// Kembalikan List<Map<String, dynamic>> berisi daftar URL video beserta kualitas/resolusinya
  Future<List<Map<String, dynamic>>> fetchStreamingLinks(String episodeId) async {
    if (episodeId.isEmpty) {
      throw Exception('Episode ID tidak boleh kosong');
    }

    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/watch/$episodeId'),
          )
          .timeout(timeoutDuration);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);
        
        List<Map<String, dynamic>> videoSources = [];
        
        // Cek format response dari Consumet API
        if (jsonData['sources'] != null && jsonData['sources'] is List) {
          final sources = jsonData['sources'] as List;
          
          for (var source in sources) {
            final url = source['url']?.toString();
            final quality = source['quality']?.toString() ?? 'Unknown';
            final isM3U8 = url?.contains('.m3u8') ?? false;
            
            if (url != null && url.isNotEmpty) {
              videoSources.add({
                'url': url,
                'quality': quality,
                'isM3U8': isM3U8,
                'type': isM3U8 ? 'hls' : 'mp4',
              });
            }
          }
        }
        
        // Format alternatif: videoUrl langsung
        if (videoSources.isEmpty && jsonData['videoUrl'] != null) {
          final url = jsonData['videoUrl']?.toString();
          if (url != null && url.isNotEmpty) {
            videoSources.add({
              'url': url,
              'quality': 'Auto',
              'isM3U8': url.contains('.m3u8'),
              'type': url.contains('.m3u8') ? 'hls' : 'mp4',
            });
          }
        }
        
        // Tambahan: backup links jika ada
        if (jsonData['backupSources'] != null && jsonData['backupSources'] is List) {
          final backups = jsonData['backupSources'] as List;
          for (var backup in backups) {
            final url = backup['url']?.toString();
            if (url != null && url.isNotEmpty) {
              videoSources.add({
                'url': url,
                'quality': 'Backup - ${backup['quality'] ?? 'Unknown'}',
                'isM3U8': url.contains('.m3u8'),
                'type': url.contains('.m3u8') ? 'hls' : 'mp4',
              });
            }
          }
        }
        
        if (videoSources.isEmpty) {
          throw Exception('Tidak ada link streaming yang ditemukan untuk episode: $episodeId');
        }
        
        // Urutkan berdasarkan kualitas (1080p > 720p > 480p > 360p > lainnya)
        videoSources.sort((a, b) {
          int getQualityRank(String quality) {
            if (quality.contains('1080')) return 5;
            if (quality.contains('720')) return 4;
            if (quality.contains('480')) return 3;
            if (quality.contains('360')) return 2;
            if (quality.contains('Backup')) return 1;
            return 0;
          }
          return getQualityRank(b['quality']).compareTo(getQualityRank(a['quality']));
        });
        
        print('Berhasil mengambil ${videoSources.length} link streaming untuk episode: $episodeId');
        return videoSources;
      } else if (response.statusCode == 404) {
        throw Exception('Episode dengan ID $episodeId tidak ditemukan');
      } else {
        throw Exception(
            'Gagal mengambil link streaming. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      if (e is http.ClientException) {
        print('Kesalahan koneksi pada fetchStreamingLinks: $e');
        throw Exception('Gagal terhubung ke server. Periksa koneksi internet Anda.');
      } else if (e.toString().contains('Timeout')) {
        throw Exception('Permintaan timeout setelah 10 detik. Silakan coba lagi.');
      } else {
        print('Kesalahan pada fetchStreamingLinks: $e');
        throw Exception('Gagal mengambil link streaming: $e');
      }
    }
  }

  /// Method helper: Mendapatkan link streaming langsung dari judul anime dan nomor episode
  /// (Menggabungkan ketiga fungsi di atas untuk kemudahan Front-End)
  Future<Map<String, dynamic>> getStreamingLinkByTitleAndEpisode(
    String animeTitle,
    int episodeNumber,
  ) async {
    try {
      // Step 1: Cari consumet ID
      final consumetId = await searchConsumetId(animeTitle);
      
      // Step 2: Ambil daftar episode
      final episodes = await fetchEpisodes(consumetId);
      
      // Step 3: Cari episode yang sesuai
      final targetEpisode = episodes.firstWhere(
        (ep) => ep['episodeNumber'] == episodeNumber,
        orElse: () => {},
      );
      
      if (targetEpisode.isEmpty) {
        throw Exception('Episode $episodeNumber tidak ditemukan untuk anime "$animeTitle"');
      }
      
      final episodeId = targetEpisode['episodeId'];
      
      // Step 4: Ambil link streaming
      final videoSources = await fetchStreamingLinks(episodeId);
      
      return {
        'success': true,
        'consumetId': consumetId,
        'episodeId': episodeId,
        'episodeNumber': episodeNumber,
        'videoSources': videoSources,
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }
}