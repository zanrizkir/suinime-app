import '../models/library_model.dart';
import '../models/anime_model.dart';

/// Extension to convert LibraryItem to AnimeModel for use with unified AnimeCard widget
extension LibraryItemConverter on LibraryItem {
  /// Convert LibraryItem to AnimeModel (preserves core display fields)
  AnimeModel toAnimeModel() {
    return AnimeModel(
      malId: malId,
      title: title,
      imageUrl: imageUrl,
      score: score,
    );
  }
}
