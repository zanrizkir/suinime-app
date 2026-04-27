import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/anime_model.dart';

class ApiService {
  static const String baseUrl = 'https://api.jikan.moe/v4';

  // Mengubah Future<void> menjadi Future<List<AnimeModel>>
  Future<List<AnimeModel>> fetchTopAnime() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/top/anime'));
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);
        final List<dynamic> animeListJson = jsonData['data'];
        
        // Memetakan (mapping) setiap item JSON menjadi object AnimeModel
        return animeListJson.map((json) => AnimeModel.fromJson(json)).toList();
      } else {
        throw Exception('Gagal memuat data dari server');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan jaringan: $e');
    }
  }
}