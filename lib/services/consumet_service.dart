import 'dart:convert';
import 'package:http/http.dart' as http;

class ConsumetService {
  // Base URL untuk Consumet API (Gogoanime)
  static const String baseUrl = 'https://api.consumet.org/anime/gogoaname';
  
  // Alternatif endpoint (pilih salah satu yang tersedia)
  // static const String baseUrl = 'https://consumet-api-production-6b6e.up.railway.app/anime/gogoanime';
  
  /// Mencari link streaming berdasarkan episode ID
  /// episodeId: contoh "naruto-episode-1" atau ID dari provider
  Future<String> fetchStreamingLink(String episodeId) async {
    if (episodeId.isEmpty) {
      throw Exception('Episode ID tidak boleh kosong');
    }

    try {
      // Endpoint untuk mengambil link streaming
      final response = await http.get(
        Uri.parse('$baseUrl/watch/$episodeId')
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);
        
        // Coba ambil link dari berbagai format response yang mungkin
        String? videoUrl;
        
        // Format response untuk consumet API
        if (jsonData['sources'] != null && (jsonData['sources'] as List).isNotEmpty) {
          // Prioritaskan link dengan kualitas terbaik
          var sources = jsonData['sources'] as List;
          var bestSource = sources.firstWhere(
            (source) => source['quality'] == '1080p' || source['quality'] == '720p',
            orElse: () => sources.first
          );
          videoUrl = bestSource['url'];
        } 
        // Format alternatif
        else if (jsonData['videoUrl'] != null) {
          videoUrl = jsonData['videoUrl'];
        }
        else if (jsonData['streamUrl'] != null) {
          videoUrl = jsonData['streamUrl'];
        }
        
        if (videoUrl != null && videoUrl.isNotEmpty) {
          print('Berhasil mendapatkan link streaming untuk episode: $episodeId');
          return videoUrl;
        } else {
          throw Exception('Link streaming tidak ditemukan dalam response');
        }
      } else if (response.statusCode == 404) {
        throw Exception('Episode tidak ditemukan');
      } else {
        throw Exception('Gagal mengambil link streaming. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      print('Kesalahan pada fetchStreamingLink: $e');
      throw Exception('Gagal memuat link streaming: $e');
    }
  }
  
  /// Fungsi alternatif untuk mencari anime terlebih dahulu (opsional)
  Future<Map<String, dynamic>> searchAnimeOnConsumet(String query) async {
    if (query.isEmpty) {
      throw Exception('Query pencarian tidak boleh kosong');
    }
    
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/search?keyw=${Uri.encodeComponent(query)}')
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);
        print('Berhasil mencari anime di Consumet: $query');
        return jsonData;
      } else {
        throw Exception('Gagal mencari anime. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      print('Kesalahan pada searchAnimeOnConsumet: $e');
      throw Exception('Gagal mencari anime di Consumet: $e');
    }
  }
  
  /// Mendapatkan daftar episode untuk suatu anime (opsional)
  Future<List<String>> getEpisodeList(String animeId) async {
    if (animeId.isEmpty) {
      throw Exception('Anime ID tidak boleh kosong');
    }
    
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/episodes/$animeId')
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);
        
        List<String> episodeUrls = [];
        if (jsonData['episodes'] != null && jsonData['episodes'] is List) {
          episodeUrls = (jsonData['episodes'] as List)
              .map((ep) => ep['episodeId']?.toString() ?? '')
              .where((id) => id.isNotEmpty)
              .toList();
        }
        
        print('Berhasil mengambil ${episodeUrls.length} episode');
        return episodeUrls;
      } else {
        throw Exception('Gagal mengambil daftar episode');
      }
    } catch (e) {
      print('Kesalahan pada getEpisodeList: $e');
      throw Exception('Gagal memuat daftar episode: $e');
    }
  }
}