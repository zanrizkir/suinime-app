import 'services/api_service.dart';
import 'services/consumet_service.dart';
import 'models/anime_model.dart';

void main() async {
  print('=== TESTING API SERVICE ===\n');

  final apiService = ApiService();
  final consumetService = ConsumetService();

  // Test 1: Fetch Top Anime
  print('📺 TEST 1: Fetch Top Anime');
  try {
    List<AnimeModel> topAnime = await apiService.fetchTopAnime();
    print('✅ Sukses! Mendapatkan ${topAnime.length} anime');
    if (topAnime.isNotEmpty) {
      print('   Contoh: ${topAnime[0].title} (Score: ${topAnime[0].score})');
    }
  } catch (e) {
    print('❌ Gagal: $e');
  }
  print(''); // Spasi

  // Test 2: Search Anime
  print('🔍 TEST 2: Search Anime');
  try {
    List<AnimeModel> searchResults = await apiService.searchAnime('naruto');
    print('✅ Sukses! Menemukan ${searchResults.length} anime');
    for (var i = 0; i < searchResults.length && i < 3; i++) {
      print('   ${i + 1}. ${searchResults[i].title}');
    }
  } catch (e) {
    print('❌ Gagal: $e');
  }
  print('');

  // Test 3: Anime Detail
  print('📝 TEST 3: Fetch Anime Detail');
  try {
    var detail = await apiService.fetchAnimeDetail(21); // One Piece
    print('✅ Sukses!');
    print('   Judul: ${detail.title}');
    print('   Status: ${detail.status}');
    print('   Episode: ${detail.episodes}');
    print('   Genre: ${detail.genres.join(", ")}');
    print(
      '   Sinopsis: ${detail.synopsis?.substring(0, detail.synopsis!.length > 100 ? 100 : detail.synopsis!.length)}...',
    );
  } catch (e) {
    print('❌ Gagal: $e');
  }
  print('');

  // Test 4: Consumet Service (Streaming)
  print('🎬 TEST 4: Fetch Streaming Link');
  try {
    List<Map<String, dynamic>> videoSources = await consumetService
        .fetchStreamingLinks('naruto-episode-1');
    String videoUrl = videoSources.first['url'];
    print('✅ Sukses!');
    print('   URL Video: $videoUrl');
  } catch (e) {
    print('❌ Gagal: $e');
    print('   Catatan: Consumet API mungkin perlu endpoint yang valid');
  }
  print('');

  // Test 5: Error Handling
  print('⚠️ TEST 5: Error Handling Test');
  try {
    await apiService.searchAnime('');
  } catch (e) {
    print('✅ Error berhasil ditangkap: $e');
  }

  try {
    await apiService.fetchAnimeDetail(-1);
  } catch (e) {
    print('✅ Error berhasil ditangkap: $e');
  }

  print('\n=== SEMUA TEST SELESAI ===');
}
