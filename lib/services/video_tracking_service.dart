import 'package:video_player/video_player.dart';
import 'hive_service.dart';

/// Service for tracking video playback and continue watching functionality
class VideoTrackingService {
  /// Save continue watching progress
  static Future<void> trackWatchProgress({
    required int malId,
    required String animeTitle,
    required String imageUrl,
    required int episodeNumber,
    required VideoPlayerController videoController,
  }) async {
    try {
      if (!videoController.value.isInitialized) return;

      final position = videoController.value.position.inMilliseconds;
      final duration = videoController.value.duration.inMilliseconds;

      // Only save if watched more than 10 seconds
      if (position > 10000) {
        await HiveService.saveContinueWatching(
          malId: malId,
          animeTitle: animeTitle,
          imageUrl: imageUrl,
          episodeNumber: episodeNumber,
          position: position,
          duration: duration,
        );

        // Also update watch history
        await HiveService.addToWatchHistory(
          malId: malId,
          title: animeTitle,
          imageUrl: imageUrl,
          lastEpisode: episodeNumber,
        );
      }
    } catch (e) {
      print('Error tracking watch progress: $e');
    }
  }

  /// Get resume position for anime
  static Duration? getResumePosition(int malId) {
    try {
      final continueWatching = HiveService.getContinueWatching(malId);
      if (continueWatching != null) {
        return Duration(milliseconds: continueWatching.position);
      }
      return null;
    } catch (e) {
      print('Error getting resume position: $e');
      return null;
    }
  }

  /// Check if anime should resume from last position
  static bool shouldResumeFromLastPosition(int malId) {
    try {
      final continueWatching = HiveService.getContinueWatching(malId);
      if (continueWatching == null) return false;

      // Only resume if less than 95% watched
      final progress = continueWatching.position / continueWatching.duration;
      return progress < 0.95;
    } catch (e) {
      print('Error checking resume: $e');
      return false;
    }
  }

  /// Clear continue watching for anime (when episode is finished)
  static Future<void> markAsCompleted(int malId) async {
    try {
      await HiveService.removeContinueWatching(malId);
    } catch (e) {
      print('Error marking as completed: $e');
    }
  }
}
