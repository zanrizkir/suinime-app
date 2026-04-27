import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Base URL Jikan API versi 4
  static const String baseUrl = 'https://api.jikan.moe/v4';

  // Fungsi untuk mengambil data top anime
  Future<void> fetchTopAnime() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/top/anime'));

      // Jika koneksi sukses (Kode 200)
      if (response.statusCode == 200) {
        // Ubah respons JSON (String) menjadi bentuk Map/List (Object)
        final Map<String, dynamic> jsonData = jsonDecode(response.body);
        
        // Ambil data pertama untuk tes (bisa dihapus nanti)
        final firstAnimeTitle = jsonData['data'][0]['title'];
        print('Koneksi Sukses! Judul anime pertama: $firstAnimeTitle');
        
      } else {
        print('Gagal mengambil data. Error Code: ${response.statusCode}');
      }
    } catch (e) {
      print('Terjadi kesalahan jaringan: $e');
    }
  }
}