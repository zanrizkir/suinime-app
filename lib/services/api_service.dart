import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/anime_model.dart';

class ApiService {
  static const String baseUrl = 'https://api.jikan.moe/v4';

  // Fungsi existing untuk mengambil top anime (diperbarui)
  Future<List<AnimeModel>> fetchTopAnime() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/top/anime'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);
        
        List<AnimeModel> animeList = [];
        if (jsonData['data'] != null && jsonData['data'] is List) {
          animeList = (jsonData['data'] as List)
              .map((item) => AnimeModel.fromJson(item))
              .toList();
        }
        
        print('Berhasil mengambil ${animeList.length} anime');
        return animeList;
      } else {
        throw Exception('Gagal mengambil data. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      print('Kesalahan pada fetchTopAnime: $e');
      throw Exception('Gagal memuat anime populer: $e');
    }
  }

  // Fungsi Pencarian
  Future<List<AnimeModel>> searchAnime(String query) async {
    if (query.isEmpty) {
      throw Exception('Query pencarian tidak boleh kosong');
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/anime?q=${Uri.encodeComponent(query)}&limit=20')
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);
        
        List<AnimeModel> searchResults = [];
        if (jsonData['data'] != null && jsonData['data'] is List) {
          searchResults = (jsonData['data'] as List)
              .map((item) => AnimeModel.fromJson(item))
              .toList();
        }
        
        print('Pencarian "$query" menemukan ${searchResults.length} anime');
        return searchResults;
      } else if (response.statusCode == 404) {
        return []; // Tidak ada hasil
      } else {
        throw Exception('Gagal mencari anime. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      print('Kesalahan pada searchAnime: $e');
      throw Exception('Gagal melakukan pencarian: $e');
    }
  }

  // Fungsi Detail Anime
  Future<AnimeDetailModel> fetchAnimeDetail(int malId) async {
    if (malId <= 0) {
      throw Exception('ID anime tidak valid');
    }

    try {
      final response = await http.get(Uri.parse('$baseUrl/anime/$malId/full'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);
        
        if (jsonData['data'] == null) {
          throw Exception('Data anime tidak ditemukan');
        }
        
        final animeDetail = AnimeDetailModel.fromJson(jsonData['data']);
        print('Berhasil mengambil detail anime: ${animeDetail.title}');
        return animeDetail;
      } else if (response.statusCode == 404) {
        throw Exception('Anime dengan ID $malId tidak ditemukan');
      } else {
        throw Exception('Gagal mengambil detail. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      print('Kesalahan pada fetchAnimeDetail: $e');
      throw Exception('Gagal memuat detail anime: $e');
    }
  }
}