import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/anime_model.dart';
import '../models/paginated_anime_response.dart';

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
        throw Exception(
          'Gagal mengambil data. Status Code: ${response.statusCode}',
        );
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
        Uri.parse('$baseUrl/anime?q=${Uri.encodeComponent(query)}&limit=20'),
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
        throw Exception(
          'Gagal mencari anime. Status Code: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Kesalahan pada searchAnime: $e');
      throw Exception('Gagal melakukan pencarian: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchAnimeGenres() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/genres/anime'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);
        final List<dynamic> genreList = jsonData['data'] ?? [];

        return genreList
            .map<Map<String, dynamic>>(
              (genre) => {'id': genre['mal_id'], 'name': genre['name']},
            )
            .toList()
          ..sort(
            (a, b) => a['name'].toString().toLowerCase().compareTo(
              b['name'].toString().toLowerCase(),
            ),
          );
      } else {
        throw Exception(
          'Gagal mengambil genre. Status Code: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Kesalahan pada fetchAnimeGenres: $e');
      throw Exception('Gagal memuat daftar genre: $e');
    }
  }

  Future<List<AnimeModel>> fetchAnimeByGenre(
    int genreId, {
    int page = 1,
  }) async {
    final response = await fetchAnimeByGenrePaginated(genreId, page: page);
    return response.anime;
  }

  Future<PaginatedAnimeResponse> fetchAnimeByGenrePaginated(
    int genreId, {
    int page = 1,
  }) async {
    if (genreId <= 0) {
      throw Exception('ID genre tidak valid');
    }

    try {
      final response = await http.get(
        Uri.parse(
          '$baseUrl/anime?genres=$genreId&page=$page&order_by=score&sort=desc',
        ),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);
        return PaginatedAnimeResponse.fromJson(jsonData, requestedPage: page);
      } else {
        throw Exception(
          'Gagal mengambil anime genre. Status Code: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Kesalahan pada fetchAnimeByGenre: $e');
      throw Exception('Gagal memuat anime berdasarkan genre: $e');
    }
  }

  Future<List<AnimeModel>> getCompletedAnime({int page = 1}) async {
    final response = await getCompletedAnimePaginated(page: page);
    return response.anime;
  }

  Future<PaginatedAnimeResponse> getCompletedAnimePaginated({
    int page = 1,
  }) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$baseUrl/anime?status=complete&page=$page&order_by=score&sort=desc',
        ),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);
        return PaginatedAnimeResponse.fromJson(jsonData, requestedPage: page);
      } else {
        throw Exception(
          'Gagal mengambil completed anime. Status Code: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Kesalahan pada getCompletedAnime: $e');
      return PaginatedAnimeResponse(
        anime: const [],
        currentPage: page,
        totalPages: page,
        perPage: 0,
        hasNextPage: false,
      );
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
        throw Exception(
          'Gagal mengambil detail. Status Code: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Kesalahan pada fetchAnimeDetail: $e');
      throw Exception('Gagal memuat detail anime: $e');
    }
  }
}
